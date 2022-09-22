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

