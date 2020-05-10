function [x, last] = removeTrailingNaNs(x, dim)
% removeTrailingNaNs  Remove trailing NaNs along specified dimension

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

sizeX = size(x);
ndimsX = ndims(x);
anyValue = any(~isnan(x), [1:dim-1, dim+1:ndimsX]);
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

