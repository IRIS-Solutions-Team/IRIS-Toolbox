function run(fileName, section)

arguments
    fileName (1, 1) string
end

arguments (Repeating)
    section (1, 1) string
end

code = string(fileread(fileName));
code = locallyExtractCode(code, fileName, section{:});

if code~=""
    disp(code);
    evalin("caller", code);
end

end%

%
% Local functions
%

function outputCode = locallyExtractCode(inputCode, fileName, varargin)
    if isempty(varargin)
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
end%
