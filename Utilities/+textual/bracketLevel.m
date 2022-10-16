
function [level, allClosed] = bracketLevel(inputString, bracketTypes, varargin)

%( Input parser
persistent ip
if isempty(ip)
    ip = extend.InputParser();
    addRequired(ip, 'inputString', @validate.string);
    addRequired(ip, 'bracketTypes', @(x) validate.list(x) && all(cellfun(@(y) any(strcmp(y, {'()', '[]', '{}', '<>', '"', ''''})), cellstr(x))));
end
[skip, opt] = maybeSkip(ip, varargin{:});
if ~skip
    opt = parse(ip, inputString, bracketTypes);
end
%)


    inputString = reshape(char(inputString), 1, []);
    bracketTypes = string(bracketTypes);

    inputString = [inputString, ' '];
    level = zeros(size(inputString));

    for t = bracketTypes
        if strlength(t)==2
            level = local_getLevelForPair(inputString, level, t);
        elseif strlength(t)==1
            level = local_getLevelForSingleton(inputString, level, t);
        end
    end

    allClosed = level(end)==0;
    level(end) = [];

end%


function level = local_getLevelForPair(inputString, level, brackets)
    %(
    brackets = char(brackets);
    open = brackets(1);
    close = brackets(2);
    updateLevel = zeros(size(inputString));
    updateLevel(inputString==open) = 1;
    updateLevel([' ', inputString(1:end-1)]==close) = -1;
    level = level + cumsum(updateLevel);
    %)
end%


function level = local_getLevelForSingleton(inputString, level, mark)
    %(
    mark = char(mark);
    updateLevel = zeros(size(inputString));
    posMark = find(inputString==mark);
    updateLevel(posMark(1:2:end)) = 1;
    updateLevel(posMark(2:2:end)) = -1;
    level = level + cumsum(updateLevel);
    %)
end%

