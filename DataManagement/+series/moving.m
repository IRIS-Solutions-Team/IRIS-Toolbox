% moving  Implement moving function on numeric data
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

% >=R2019b
%(
function data = moving(data, window, func)

arguments
    data {mustBeNumeric}
    window (1, :) {mustBeInteger}
    func {mustBeA(func, "function_handle")} = @mean
end
%)
% >=R2019b

% <=R2019a
%{
function data = moving(data, window, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('series/moving');
    addRequired(pp, 'inputData', @isnumeric);
    addRequired(pp, 'window', @(x) isnumeric(x) && all(x==round(x)));
    addOptional(pp, 'function', @mean, @(x) isa(x, 'function_handle'));
end
parse(pp, data, window, varargin{:});
func = pp.Results.function;
%}
% <=R2019a

if isempty(window)
    data(:) = NaN;
    return
end

%--------------------------------------------------------------------------

sizeData = size(data);
numColumns = prod(sizeData(2:end));
for i = 1 : numColumns
    shiftedData = numeric.shift(data(:, i), window);
    data(:, i) = feval(func, shiftedData, 2);
end

end%

