% moving  Implement moving function on numeric data
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function data = moving(data, window, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('numeric.moving');
    addRequired(pp, 'InputData', @isnumeric);
    addRequired(pp, 'Window', @(x) isnumeric(x) && all(x==round(x)));
    addOptional(pp, 'Function', @mean, @(x) isa(x, 'function_handle'));
end
parse(pp, data, window, varargin{:});
func = pp.Results.Function;

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
    data(:, i) = feval(func, numeric.shift(data(:, i), window), 2);
end

if ndimsData>2
    data = reshape(data, sizeData);
end

end%

