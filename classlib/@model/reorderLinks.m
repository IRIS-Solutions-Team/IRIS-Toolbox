function this = reorderLinks(this, opt)
% reorderLinks  Reset ordering of links and reorder sequentially if requested.
%
% Beckend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

TYPE = @int8;
PTR = @int16;
nEqn = length(this.Equation);
ixl = this.Equation.Type==TYPE(4);
posl = find(ixl);

% Reset ordering of links.
this.Pairing.Link.Order = find(ixl);
if ~opt.OrderLinks
    return
end

nl = sum(ixl);
ptr = this.Pairing.Link.Lhs(ixl);

eps = model.Incidence.getIncidenceEps(this.Equation.Dynamic, ixl);
inc = false(nl);
for i = 1 : nl
    ixPtr = eps(2, :)==ptr(i);
    ixEqn = false(1, nEqn);
    ixEqn(eps(1, ixPtr)) = true;
    ixEqn = ixEqn(ixl);
    inc(ixEqn, i) = true;
end

if nnz(inc)==0
    % No need to reorder.
    return
end

for i = 1 : nl
    inc(i, i) = true;
end

[ordInc, ordEqn, ordQty] = solver.blazer.Blazer.reorder(inc, posl, ptr);
blk = solver.blazer.Blazer.getBlocks(ordInc, ordEqn, ordQty);
if any( cellfun(@length, blk)>1 )
    throw( ...
        exception.Base('Model:LinksNotSequential', 'warning') ...
        );
end

ordEqn = fliplr(ordEqn);
this.Pairing.Link.Order = PTR(ordEqn);

end
