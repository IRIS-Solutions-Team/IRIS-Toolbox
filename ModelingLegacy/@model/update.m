function [this, ok] = update(this, p, variantRequested)
% update  Update parameters, sstate, solve, and refresh
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

if nargin<3
    variantRequested = 1;
end

%--------------------------------------------------------------------------

update = this.Update;
posValues = update.PosOfValues;
posStdCorr = update.PosOfStdCorr;

inxValues = ~isnan(posValues);
posValues = posValues(inxValues);
inxStdCorr = ~isnan(posStdCorr);
posStdCorr = posStdCorr(inxStdCorr);

% Reset parameters and stdcorrs
this.Variant.Values(:, :, variantRequested) = update.Values;
this.Variant.StdCorr(:, :, variantRequested) = update.StdCorr;

runSteady = ~isequal(update.Steady, false);
runSolve = ~isequal(update.Solve, false);
runCheckSteady = ~isequal(update.CheckSteady, false);

% Update regular parameters and run refresh if needed
needsRefresh = any(this.Link);
beenRefreshed = false;
if any(inxValues)
    this.Variant.Values(:, posValues, variantRequested) = p(inxValues);
end

% Update stdCorr
if any(inxStdCorr)
    this.Variant.StdCorr(:, posStdCorr, variantRequested) = p(inxStdCorr);
end

% Refresh dynamic links; the links can refer/define std devs and
% cross-corrs
if needsRefresh
    this = refresh(this, variantRequested);
    beenRefreshed = true;
end

% If only stds or corrs have been changed, no values have been
% refreshed, and no user preprocessor is called, return immediately as
% there is no need to re-solve or re-sstate the model.
if ~any(inxValues) && ~isa(update.Steady, 'function_handle') && ~beenRefreshed
    ok = true;
    return
end

if this.IsLinear
    %
    % Linear Models
    %
    if runSolve
        [this, numStablePaths, nanDerv, sing2, bk] = ...
            solveFirstOrder(this, variantRequested, update.Solve);
    else
        numStablePaths = 1;
    end
    if runSteady
        this = steadyLinear(this, update.Steady, variantRequested);
        if needsRefresh
            this = refresh(this, variantRequested);
        end
    end
    okSteady = true;
    okCheckSteady = true;
	sstateErrList = { };

else
    %
    % Nonlinear Models
    %
    okSteady = true;
    sstateErrList = { };
    okCheckSteady = true;
    nanDerv = [ ];
    sing2 = false;
    bk = nan(3, 1);
    if runSteady
        if isa(update.Steady, 'function_handle')
            % Call to a user-supplied sstate solver.
            m = this(variantRequested);
            [m, okSteady] = feval(update.Steady, m);
            this(variantRequested) = m;
        elseif iscell(update.Steady) && isa(update.Steady{1}, 'function_handle')
            %  Call to a user-supplied sstate solver with extra arguments.
            m = this(variantRequested);
            [m, okSteady] = feval(update.Steady{1}, m, update.Steady{2:end});
            this(variantRequested) = m;
        else
             % Call to the [IrisToolbox] sstate solver.
            [this, okSteady] = steadyNonlinear( this, ...
                                                update.Steady, ...
                                                variantRequested );
        end
        if needsRefresh
            m = refresh(m, variantRequested);
        end
    end
    % Run chksstate only if steady state recomputed.
    if runSteady && runCheckSteady
        [~, ~, ~, sstateErrList] = implementCheckSteady( this, ...
                                                         variantRequested, ...
                                                         update.CheckSteady );
        sstateErrList = sstateErrList{1};
        okCheckSteady = isempty(sstateErrList);
    end
    if okSteady && okCheckSteady && runSolve
        [ this, ...
          numStablePaths, ...
          nanDerv, ...
          sing2, ...
          bk                    ] = solveFirstOrder( this, ...
                                                     variantRequested, ...
                                                     update.Solve );
    else
        numStablePaths = 1;
    end
end

ok = numStablePaths==1 && okSteady && okCheckSteady;
if ok
    return
end

if strcmpi(update.NoSolution, 'Error')
    % Throw error, give access to the failed model object and terminate
    m = this(variantRequested);
    model.failed( m, okSteady, okCheckSteady, sstateErrList, ...
                  numStablePaths, nanDerv, sing2, bk );
end

end%

