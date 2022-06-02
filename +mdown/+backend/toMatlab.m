
% >=R2019b
%{
function output = toMatlab(input, opt)

arguments
    input (1, 1) string
    opt.Language (1, :) string = ["matlab", "iris"]
end
%}
% >=R2019b


% <=R2019a
%(
function output = toMatlab(input, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Language", ["matlab", "iris"]);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


input = textual.stringify(split(string(input), newline()));
opt.Language = reshape(string(opt.Language), 1, []);
output = string.empty(1, 0);

inCode = false;
inMath = false;
canBeIndentedCode = true;
inxCode = logical.empty(1, 0);

for line = input
    if ~inCode && ~inMath
        %
        % Outside code and math
        %
        if startsWith(line, "$$")
            inMath = true;
            canBeIndentedCode = false;
            line = locallyComment(line);
            inxCode(end+1) = false;
        elseif canBeIndentedCode && startsWith(line, "    ")
            line = extractAfter(line, 4);
            canBeIndentedCode = true;
            inxCode(end+1) = true;
        elseif startsWith(line, "```"+opt.Language)
            line = "";
            inCode = true;
            canBeIndentedCode = false;
            inxCode(end+1) = true;
        elseif strlength(erase(line, " "))==0
            line = "";
            canBeIndentedCode = true;
            inxCode(end+1) = false;
        else
            line = locallyComment(line);
            canBeIndentedCode = false;
            inxCode(end+1) = false;
        end
    elseif inMath
        %
        % In math
        %
        if startsWith(line, "$$")
            inMath = false;
        end
        line = locallyComment(line);
        canBeIndentedCode = false;
        inxCode(end+1) = false;
    else
        %
        % In code
        %
        if startsWith(line, "```") && ~startsWith(line, "```"+string(opt.Language))
            line = "";
            inCode = false;
        end
        canBeIndentedCode = false;
        inxCode(end+1) = true;
    end

    output(end+1) = line;
end

output = locallyJoinComments(output, inxCode);
output = join(output, newline);

end%

%
% Local functions
%

function line = locallyComment(line)
    %(
    if strlength(line)==0
        return
    end
    line = "% " + line;
    if startsWith(line, "% ## ")
        line = replace(line, "% ## ", "%% ");
        if ~endsWith(line, " ")
            line = line + " ";
        end
    elseif startsWith(line, "% # ")
        line = replace(line, "% # ", "%% ");
        if ~endsWith(line, " ")
            line = line + " ";
        end
    end
    %)
end%


function output = locallyJoinComments(output, inxCode)
    %
    % Comment out each line outside code that
    % * contains only blank spaces, and
    % * is preceded by a commented line, and
    % * is followed either by a commented line or an empty line
    % 
    %(
    inxCommented = startsWith(output, "%");
    inxEmpty = strlength(erase(output, " "))==0;
    inxCommented = [false, inxCommented, false];
    inxEmpty = [false, inxEmpty, false];
    inx = inxEmpty(2:end-1) & inxCommented(1:end-2) & ~inxCommented(2:end-1) & (inxCommented(3:end) | inxEmpty(3:end)) & ~inxCode;
    if any(inx)
        output(inx) = "% " + output(inx);
    end
    %)
end%

