function code = printWithValues(modelObject, modelFile, options)

arguments
    modelObject (1, 1) Model
    modelFile (1, :) string
    options.SaveAs (1, 1) string = ""
    options.Parameters (1, 1) logical = true
    options.Steady (1, 1) logical = true
    options.MarkdownCode (1, 1) = false
end

modelFile = reshape(string(modelFile), 1, []);

code = "";
if isempty(modelFile)
    return
end

code = string(fileread(modelFile(1)));

if numel(modelFile)>1
    lineBreak = string(newline());
    for n = modelFile(2:end)
        code = code + lineBreak + lineBreak + lineBreak + string(fileread(n));
    end
end

types = modelObject.Quantity.Type;
names = string(modelObject.Quantity.Name);
values = modelObject.Variant.Values;

selectTypes = [];
if options.Parameters
    selectTypes = [selectTypes, 4];
end
if options.Steady
    selectTypes = [selectTypes, 1, 2];
end
inxSelect = ismember(types, selectTypes);

for i = find(inxSelect)
    name = names(i);
    if ~contains(code, name)
        continue
    end
    value = reshape(values(1, i, :), 1, []);
    valueString = "<" + join(replace(string(value), " ", ""), ", ") + ">";
    code = regexprep(code, "\<" + name + "\>(\{[^\}]*\})?", name + "$1" + valueString);
end

if ~isequal(options.MarkdownCode, false)
    type = "";
    if ischar(options.MarkdownCode) || isstring(options.MarkdownCode)
        type = string(options.MarkdownCode);
    end
    code = "```" + type + newline + code + newline + "```" + newline;
end

if ~isempty(options.SaveAs) && strlength(options.SaveAs)>0
    writematrix(code, options.SaveAs, "fileType", "text", "quoteStrings", false);
end

end%

