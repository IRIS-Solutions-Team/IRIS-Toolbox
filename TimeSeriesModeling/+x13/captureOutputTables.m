function outputSeries = captureOutputTables(outputFiles, outputTables, flipSign, freq)

template = Series.template( );

numOutputTables = numel(outputTables);
outputSeries = cell(1, numOutputTables);
for i = 1 : numOutputTables
    tableExtension = extractAfter(outputTables(i), "_");
    series = [ ];
    try
        table = string(outputFiles.(tableExtension));
        table = splitlines(table);
        table = join(table(3:end), newline);
        table = eval("[" + table + "]");
        if ~isempty(table)
            startYear = floor(table(1)/100);
            if freq>1
                startPeriod = table(1) - 100*startYear;
            else
                startPeriod = 1;
            end
            start = dater.new(freq, startYear, startPeriod);
            series = fill(template, flipSign*table(:, 2), start);
        end
    end
    if isempty(series)
        series = template;
    end
    outputSeries{i} = series;
end

end%

