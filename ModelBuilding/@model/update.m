function [this, ok] = update(this, p, variantRequested, opt, isError)
% update  Update parameters, sstate, solve, and refresh.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

PTR = @int16;

% `IsError`: Throw error if update fails.
try
    isError; %#ok<VUNUS>
catch %#ok<CTCH>
    isError = true;
end

%--------------------------------------------------------------------------

posValues = this.TaskSpecific.Update.PosValues;
posStdCorr = this.TaskSpecific.Update.PosStdCorr;

ixNanQty = isnan(posValues);
posValues = posValues(~ixNanQty);
ixNanStdCorr = isnan(posStdCorr);
posStdCorr = posStdCorr(~ixNanStdCorr);

% Reset parameters and stdcorrs.
this.Variant.Values(:, :, variantRequested) = this.TaskSpecific.Update.Values;
this.Variant.StdCorr(:, :, variantRequested) = this.TaskSpecific.Update.StdCorr;

runSteady = ~isequal(opt.Steady, false);
runSolve = ~isequal(opt.Solve, false);
runChksstate = ~isequal(opt.ChkSstate, false);

% Update regular parameters and run refresh if needed.
needsRefresh = any(this.Link);
beenRefreshed = false;
if any(~ixNanQty)
    this.Variant.Values(:, posValues, variantRequested) = p(~ixNanQty);
end

% Update stds and corrs.
if any(~ixNanStdCorr)
    this.Variant.StdCorr(:, posStdCorr, variantRequested) = p(~ixNanStdCorr);
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
if all(ixNanQty) && ~isa(opt.Steady, 'function_handle') && ~beenRefreshed
    ok = true;
    return
end

if this.IsLinear
    % __Linear Models__
    if runSolve
        [this, nPth, nanDerv, sing2, bk] = solveFirstOrder(this, variantRequested, opt.Solve);
    else
        nPth = 1;
    end
    if runSteady
        this = steadyLinear(this, opt.Steady, variantRequested);
        if needsRefresh
            this = refresh(this, variantRequested);
        end
    end
    okSteady = true;
    okChkSteady = true;
	sstateErrList = { };
else
    % __Nonlinear Models__
    okSteady = true;
    sstateErrList = { };
    okChkSteady = true;
    nanDerv = [ ];
    sing2 = false;
    if runSteady
        if isa(opt.Steady, 'function_handle')
            % Call to a user-supplied sstate solver.
            m = this(variantRequested);
            [m, okSteady] = feval(opt.Steady, m);
            this(variantRequested) = m;
        elseif iscell(opt.Steady) && isa(opt.Steady{1}, 'function_handle')
            %  Call to a user-supplied sstate solver with extra arguments.
            m = this(variantRequested);
            [m, okSteady] = feval(opt.Steady{1}, m, opt.Steady{2:end});
            this(variantRequested) = m;
        else
             % Call to the IRIS sstate solver.
            [this, okSteady] = steadyNonlinear(this, opt.Steady, variantRequested);
        end
        if needsRefresh
            m = refresh(m, variantRequested);
        end
    end
    % Run chksstate only if steady state recomputed.
    if runSteady && runChksstate
        [~, ~, ~, sstateErrList] = mychksstate(this, variantRequested, opt.ChkSstate);
        sstateErrList = sstateErrList{1};
        okChkSteady = isempty(sstateErrList);
    end
    if okSteady && okChkSteady && runSolve
        [this, nPth, nanDerv, sing2, bk] = solveFirstOrder(this, variantRequested, opt.Solve);
    else
        nPth = 1;
    end
end

ok = nPth==1 && okSteady && okChkSteady;

if ~isError
    return
end

if ~ok
    % Throw error and give access to the failed model object.
    m = this(variantRequested);
    model.failed( ...
        m, okSteady, okChkSteady, sstateErrList, ...
        nPth, nanDerv, sing2, bk ...
    );
end

end
