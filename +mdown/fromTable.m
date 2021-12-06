function code = fromTable(t, options)

arguments
    t table

    options.NaN (1, :) string {mustBeScalarOrEmpty} = string.empty(1, 0)
    options.Zero (1, :) string {mustBeScalarOrEmpty} = string.empty(1, 0)
    options.RowNamesHeader (1, 1) string = "Name"
    options.RowNamesPattern (1, 2) string = ["`", "`"]
    options.NumericFormat (1, 1) string = "%g"
    options.Round (1, 1) double = Inf
    options.Title (1, :) string {mustBeScalarOrEmpty} = string.empty(1, 0)
    options.SaveAs (1, :) string {mustBeScalarOrEmpty} = string.empty(1, 0)
    options.AppendTo (1, :) string {mustBeScalarOrEmpty} = string.empty(1, 0)
end

s = table2struct(t, "toScalar", true);
columnNames = textual.stringify(t.Properties.VariableNames);

rowNames = textual.stringify(t.Properties.RowNames);
if ~isempty(rowNames)
    columnNames = [options.RowNamesHeader, columnNames];
    rowNames = options.RowNamesPattern(1) + rowNames + options.RowNamesPattern(2);
    s.(options.RowNamesHeader) = reshape(rowNames, [], 1);
end

numColumns = numel(columnNames);
numRows = numel(s.(columnNames(1)));

%
% Convert all values to strings
%
p = struct();
for n = columnNames
    p.(n) = locallyStringify(s.(n), options);
end


title = string(newline());
if ~isempty(options.Title)
    title = title + join(options.Title, newline);
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

if ~isempty(options.SaveAs)
    textual.write(code, options.SaveAs);
end

if ~isempty(options.AppendTo)
    try
        existing = fileread(options.AppendTo);
    catch
        existing = "";
    end
    textual.write(existing + code, options.AppendTo);
end

end%

%
% Local functions
%

function output = locallyStringify(values, options)
    %(
    if isstring(values)
        output = values;
    elseif islogical(values)
        output = repmat("", size(values));
        output(values) = "`true`";
        output(~values) = "`false`";
    elseif isnumeric(values)
        if ~isequal(options.Round, Inf)
            values = round(values, options.Round);
            values(values==0) = 0;
        end
        output = compose(options.NumericFormat, values);
        if ~isempty(options.NaN)
            nanString = sprintf(options.NumericFormat, NaN);
            output = replace(output, nanString, options.NaN);
        end
        if ~isempty(options.Zero)
            zeroString = sprintf(options.NumericFormat, 0);
            output = replace(output, zeroString, options.Zero);
        end
    elseif iscellstr(values)
        output = string(values);
    else
        output = repmat("", size(values));
    end
    %)
end%


