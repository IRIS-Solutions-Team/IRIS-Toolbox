function data = moving(data, window, func)
% moving  Implement moving function on numeric data
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if isempty(window)
    data(:) = NaN;
    return
end

if nargin<3
    func = @mean;
end

%--------------------------------------------------------------------------

sizeData = size(data);
ndimsData = ndims(data);
if ndimsData>2
    data = data(:, :);
end

for i = 1 : size(data, 2)
    ithData = data(:, i);
    shiftIthData = apply.shift(data(:, i), window);
    data(:, i) = feval(func, shiftIthData, 2);
end

if ndimsData>2
    data = reshape(data, sizeData)
end

end
