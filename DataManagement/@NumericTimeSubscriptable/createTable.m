% createTable  Create table from Series object

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function outputTable = createTable(startDate, data, comments, padDates)

try, padDates; catch, padDates = false; end

%--------------------------------------------------------------------------

if ndims(data)>2
    thisError = [
        "Series:CannotCreateTable"
        "Cannot create table for three- or higher-dimensional time series."
    ];
    throw(exception.Base(thisError, 'error'));
end

numColumns = size(data, 2);
numRows = size(data, 1);
startDate = double(startDate);
endDate = dater.plus(startDate, numRows-1);
range = dater.colon(startDate, endDate);
dates = dater.toDefaultString(range) + ":";
dates = reshape(string(dates), [ ], 1);
if padDates
    dates = pad(dates, "left", char(160));
end
dataColumns = mat2cell(data, numRows, ones(1, numColumns));
outputTable = table( ...
    dataColumns{:} ...
    , 'RowNames', dates ...
    , 'VariableNames', compose('%g', 1:numColumns) ...
);

if nargin>=3
    outputTable.Properties.VariableDescriptions = string(comments);
end

end%

