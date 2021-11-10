
% >=R2019b
%(
function code = printWithValues(modelObject, modelFile, options)

arguments
    modelObject (1, 1) Model
    modelFile (1, :) string

    options.SaveAs (1, 1) string = ""
    options.Parameters (1, 1) logical = true
    options.Steady (1, 1) logical = true
    options.MarkdownCode (1, 1) = false
    options.Braces (1, 2) string = ["<", ">"]
end
%)
% >=R2019b


% <=R2019a
%{
function code = printWithValues(modelObject, modelFile, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    addParameter(pp, 'SaveAs', "");
    addParameter(pp, 'Parameters', true);
    addParameter(pp, 'Steady' , true);
    addParameter(pp, 'MarkdownCode', false);
end
parse(pp, varargin{:});
options = pp.Results;
%}
% <=R2019a


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
    if isreal(value)
        valueString = compose("%g", value);
    else
        valueString = compose("%g", real(value)) + compose("%+gi", imag(value));
    end
    valueString = options.Braces(1) + join(valueString, ", ") + options.Braces(2);
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
    textual.write(code, options.SaveAs);
end

end%

