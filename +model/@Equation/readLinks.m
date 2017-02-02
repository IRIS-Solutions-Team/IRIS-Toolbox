function [equation, link] = readLinks(equation, euc, quantity)
% readLinks  Read dynamic links.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;
PTR = @int16;

%--------------------------------------------------------------------------

ixl = equation.Type==TYPE(4);
nEqtn = numel(equation.Input);
link = model.Pairing.initLink(nEqtn);
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
    lsInvalid = equation.Input(ixl);
    lsInvalid = lsInvalid(~ixValid);
    throw( exception.Base('Equation:INVALID_LHS_LINK', 'error'), ...
        lsInvalid{:} );
end

equation.Dynamic(ixl) = euc.RhsDynamic(ixl);

nl = sum(ixl);
ptr = repmat(PTR(0), 1, nl);
ptr(ixValidName) = PTR( ell.PosName(ixValidName) );
ptr(ixValidStdCorr) = PTR( nQuan + ell.PosStdCorr(ixValidStdCorr) );
link.Lhs(ixl) = ptr;

end
