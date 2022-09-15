
function outputTable = createTable(startDate, data, comments, headers, padDates)

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

    printHeaders = compose("%g", 1:numColumns);
    if isstring(headers) && size(headers, 2)==numColumns
        printHeaders = printHeaders + ":" + headers(1, :);
    end

    outputTable = table( ...
        dataColumns{:} ...
        , 'RowNames', dates ...
        , 'VariableNames', printHeaders(1, :) ...
    );

    if nargin>=3
        outputTable.Properties.VariableDescriptions = string(comments);
    end

end%

