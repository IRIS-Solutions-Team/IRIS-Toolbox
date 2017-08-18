function disp(this)

nTime = size(this.Data, 1);

[sizeString, emptyString, sizeData] = textual.printSize(this.Data);
ndimsData = numel(sizeData);
classString = class(this.Data);
freqString = this.FrequencyDisplayName;
fprintf( ...
    '  %s %sTimeSeries\n  Data: %s\n  Frequency: %s\n', ...
    sizeString, emptyString, classString, freqString ...
);

if isempty(emptyString)
    frequency = this.Frequency;
    if frequency==Frequency.INTEGER
        from = this.Start;
        to = this.End;
        timeColumn = toChar(this.Start : this.End);
        timeColumn = strcat(timeColumn, ':');
        timeColumn = strjust(timeColumn, 'right');
    else
        timeColumn = datetime(transpose(this.Start : this.End));
        timeColumn.Format = [timeColumn.Format, ':'];
    end
    nCol = sizeData(2);
    columnHeaders = cell(1, nCol);
    for i = 1 : nCol
        columnHeaders{i} = sprintf('C%g', i);
    end
    if ndimsData>2
        dispNd(timeColumn, this.Data, columnHeaders, this.ColumnNames);
    else
        disp2d(timeColumn, this.Data, columnHeaders, this.ColumnNames);
    end
else
    textual.looseLine( );
end

disp@mixedin.UserDataWrapper(this);

end




function disp2d(timeColumn, data, columnHeaders, columnNames)
[nTime, nCol] = size(data);
if iscell(data)
    tableData = cell(1, nCol);
    for iCol = 1 : nCol
        tableData{iCol} = data(:, iCol);
    end
else
    tableData = mat2cell(data, nTime, ones(1, nCol));
end
textual.looseLine( );
if isa(timeColumn, 'datetime')
    tt = timetable(timeColumn, tableData{:}, 'VariableNames', columnHeaders);
else
    tt = table( );
    tt.Time = timeColumn;
    tt = [tt, table(tableData{:}, 'VariableNames', columnHeaders')];
end
disp(tt);
dispColumnNames(columnNames);
end




function dispColumnNames(columnNames)
    ixEmpty = strlength(columnNames)==0;
    if any(~ixEmpty)
        posCol = find(~ixEmpty);
        nPlace = 2 + ceil(log10(max(posCol)));
        for iCol = find(~ixEmpty)
            disp("    " + sprintf('%*s: ', nPlace, sprintf('C%g', iCol)) + columnNames(iCol));
        end
        textual.looseLine( );
    end
end




function dispNd(timeColumn, data, columnHeaders, columnNames)
    sizeData = size(data);
    sz3 = sizeData(3:end);
    location = cell(1, numel(sz3));
    for i = 1 : prod(sz3)
        [location{:}] = ind2sub(sz3, i);
        textual.looseLine( );
        temp = sprintf(',%g', location{:});
        fprintf('(:,:%s) =\n', temp);
        disp2d(timeColumn, data(:, :, i), columnHeaders, columnNames(1, :, i));
    end
end
