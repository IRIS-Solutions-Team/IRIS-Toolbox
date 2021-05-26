function code = table(inputTable, fileName, varargin)

NUMERIC_FORMAT = '$%.2f$';
NAN_STRING = '--';
INF_STRING = '$\infty$';
MINUS_INF_STRING = '$-\infty$';

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('latex.table');
    INPUT_PARSER.addRequired('Table', @(x) isa(x, 'table'));
    INPUT_PARSER.addRequired('FileName', @(x) isempty(x) || ischar(x) || isa(x, 'string'));
    INPUT_PARSER.addParameter('ArrayStretch', 1.5, @(x) isnumeric(x) && isscalar(x) && x>=0);
    INPUT_PARSER.addParameter('RowNamesTypeFace', '', @(x) ischar(x) || isa(x, 'string'));
    INPUT_PARSER.addParameter('ColumnNamesTypeFace', '', @(x) ischar(x) || isa(x, 'string'));
    INPUT_PARSER.addParameter('ColumnWidth', '', @(x) ischar(x) || isa(x, 'string'));
end
INPUT_PARSER.parse(inputTable, fileName, varargin{:});
opt = INPUT_PARSER.Options;

%--------------------------------------------------------------------------

cellTable = table2cell(inputTable);
[numRows, numColumns] = size(cellTable);
rowNames = inputTable.Properties.RowNames;
columnNames = inputTable.Properties.VariableNames;
columnNames = strrep(columnNames, '_', '\_');

spec = repmat('r', 1, numColumns);
indexNumeric = cellfun(@isnumeric, cellTable(1, :));
spec(~indexNumeric) = 'l';

code = '';
code = [code, '\begingroup', newline];
%code = [code, '\small', newline];
code = [code, '\renewcommand{\arraystretch}', sprintf('{%g}', opt.ArrayStretch), newline];
code = [code, '\begin{tabular}{l', spec, '}', newline];
code = [code, '\hline', newline];
for i = 1 : numColumns
    ithColumnName = columnNames{i};
    if ~isempty(opt.ColumnNamesTypeFace)
        ithColumnName = [opt.ColumnNamesTypeFace, '{', ithColumnName, '}'];
    end
    if ~isempty(opt.ColumnWidth)
        ithColumnName = ['\makebox[', opt.ColumnWidth, '][r]{', ithColumnName, '}'];
    end
    code = [code, '& ', ithColumnName, ' '];
end
code = [code, '\\', newline, '\hline', newline];
for row = 1 : numRows
    ithRowName = rowNames{row};
    if opt.RowNamesTypeFace
        ithRowName = [opt.RowNamesTypeFace, '{', ithRowName, '}'];
    end
    code = [code, ithRowName];
    for col = 1 : numColumns
        value = cellTable{row, col};
        if isnumeric(value)
            if isequaln(value, NaN)
                string = NAN_STRING;
            elseif isequal(value, Inf)
                string = INF_STRING;
            elseif isequal(value, -Inf);
                string = MINUS_INF_STRING;
            else
                string = sprintf(NUMERIC_FORMAT, value);
            end
        else
            string = char(value);
        end
        code = [code, '& ', string, ' '];
    end
    code = [code, '\\', newline];
end
code = [code, '\hline', newline];
code = [code, '\end{tabular}', newline];
code = [code, '\endgroup', newline];

if ~isempty(fileName)
    textual.write(code, fileName);
end

end
