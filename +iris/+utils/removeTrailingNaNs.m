function [x, last] = removeTrailingNaNs(x, dim)

    sizeX = size(x);
    ndimsX = ndims(x);
    try
        anyValue = any(~isnan(x), [1:dim-1, dim+1:ndimsX]);
    catch
        anyValue = ~isnan(x);
        anyValue = permute(anyValue, [dim, 1:dim-1, dim+1:ndimsX]);
        anyValue = any(~isnan(anyValue(:, :)), 2);
        anyValue = ipermute(anyValue, [dim, 1:dim-1, dim+1:ndimsX]);
    end
    last = find(anyValue, 1, 'last');
    if isempty(last)
        sizeX(dim) = 0;
        x = nan(sizeX, 'like', x);
        last = 0;
        return
    end
    ref = repmat({':'}, 1, ndimsX);
    ref{dim} = 1:last;
    x = x(ref{:});

end%

