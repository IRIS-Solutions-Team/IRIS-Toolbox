function [data, names, dates] = extractSeriesData(inputDb, names, dates) 

    if isa(names, 'function_handle')
        names = databank.filterFields(inputDb, 'name', names, 'class', 'Series');
    end
    names = reshape(string(names), 1, [ ]);

    allSeries = cell(size(names));
    if isa(inputDb, 'Dictionary')
        for i = 1 : numel(names)
            allSeries{i} = retrieve(inputDb, names(i));
        end
    else
        for i = 1 : numel(names)
            allSeries{i} = inputDb.(names(i));
        end
    end

    here_checkTimeSeries();

    data = cell(size(allSeries));
    context = '';
    [dates, data{:}] = getDataFromMultiple(dates, context, allSeries{:});
    dates = reshape(double(dates), 1, []);

return

    function here_checkTimeSeries()
        %(
        inxValid = true(size(names));
        for i = 1 : numel(allSeries)
            inxValid(i) = isa(allSeries{i}, 'Series');
        end
        if any(~inxValid)
            exception.error([
                "Databank:NotTimeSeries"
                "This databank field is not a time series: %s"
            ], names(~inxValid));
        end
        %)
    end%
end%


function value = local_mustBeSeries(value, name)
    %(
    if isa(value, 'Series')
        return
    end
    exception.error([
        "Databank:ExtractSeries"
        "This databank field is not a time series: %s"
    ], name);
    %)
end%

