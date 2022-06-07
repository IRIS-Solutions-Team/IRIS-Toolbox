function outputTable = table(this, varargin)

    data = double(this);

    if ~isempty(varargin)
        data = data(:, :, varargin{:});
    end

    columnNames = cellstr(this.ColumnNames);
    rowNames = cellstr(this.RowNames);

    try
        outputTable = array2table( ...
            data ...
            , "VariableNames", columnNames ...
            , "RowNames", rowNames ...
        );
    catch
        % Runs in old Matlab
        columnNames = local_replaceShifts(columnNames);
        rowNames = local_replaceShifts(rowNames);
        outputTable = array2table( ...
            data ...
            , "VariableNames", columnNames ...
            , "RowNames", rowNames ...
        );
    end

end%

%
% Local functions
%

function names = local_replaceShifts(names)
    %(
    names = regexprep(names, '{\-(\d+)}', '_Tminus$1');
    names = regexprep(names, '{\+?(\d+)}', '_Tplus$1');
    %)
end%
