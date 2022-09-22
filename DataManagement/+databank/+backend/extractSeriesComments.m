
function comments = extractSeriesComments(inputDb, names)

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

    comments = cell(size(allSeries));
    for i = 1 : numel(comments)
        comments{i} = getComments(allSeries{i});
    end

    return

    function here_checkTimeSeries()
        %(
        inxValid = true(size(names));
        for i = 1 : numel(allSeries)
            inxValid(i) = isa(allSeries{i}, 'Series');
        end
        if any(~inxValid)
            exception.error([
                "Databank"
                "This databank field is not a time series: %s"
            ], names(~inxValid));
        end
        %)
    end%
end%

