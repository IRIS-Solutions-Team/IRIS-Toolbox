
% >=R2019b
%{
function run(fileName, opt)

arguments
    fileName (1, 1) string
    opt.Sections (1, :) string = string.empty(1, 0)
end
%}
% >=R2019b


% <=R2019a
%(
function run(fileName, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Sections", string.empty(1, 0));
end
opt = parse(ip, varargin{:});
%)
% <=R2019a


code = string(fileread(fileName));
code = local_extractCode(code, fileName, opt.Sections);

if code~=""
    disp(code);
    evalin("caller", code);
end

end%

%
% Local functions
%

function outputCode = local_extractCode(inputCode, fileName, sections)
    %(
    sections = textual.stringify(sections);
    if isempty(sections)
        outputCode = extractBetween(inputCode, "```matlab", "```", "boundaries", "inclusive");
        if isempty(outputCode)
            error("No section(s) of Matlab code found in %s.", sectionNamePattern, fileName);
        end
    else
        outputCode = string.empty(0, 1);
        sections = unique(string((varargin)));
        sectionNamePattern = sections(1);
        for n = sections(2:end)
            sectionNamePattern = sectionNamePattern | n;
        end
        startPattern = "```matlab" + whitespacePattern() + sectionNamePattern + whitespacePattern(1, Inf);
        outputCode = extractBetween(inputCode, startPattern, "```", "boundaries", "inclusive");
        if isempty(outputCode)
            error("No section(s) marked %s found in %s.", sectionNamePattern, fileName);
        end
    end
    outputCode = replace(outputCode, "```", "%```");
    if ~isempty(outputCode)
        outputCode = join(outputCode, newline);
    else
        outputCode = "";
    end
    %)
end%

