function c = matrix(fileName, inputMatrix, varargin)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('latex.matrix');
    INPUT_PARSER.addRequired('FileName', @(x) isempty(x) || ischar(x) || isa(x, 'string'));
    INPUT_PARSER.addRequired('InputMatrix', @(x) isnumeric(x) && ismatrix(x));
    INPUT_PARSER.addParameter('RowNames', cell.empty(1, 0), @(x) iscellstr(x) || isa(x, 'string'));
    INPUT_PARSER.addParameter('ColumnNames', cell.empty(1, 0), @(x) iscellstr(x) || isa(x, 'string'));
    INPUT_PARSER.addParameter('Format', '%.2f', @(x) (ischar(x) || isa(x, 'string')) && startsWith(x, '%'));
    INPUT_PARSER.addParameter('ColumnWidth', '', @(x) ischar(x) || isa(x, 'string'));
    INPUT_PARSER.addParameter('VerboseRowNames', true, @(x) isequal(x, true) || isequal(x, false));
    INPUT_PARSER.addParameter('VerboseColumnNames', true, @(x) isequal(x, true) || isequal(x, false));
end
INPUT_PARSER.parse(fileName, inputMatrix, varargin{:});
opt = INPUT_PARSER.Options;

opt.RowNames = cellstr(opt.RowNames);
opt.ColumnNames = cellstr(opt.ColumnNames);
opt.ColumnWidth = char(opt.ColumnWidth);

isRowNames = ~isempty(opt.RowNames);
isColumnNames = ~isempty(opt.ColumnNames);
isColumnWidth = ~isempty(opt.ColumnWidth);
[numOfRows, numOfColumns] = size(inputMatrix);

if isRowNames && opt.VerboseRowNames
    opt.RowNames = strcat('\verb`', opt.RowNames, '`');
end
if isColumnNames && opt.VerboseColumnNames
    opt.ColumnNames = strcat('\verb`', opt.ColumnNames, '`');
end

columnSpec = repmat('r', 1, numOfColumns);
if isRowNames
    columnSpec = ['l', columnSpec];
end
c = ['\begin{tabular}{', columnSpec, '}', newline];

if isColumnNames
    c = [c, sprintf(' & %s', opt.ColumnNames{1:min(end, numOfColumns)}), ' \\', newline];
end

rowFormat = ['$', opt.Format, '$'];
if isColumnWidth
    rowFormat = ['\\makebox[', opt.ColumnWidth, '][r]{', rowFormat, '}'];
end
rowFormat = repmat([' & ', rowFormat], 1, numOfColumns);
if ~isRowNames
    rowFormat(1:3) = '';
end
for i = 1 : numOfRows
    if isRowNames
        c = [c, opt.RowNames{i}];
    end
    c = [c, sprintf(rowFormat, inputMatrix(i, :)), ' \\', newline];
end

c = [c, '\end{tabular}'];

if ~isempty(fileName)
    textual.write(c, fileName);
end

end
