function data = moving(data, window, varargin)
% moving  Implement moving function on numeric data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('numeric.moving');
    inputParser.addRequired('InputData', @isnumeric);
    inputParser.addRequired('Window', @(x) isnumeric(x) && all(x==round(x)));
    inputParser.addOptional('Function', @mean, @(x) isa(x, 'function_handle'));
end
inputParser.parse(data, window, varargin{:});
func = inputParser.Results.Function;

if isempty(window)
    data(:) = NaN;
    return
end

%--------------------------------------------------------------------------

sizeData = size(data);
ndimsData = ndims(data);
if ndimsData>2
    data = data(:, :);
end

for i = 1 : size(data, 2)
    ithData = data(:, i);
    shiftIthData = numeric.shift(data(:, i), window);
    data(:, i) = feval(func, shiftIthData, 2);
end

if ndimsData>2
    data = reshape(data, sizeData);
end

end
