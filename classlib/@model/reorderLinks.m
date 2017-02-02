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

% Reset ordering of links.
this.Pairing.Link.Order = repmat(PTR(0), 1, nEqn);
if ~opt.OrderLinks
    return
end

ixl = this.Equation.Type==TYPE(4);
nl = sum(ixl);
ptr = this.Pairing.Link.Lhs(ixl);
nPtr = length(ptr);

eps = model.Incidence.getIncidenceEps(this.Equation.Dynamic, ixl);
inc = false(nl, nPtr);
for i = 1 : nPtr
    ix = eps(1, :)==ptr(i);
    inc(eps(2, ix), i) = true;
end

if nnz(inc)==0
    % No need to reorder.
    return
end

for i = 1 : nPtr
    inc(i, i) = true;
end

[ordInc, ordEqn, ordQty] = solver.blazer.Blazer.reorder(inc, 1:nl, 1:nl);
blk = solver.blazer.Blazer.getBlocks(ordInc, ordEqn, ordQty);
if any( cellfun(@length, blk)>1 )
    throw( ...
        exception.Base('Model:LinksNotSequential', 'warning') ...
        );
end

ordEqn = fliplr(ordEqn);
this.Pairing.Link.Order(ixl) = PTR(ordEqn);

end
