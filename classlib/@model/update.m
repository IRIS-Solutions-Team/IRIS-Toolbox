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

% Update regular parameters and run refresh if needed.
needsRefresh = any( this.Pairing.Link.Lhs>PTR(0) );
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
if all(ixNanQty) && ~isa(opt.sstate, 'function_handle') && ~beenRefreshed
    ok = true;
    return
end

if this.IsLinear
    % Linear models
    %---------------
    if ~isequal(opt.solve,false)
        [this,nPth,nanDerv,sing2] = solveFirstOrder(this, iAlt, opt.solve);
    else
        nPth = 1;
    end
    if isstruct(opt.sstate)
        this = steadyLinear(this, iAlt, opt);
        if needsRefresh
            this = refresh(this, iAlt);
        end
    end
    sstateOk = true;
    chkSstateOk = true;
	sstateErrList = { };
else
    % Non-linear models
    %-------------------
    sstateOk = true;
    sstateErrList = { };
    chkSstateOk = true;
    nanDerv = [ ];
    sing2 = false;
    if isstruct(opt.sstate)
        % Call to the IRIS sstate solver.
        [this,sstateOk] = mysstatenonlin(this, iAlt, opt.sstate);
        if needsRefresh
            this = refresh(this, iAlt);
        end
    elseif isa(opt.sstate, 'function_handle')
        % Call to a user-supplied sstate solver.
        m = this(iAlt);
        [m,sstateOk] = opt.sstate(m);
        if needsRefresh
            m = refresh(m);
        end
        this(iAlt) = m;
    elseif iscell(opt.sstate) && isa(opt.sstate{1}, 'function_handle')
        % Call to a user-supplied sstate solver with extra arguments.
        m = this(iAlt);
        [m,sstateOk] = feval(opt.sstate{1}, m, opt.sstate{2:end});
        if needsRefresh
            m = refresh(m);
        end  
        this(iAlt) = m;
    end
    % Run chksstate only if steady state recomputed.
    if ~isequal(opt.sstate,false) && isstruct(opt.chksstate)
        [~,~,~,sstateErrList] = mychksstate(this, iAlt, opt.chksstate);
        sstateErrList = sstateErrList{1};
        chkSstateOk = isempty(sstateErrList);
    end
    if sstateOk && chkSstateOk && ~isequal(opt.solve,false)
        [this, nPth, nanDerv, sing2] = solveFirstOrder(this, iAlt, opt.solve);
    else
        nPth = 1;
    end
end

ok = nPth==1 && sstateOk && chkSstateOk;

if ~isError
    return
end

if ~ok
    % Throw error and give access to the failed model object
    %--------------------------------------------------------
    m = this(iAlt);
    model.failed(m,sstateOk, chkSstateOk, sstateErrList, ...
        nPth, nanDerv, sing2);
end

end
