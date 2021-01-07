% toArray  Retrieve data from time series into plain numeric array

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

% >=R2019b
%(
function [outputArray, names, dates] = toArray(inputDb, names, dates, columns)

arguments
    inputDb (1, 1) {validate.databank}
    names {locallyValidateNames} = @all
    dates {validate.properRange} = @all
    columns (1, :) {mustBeInteger, mustBePositive} = 1
end
%)
% >=R2019b

% <=R2019a
%{
function [outputArray, names, dates] = toArray(inputDb, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('+databank/toArray');
    addRequired(pp, 'inputDb', @(x) validate.databank(x) && isscalar(x)); 
    addOptional(pp, 'names', @locallyValidateNames);
    addOptional(pp, 'dates', @DateWrapper.validateProperRangeInput);
    addOptional(pp, 'columns', 1, @(x) isnumeric(x) && all(x(:)==round(x(:))) && all(x(:)>=1));
end
parse(pp, inputDb, varargin{:});
names =  pp.Results.names;
dates = pp.Results.dates;
columns = pp.Results.columns;
%}
% <=R2019a

%
% Extract data as a cell array of numeric arrays
%
[data, names, dates] = databank.backend.extractSeriesData(inputDb, names, dates);

%
% Extract requested columns
%
for i = 1 : numel(data)
    data{i} = data{i}(:, columns);
end

%
% Create numeric array
%
outputArray = [data{:}];

end%

%
% Local Validators
%

function flag = locallyValidateNames(x)
    %(
    if isa(x, 'function_handle') || isstring(string(x))
        flag = true;
        return
    end
    error("Input value must be an array of strings or a test function.");
    %)
end%

