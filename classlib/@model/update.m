function [this, ok] = update(this, p, itr, iAlt, opt, isError)
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

posQty = itr.PosQty;
posStdCorr = itr.PosStdCorr;

ixNanQty = isnan(posQty);
posQty = posQty(~ixNanQty);
ixNanStdCorr = isnan(posStdCorr);
posStdCorr = posStdCorr(~ixNanStdCorr);

% Reset parameters and stdcorrs.
this.Variant{iAlt}.Quantity(1, :) = itr.Quantity;
this.Variant{iAlt}.StdCorr(1, :) = itr.StdCorr;

runSteady = ~isequal(opt.Steady, false);
runSolve = ~isequal(opt.solve, false);
runChksstate = ~isequal(opt.chksstate, false);

% Update regular parameters and run refresh if needed.
needsRefresh = any(this.Link);
beenRefreshed = false;
if any(~ixNanQty)
    this.Variant{iAlt}.Quantity(1, posQty) = p(~ixNanQty);
end

% Update stds and corrs.
if any(~ixNanStdCorr)
    this.Variant{iAlt}.StdCorr(1, posStdCorr) = p(~ixNanStdCorr);
end

% Refresh dynamic links. The links can refer/define std devs and
% cross-corrs.
if needsRefresh
    this = refresh(this, iAlt);
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
    % Linear models
    %---------------
    if runSolve
        [this, nPth, nanDerv, sing2, bk] = solveFirstOrder(this, iAlt, opt.solve);
    else
        nPth = 1;
    end
    if runSteady
        this = steadyLinear(this, opt.Steady, iAlt);
        if needsRefresh
            this = refresh(this, iAlt);
        end
    end
    okSteady = true;
    okChkSteady = true;
	sstateErrList = { };
else
    % Non-linear models
    %-------------------
    okSteady = true;
    sstateErrList = { };
    okChkSteady = true;
    nanDerv = [ ];
    sing2 = false;
    if runSteady
        if isa(opt.Steady, 'function_handle')
            % Call to a user-supplied sstate solver.
            m = this(iAlt);
            [m, okSteady] = feval(opt.Steady, m);
            this(iAlt) = m;
        elseif iscell(opt.Steady) && isa(opt.Steady{1}, 'function_handle')
            %  Call to a user-supplied sstate solver with extra arguments.
            m = this(iAlt);
            [m, okSteady] = feval(opt.Steady{1}, m, opt.Steady{2:end});
            this(iAlt) = m;
        else
             % Call to the IRIS sstate solver.
            [this, okSteady] = steadyNonlinear(this, opt.Steady, iAlt);
        end
        if needsRefresh
            m = refresh(m, iAlt);
        end
    end
    % Run chksstate only if steady state recomputed.
    if runSteady && runChksstate
        [~, ~, ~, sstateErrList] = mychksstate(this, iAlt, opt.chksstate);
        sstateErrList = sstateErrList{1};
        okChkSteady = isempty(sstateErrList);
    end
    if okSteady && okChkSteady && runSolve
        [this, nPth, nanDerv, sing2, bk] = solveFirstOrder(this, iAlt, opt.solve);
    else
        nPth = 1;
    end
end

ok = nPth==1 && okSteady && okChkSteady;

if ~isError
    return
end

if ~ok
    % Throw error and give access to the failed model object
    %--------------------------------------------------------
    m = this(iAlt);
    model.failed(m, okSteady, okChkSteady, sstateErrList, ...
        nPth, nanDerv, sing2, bk);
end

end
