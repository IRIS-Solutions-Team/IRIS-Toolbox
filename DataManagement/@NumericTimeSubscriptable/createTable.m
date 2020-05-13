function outputTable = createTable(startDate, data, comments)

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
endDate = DateWrapper.roundPlus(startDate, numRows-1);
range = DateWrapper.roundColon(startDate, endDate);
dates = DateWrapper.toDefaultString(range) + ":";
dates = reshape(string(dates), [ ], 1);
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

