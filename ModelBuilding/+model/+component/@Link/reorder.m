function this = reorder(this, opt)
% reorder  Reset ordering of links and reorder sequentially if requested.
%
% Beckend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

TYPE = @int8;
PTR = @int16;
nl = length(this.Input);

% Reset ordering of links.
this.Order = PTR(1:nl);
if ~opt.OrderLinks
    return
end

nl = length(this);
ptr = abs(this.LhsPtr);

eps = model.component.Incidence.getIncidenceEps(this.RhsExpn);
inc = false(nl);
for i = 1 : nl
    ixPtr = eps(2, :)==ptr(i);
    inc(eps(1, ixPtr), i) = true;
end

if nnz(inc)==0
    % No need to reorder.
    return
end

for i = 1 : nl
    inc(i, i) = true;
end

[ordInc, ordEqn, ordQty] = solver.blazer.Blazer.reorder(inc, 1:nl, ptr);
blk = solver.blazer.Blazer.getBlocks(ordInc, ordEqn, ordQty);
if any( cellfun(@length, blk)>1 )
    throw( ...
        exception.Base('Link:LinksNotSequential', 'warning') ...
        );
end

this.Order = PTR( fliplr(ordEqn) );

end
