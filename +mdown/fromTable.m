
% >=R2019b
%{
function code = fromTable(t, opt)

arguments
    t table

    opt.NaN (1, :) string {mustBeScalarOrEmpty} = string.empty(1, 0)
    opt.Zero (1, :) string {mustBeScalarOrEmpty} = string.empty(1, 0)
    opt.RowNamesHeader (1, 1) string = "Name"
    opt.RowNamesPattern (1, 2) string = ["`", "`"]
    opt.NumericFormat (1, 1) string = "%g"
    opt.Round (1, 1) double = Inf
    opt.Title (1, :) string {mustBeScalarOrEmpty} = string.empty(1, 0)
    opt.SaveAs (1, :) string {mustBeScalarOrEmpty} = string.empty(1, 0)
    opt.AppendTo (1, :) string {mustBeScalarOrEmpty} = string.empty(1, 0)
end
%}
% >=R2019b


% <=R2019a
%(
function code = fromTable(t, opt)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "NaN", string.empty(1, 0));
    addParameter(ip, "Zero", string.empty(1, 0));
    addParameter(ip, "RowNamesHeader", "Name");
    addParameter(ip, "RowNamesPattern", ["`", "`"]);
    addParameter(ip, "NumericFormat", "%g");
    addParameter(ip, "Round", Inf);
    addParameter(ip, "Title", string.empty(1, 0));
    addParameter(ip, "SaveAs", string.empty(1, 0));
    addParameter(ip, "AppendTo", string.empty(1, 0));
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


s = table2struct(t, "toScalar", true);
columnNames = textual.stringify(t.Properties.VariableNames);

rowNames = textual.stringify(t.Properties.RowNames);
if ~isempty(rowNames)
    columnNames = [opt.RowNamesHeader, columnNames];
    rowNames = opt.RowNamesPattern(1) + rowNames + opt.RowNamesPattern(2);
    s.(opt.RowNamesHeader) = reshape(rowNames, [], 1);
end

numColumns = numel(columnNames);
numRows = numel(s.(columnNames(1)));

%
% Convert all values to strings
%
p = struct();
for n = columnNames
    p.(n) = locallyStringify(s.(n), opt);
end


title = string(newline());
if ~isempty(opt.Title)
    title = title + join(opt.Title, newline);
elseif ~isempty(t.Properties.Description)
    title = title + join(textual.stringify(t.Properties.Description), newline());
end
title = title + newline() + newline();


header = "";
align = "";
for n = columnNames
    header = header + "| " + n + " ";
    align = align + "|";
    if isnumeric(s.(n)) || islogical(s.(n))
        align = align + "---:";
    else
        align = align + ":---";
    end
end
header = header + " |" + newline();
align = align + "|" + newline();
code = title + header + align;

for row = 1 : numRows
    for n = columnNames
        code = code + "| " + p.(n)(row) + " ";
    end
    code = code + "|" + newline();
end

code = code + newline();

if ~isempty(opt.SaveAs)
    textual.write(code, opt.SaveAs);
end

if ~isempty(opt.AppendTo)
    try
        existing = fileread(opt.AppendTo);
    catch
        existing = "";
    end
    textual.write(existing + code, opt.AppendTo);
end

end%

%
% Local functions
%

function output = locallyStringify(values, opt)
    %(
    if isstring(values)
        output = values;
    elseif islogical(values)
        output = repmat("", size(values));
        output(values) = "`true`";
        output(~values) = "`false`";
    elseif isnumeric(values)
        if ~isequal(opt.Round, Inf)
            values = round(values, opt.Round);
            values(values==0) = 0;
        end
        output = compose(opt.NumericFormat, values);
        if ~isempty(opt.NaN)
            nanString = sprintf(opt.NumericFormat, NaN);
            output = replace(output, nanString, opt.NaN);
        end
        if ~isempty(opt.Zero)
            zeroString = sprintf(opt.NumericFormat, 0);
            output = replace(output, zeroString, opt.Zero);
        end
    elseif iscellstr(values)
        output = string(values);
    else
        output = repmat("", size(values));
    end
    %)
end%


