function [level, allClosed] = bracketLevel(inputString, bracketTypes, varargin)
% bracketLevel  Return the nested bracket level for each character in a string
%{
% ## Syntax ##
%
%
%     [level, allClosed] = textual.bracetLevel(inputString, bracketTypes)
%
%
% ## Input Arguments ##
%
%
% __`inputString`__ [ char | string ]
% >
% Input string; for each of the characters in the `inputString`, a number
% greater than or equal to 0 will be returned indicating the level of
% nested brackets at the position.
%
%
% __`bracketTypes`__ [ cellstr | string ]
% >
% List of bracket types that will be counted; can be any combination of the
% following four types of brackets: `()`, `[]`, `{}`, `<>`.
%
%
% ## Output Arguments ##
%
%
% __`level`__ [ numeric ]
% >
% A vector of numbers greater than or equal to 0 indicating the the level
% of nested brackets at the respective position in the `inputString`; all
% opening and closing brackets are counted as inside themselves.
%
%
% __`allClosed`__ [ `true` | `false` ]
% True if all brackets are closed by the end of the string.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('+textual/bracketLevel');
    addRequired(pp, 'inputString', @validate.string);
    addRequired(pp, 'bracketTypes', @(x) validate.list(x) && all(cellfun(@(y) any(strcmp(y, {'()', '[]', '{}', '<>'})), cellstr(x))));
end
%)
[skip, opt] = maybeSkip(pp, varargin{:});
if ~skip
    opt = parse(pp, inputString, bracketTypes);
end

%--------------------------------------------------------------------------

inputString = reshape(char(inputString), 1, [ ]);
bracketTypes = cellstr(bracketTypes);

inputString = [inputString, ' '];
level = zeros(size(inputString));

if any(strcmp(bracketTypes, '()'))
    hereLevel('(', ')');
end

if any(strcmp(bracketTypes, '[]'))
    hereLevel('[', ']');
end

if any(strcmp(bracketTypes, '{}'))
    hereLevel('{', '}');
end

if any(strcmp(bracketTypes, '<>'))
    hereLevel('<', '>');
end

allClosed = level(end)==0;
level(end) = [ ];

return

    function hereLevel(open, close)
        tempLevel = zeros(size(inputString));
        tempLevel(inputString==open) = 1;
        tempLevel([' ', inputString(1:end-1)]==close) = -1;
        tempLevel = cumsum(tempLevel);
        level = level + tempLevel;
    end%
end%

