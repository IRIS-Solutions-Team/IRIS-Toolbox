function [eqn, lnk] = readLinks(eqn, euc, quantity)
% readLinks  Read dynamic lnks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;
PTR = @int16;

%--------------------------------------------------------------------------

ixl = eqn.Type==TYPE(4);
nEqtn = numel(eqn.Input);
lnk = model.component.Link( );
if ~any(ixl)
    return
end

nQuan = length(quantity.Name);
lsLhsName = euc.LhsDynamic(ixl);
ell = lookup(quantity, lsLhsName);
ixValidName = ~isnan(ell.PosName);
ixValidStdCorr = ~isnan(ell.PosStdCorr);
ixValid = ixValidName | ixValidStdCorr;
if any(~ixValid)
    lsInvalid = eqn.Input(ixl);
    lsInvalid = lsInvalid(~ixValid);
    throw( exception.Base('Equation:INVALID_LHS_LINK', 'error'), ...
        lsInvalid{:} );
end

eqn.Dynamic(ixl) = euc.RhsDynamic(ixl);

nl = sum(ixl);
ptr = repmat(PTR(0), 1, nl);
ptr(ixValidName) = PTR( ell.PosName(ixValidName) );
ptr(ixValidStdCorr) = PTR( nQuan + ell.PosStdCorr(ixValidStdCorr) );
lnk.LhsPtr = ptr;
lnk.Order = PTR(1:nl);

end
