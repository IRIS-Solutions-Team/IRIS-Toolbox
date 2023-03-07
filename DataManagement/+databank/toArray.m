%{
% 
% # `databank.toArray` ^^(+databank)^^
% 
% {== Create numeric array from time series data ==}
% 
% 
% ## Syntax
% 
%     [outputArray, names, dates] = databank.toArray(inputDb, names, dates, columns)
% 
% 
% ## Input arguments
% 
% __`inputDb`__ [ struct | Dictionary ]
% > 
% > Input databank from which the time series data will be retrieved and
% > converted to a numeric array.
% > 
% 
% __`names`__ [ string | `@all` ]
% > 
% > List of time series names whose data will be retrieved from the
% > `inputDb`; `names=@all` means all time series fields will be included.
% > 
% 
% __`dates`__ [ Dater | `"unbalanced"` | `"balanced"` ]
% > 
% > Dates for which the time series data will be retrieved; the date
% > frequency of the `dates` must be consistent with the date frequency of
% > all time series listed in `names`.
% > 
% > * `dates=Inf` is the same as `dates="unbalanced"`.
% > 
% > * `dates="unbalanced"` means the dates will be automatically determined
% >   to cover an unbalanced panel of data (the earliest available
% >   observation among all time series to the latest).
% > 
% > * `dates="balanced"` means the dates will automatically determined to
% >   cover a balanced panel of data (the earliest data at which data are
% >   available for all time series to the latest date at which data are
% >   available for all time series).
% > 
% 
% __`columns=1`__ [ numeric ]
% > 
% > Column or columns that will be retrieved from the time series data; if
% > multiple columns are specified, the data will be flattened in 2nd
% > dimension; `columns=1` if omitted.
% > 
% 
% ## Output arguments 
% 
% __`outputArray`__ [ numeric ]
% > 
% > Numeric array created from the time series data from the fields listed in
% > `names` and dates specified in `dates`.
% > 
% 
% __`names`__ [ string ]
% > 
% > The names of the time series included in the `outputArray`; useful when
% > the input argument `names=@all`.
% > 
% 
% __`dates`__ [ Dater ]
% > 
% > The dates for which the time series data were retrieved and included in
% > the `outputArray`; useful when the input argument `dates=Inf`.
% > 
% 
% ## Description
% 
% 
% ## Examples
% 
% 
%}
% --8<--


% >=R2019b
%{
function [outputArray, names, dates, headers, comments] = toArray(inputDb, names, dates, column)

arguments
    inputDb (1, 1) {validate.databank}

    names {local_validateNames} = @all
    dates {local_validateDates} = Inf


    % column  Vector of flat columns in 2nd and higher dimensions to
    % retrieve from the input time series; if column=0, all columns will
    % be retrieved or data with a single column expanded unless there is
    % inconsistency

    column (1, 1) double {mustBeNonnegative} = 1 
end
%}
% >=R2019b


% <=R2019a
%(
function [outputArray, names, dates, headers, comments] = toArray(inputDb, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addOptional(ip, "names", @all, @local_validateNames);
    addOptional(ip, "dates", @all, @local_validateDates);
    addOptional(ip, "column", 1, @isnumeric);
end
parse(ip, varargin{:});
names = ip.Results.names;
dates = ip.Results.dates;
column = ip.Results.column;
%)
% <=R2019a


% Legacy value
if isequal(dates, @all)
    dates = Inf;
end

%
% Extract data as a cell array of numeric arrays
%
[data, names, dates] = databank.backend.extractSeriesData(inputDb, names, dates);
comments = databank.backend.extractSeriesComments(inputDb, names);

%
% Extract requested column
%
numData = numel(data);
if isequal(column, Inf)
    numColumns = [];
    for i = 1 : numel(data)
        sizeData = size(data{i});
        numColumns(end+1) = prod(sizeData(2:end));
    end
    maxColumns = max(numColumns);
    inxValid = numColumns==1 | numColumns==maxColumns;
    if any(~inxValid)
        exception.error([
            "Databank"
            "Inconsistent numbers of columns in 2nd and higher dimensions "
            "in these time series: " + join(names(numColumns~=1), " ")
        ]);
    end
    if maxColumns>1 && any(numColumns==1)
        for i = find(numColumns==1)
            data{i} = repmat(data{i}, 1, maxColumns);
            comments{i} = repmat(comments{i}, 1, maxColumns);
        end
        for i = 1 : numData
            data{i} = reshape(data{i}, size(data{i}, 1), 1, []);
            comments{i} = reshape(comments{i}, 1, 1, []);
        end
    end
else
    for i = 1 : numData
        data{i} = data{i}(:, column);
        comments{i} = comments{i}(:, column);
    end
end

outputArray = [data{:}];
comments = [comments{:}];

headers = [];
for i = 1 : numel(data)
    size__ = size(data{i});
    size__(1) = 1;
    headers = [headers, repmat(names(i), size__)];
end

end%

%
% Local Validators
%

function flag = local_validateNames(x)
    %(
    flag = true;
    if isa(x, 'function_handle') || isstring(string(x))
        return
    end
    error("Input value must be an array of strings or a test function.");
    %)
end%


function flag = local_validateDates(x)
    %(
    flag = true;
    if isnumeric(x)
        return
    end
    if isequal(x, @all)
        return
    end
    if isstring(x) && ismember(x, ["balanced", "unbalanced"])
        return
    end
    error("Input value must be a date vector, an Inf range, or one of {""balanced"", ""unbalanced""}.");
    %)
end%

