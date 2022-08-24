function this = reorder(this, opt)
% reorder  Reset ordering of links and reorder sequentially if requested
%
% Beckend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

PTR = @int16;

numLinks = numel(this.Input);

% Reset ordering of links
this.Order = PTR(1:numLinks);
if ~opt.OrderLinks
    return
end

numLinks = numel(this);
ptr = abs(this.LhsPtr);

eps = model.Incidence.getIncidenceEps(this.RhsExpn);
inc = false(numLinks);
for i = 1 : numLinks
    inxPtr = eps(2, :)==ptr(i);
    inc(eps(1, inxPtr), i) = true;
end

if nnz(inc)==0
    % No need to reorder
    return
end

for i = 1 : numLinks
    inc(i, i) = true;
end

[ordInc, ordEqn, ordQty] = solver.blazer.Blazer.reorder(inc, 1:numLinks, ptr);
blk = solver.blazer.Blazer.getBlocks(ordInc, ordEqn, ordQty);
if any(cellfun('length', blk)>1)
    throw(exception.Base('Link:LinksNotSequential', 'warning'));
end

this.Order = PTR(fliplr(ordEqn));

end%

