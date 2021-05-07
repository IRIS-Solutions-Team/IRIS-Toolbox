% toArray  Collect time series data into plain numeric array

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

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

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser("databank.toArray");
    addRequired(inputParser, "inputDb", @(x) validate.databank(x) && isscalar(x)); 
    addOptional(inputParser, "names", @all, @locallyValidateNames);
    addOptional(inputParser, "dates", @all, @DateWrapper.validateProperRangeInput);
    addOptional(inputParser, "columns", 1, @(x) isnumeric(x) && all(x(:)==round(x(:))) && all(x(:)>=1));
end
parse(inputParser, inputDb, varargin{:});
names =  inputParser.Results.names;
dates = inputParser.Results.dates;
columns = inputParser.Results.columns;
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

