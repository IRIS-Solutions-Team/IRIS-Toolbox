function [this, ok] = update(this, p, variantRequested)
% update  Update parameters, sstate, solve, and refresh
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

if nargin<3
    variantRequested = 1;
end

%--------------------------------------------------------------------------

posOfValues = this.Update.PosOfValues;
posOfStdCorr = this.Update.PosOfStdCorr;

indexOfValues = ~isnan(posOfValues);
posOfValues = posOfValues(indexOfValues);
indexOfStdCorr = ~isnan(posOfStdCorr);
posOfStdCorr = posOfStdCorr(indexOfStdCorr);

% Reset parameters and stdcorrs.
this.Variant.Values(:, :, variantRequested) = this.Update.Values;
this.Variant.StdCorr(:, :, variantRequested) = this.Update.StdCorr;

runSteady = ~isequal(this.Update.Steady, false);
runSolve = ~isequal(this.Update.Solve, false);
runCheckSteady = ~isequal(this.Update.CheckSteady, false);

% Update regular parameters and run refresh if needed.
needsRefresh = any(this.Link);
beenRefreshed = false;
if any(indexOfValues)
    this.Variant.Values(:, posOfValues, variantRequested) = p(indexOfValues);
end

% Update stds and corrs.
if any(indexOfStdCorr)
    this.Variant.StdCorr(:, posOfStdCorr, variantRequested) = p(indexOfStdCorr);
end

% Refresh dynamic links. The links can refer/define std devs and
% cross-corrs.
if needsRefresh
    this = refresh(this, variantRequested);
    beenRefreshed = true;
end

% If only stds or corrs have been changed, no values have been
% refreshed, and no user preprocessor is called, return immediately as
% there is no need to re-solve or re-sstate the model.
if ~any(indexOfValues) && ~isa(this.Update.Steady, 'function_handle') && ~beenRefreshed
    ok = true;
    return
end

if this.IsLinear
    % __Linear Models__
    if runSolve
        [this, numOfStablePaths, nanDerv, sing2, bk] = solveFirstOrder( this, ...
                                                                        variantRequested, ...
                                                                        this.Update.Solve );
    else
        numOfStablePaths = 1;
    end
    if runSteady
        this = steadyLinear(this, this.Update.Steady, variantRequested);
        if needsRefresh
            this = refresh(this, variantRequested);
        end
    end
    okSteady = true;
    okCheckSteady = true;
	sstateErrList = { };
else
    % __Nonlinear Models__
    okSteady = true;
    sstateErrList = { };
    okCheckSteady = true;
    nanDerv = [ ];
    sing2 = false;
    if runSteady
        if isa(this.Update.Steady, 'function_handle')
            % Call to a user-supplied sstate solver.
            m = this(variantRequested);
            [m, okSteady] = feval(this.Update.Steady, m);
            this(variantRequested) = m;
        elseif iscell(this.Update.Steady) && isa(this.Update.Steady{1}, 'function_handle')
            %  Call to a user-supplied sstate solver with extra arguments.
            m = this(variantRequested);
            [m, okSteady] = feval(this.Update.Steady{1}, m, this.Update.Steady{2:end});
            this(variantRequested) = m;
        else
             % Call to the IRIS sstate solver.
            [this, okSteady] = steadyNonlinear(this, this.Update.Steady, variantRequested);
        end
        if needsRefresh
            m = refresh(m, variantRequested);
        end
    end
    % Run chksstate only if steady state recomputed.
    if runSteady && runCheckSteady
        [~, ~, ~, sstateErrList] = mychksstate(this, variantRequested, this.Update.CheckSteady);
        sstateErrList = sstateErrList{1};
        okCheckSteady = isempty(sstateErrList);
    end
    if okSteady && okCheckSteady && runSolve
        [this, numOfStablePaths, nanDerv, sing2, bk] = solveFirstOrder( this, ...
                                                            variantRequested, ...
                                                            this.Update.Solve );
    else
        numOfStablePaths = 1;
    end
end

ok = numOfStablePaths==1 && okSteady && okCheckSteady;

if ~this.Update.ThrowError
    return
end

if ~ok
    % Throw error and give access to the failed model object.
    m = this(variantRequested);
    model.failed( m, okSteady, okCheckSteady, sstateErrList, ...
                  numOfStablePaths, nanDerv, sing2, bk );
end

end
