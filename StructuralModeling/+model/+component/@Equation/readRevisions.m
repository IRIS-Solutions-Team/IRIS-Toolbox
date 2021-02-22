function [eqn, pai] = readRevisions(eqn, euc, qty)
% readRevisions  Read steady-state revision equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

TYPE = @int8;
PTR = @int16;

%--------------------------------------------------------------------------

ixu = eqn.Type==TYPE(5);
nEqn = numel(eqn.Input);
pai = model.component.Pairing.initRevision(nEqn);
if ~any(ixu)
    return
end

% LHS must be a valid parameter name (but not a std or corr name) followed
% by {+1} or {1}.
nameLhs = regexp(euc.LhsDynamic(ixu), '^[a-zA-Z]\w*(?=\{@\+1\}$)', 'match', 'once');
ell = lookup(qty, nameLhs, TYPE(4));
ixValid = ~isnan(ell.PosName);
if any(~ixValid)
    lsInvalid = eqn.Input(ixu);
    lsInvalid = lsInvalid(~ixValid);
    throw( ...
        exception.Base('Equation:INVALID_LHS_REVISION', 'error'), ...
        lsInvalid{:} ...
        );
end

eqn.Dynamic(ixu) = euc.RhsDynamic(ixu);
pai(ixu) = PTR( ell.PosName );

end
