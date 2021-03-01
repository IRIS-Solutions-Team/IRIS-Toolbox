function [data, names, dates, dateTransform] = extractSeriesData(inputDb, names, dates) 

if isa(names, "function_handle")
    names = databank.filterFields(inputDb, "name", names, "class", "NumericTimeSubscriptable");
end
names = reshape(string(names), 1, [ ]);

if isa(inputDb, 'Dictionary')
    allSeries = arrayfun( ...
        @(n) locallyMustBeSeries(retrieve(inputDb, n), n), names ...
        , "uniformOutput", false ...
    );
else
    allSeries = arrayfun( ...
        @(n) locallyMustBeSeries(inputDb.(n), n), names ...
        , "uniformOutput", false ...
    );
end

[dates, dateTransform] = locallyResolveDates(dates);
data = cell(size(allSeries));
context = "";
[dates, data{:}] = getDataFromMultiple(dates, context, allSeries{:});
dates = reshape(double(dates), 1, []);

end%

%
% Local Functions
%

function [dates, dateTransform] = locallyResolveDates(dates)
    dateTransform = [ ];
    if isstring(dates)
        if startsWith(dates, "head", "ignoreCase", true)
            dateTransform = @head;
            dates = "unbalanced";
        elseif startsWith(dates, "tail", "ignoreCase", true)
            dateTransform = @tail;
            dates = "unbalanced";
        end
    end
end%

%
% Local Validators
%

function value = locallyMustBeSeries(value, name)
    if isa(value, "NumericTimeSubscriptable")
        return
    end
    exception.error([
        "Databank:ExtractSeries"
        "This databank field is not a time series: %s"
    ], name);
end%

