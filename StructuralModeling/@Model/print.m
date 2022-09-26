%{
% 
% # `print` ^^(Model)^^
% 
% {== Print model object ==}
% 
% 
% ## Syntax 
% 
%     [___] = print(___)
% 
% 
% ## Input arguments 
% 
% __`xxx`__ [ xxx | ___ ]
% > 
% > Description
% > 
% 
% 
% ## Output arguments 
% 
% __`yyy`__ [ yyy | ___ ]
% > 
% > Description
% > 
% 
% 
% ## Options 
% 
% __`zzz=default`__ [ zzz | ___ ]
% > 
% > Description
% > 
% 
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
% ```matlab
% ```
% 
%}
% --8<--


% >=R2019b
%{
function code = print(modelObject, modelFile, opt)

arguments
    modelObject (1, 1) Model
    modelFile (1, :) string

    opt.SaveAs (1, 1) string = ""
    opt.Parameters (1, 1) logical = true
    opt.Steady (1, 1) logical = true
    opt.Markdown (1, 1) logical = false
    opt.Braces (1, 2) string = ["<", ">"]
end
%}
% >=R2019b


% <=R2019a
%(
function code = print(modelObject, modelFile, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, 'SaveAs', "");
    addParameter(ip, 'Parameters', true);
    addParameter(ip, 'Steady' , true);
    addParameter(ip, 'Markdown', false);
    addParameter(ip, 'Braces', ["<", ">"]);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
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
if opt.Parameters
    selectTypes = [selectTypes, 4];
end
if opt.Steady
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
    valueString = opt.Braces(1) + join(valueString, ", ") + opt.Braces(2);
    code = regexprep(code, "\<" + name + "\>(\{[^\}]*\})?", name + "$1" + valueString);
end

if ~isequal(opt.Markdown, false)
    code = join(["```iris",  string(code), "```"], newline());
end

if ~isempty(opt.SaveAs) && strlength(opt.SaveAs)>0
    textual.write(code, opt.SaveAs);
end

end%

