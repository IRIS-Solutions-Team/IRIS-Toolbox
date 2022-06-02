
% >=R2019b
%{
function output = fromMatlab(input, opt)

arguments
    input (1, 1) string
    opt.Language (1, 1) string = "matlab"
end
%}
% >=R2019b


% <=R2019a
%(
function output = fromMatlab(input, varargin)

input = string(input);

persistent pp
if isempty(pp)
    pp = inputParser();
    pp = addParameter("Language", "matlab");
end
parse(pp, varargin{:});
opt = pp.Results;
%)
% <=R2019a


opt.Language = string(opt.Language);
opt.Language = opt.Language(1);
br = string(newline());

startCode = "```" + opt.Language;
endCode = "```";

output = input;
output = regexprep(output, "^[ ]*%{[ ]*$", endCode, "lineanchors");
output = regexprep(output, "^[ ]*%}[ ]*$", startCode, "lineanchors");
output = startCode+br+output;
output = output+br+endCode;

output = regexprep(output, startCode+"\s+"+endCode, "");

end%

