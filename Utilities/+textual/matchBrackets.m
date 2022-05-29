% matchBrakets  Match an opening bracket found at the beginning of char string
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     [close, inside, thisLevel] = textfun.matchBrakets(inputText, ~open, ~fill)
%
%
% ## Input Arguments ##
%
% __`inputText`__ [ char ] - 
% Input text string.
%
% __`~open`__ [ numeric ] - 
% Position of the requested opening bracket; if
% omitted the opening bracket is assumed at the beginning of `inputText`.
%
% __`~fill`__ [ char ] - 
% Auxiliary character that will be used to replace the
% content of nested brackets in `thisLevel`; if omitted `~fill` is a
% white space, `' '`.
%
%
% ## Output Arguments ##
%
% __`close`__ [ numeric ] - 
% Position of the matching closing bracket.
%
% __`inside`__ [ char ] - 
% Input text string inside the matching brackets.
%
% __`thisLevel`__ [ char ] - 
% Input text string inside the matching brackets
% where nested brackets are replaced with `fill`.
%
%
% ## Example ##
%
%     >> c = 'firstFunction(x(1), y(3), z(10)) + secondFunction()';
%     >> [posClose, inside, thisLevel] = textual.matchBrackets(c, 14)
%     posClose =
%         32
%     inside =
%         'x(1), y(3), z(10)'
%     thisLevel =
%         'x   , y   , z    '
%
%}

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (inputText) 2007-2022 IRIS Solutions Team.

function [posClose, inside, thisLevel] = matchBrackets(inputText, varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser('textual.matchBrackets');
    parser.addRequired('inputText', @(x) ischar(x) || isa(x, 'string'));
    parser.addOptional('PosOpen', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
    parser.addOptional('fill', ' ', @(x) ischar(x) && isscalar(x));
end
parser.parse(inputText, varargin{:});
posOpen = parser.Results.PosOpen;
fill = parser.Results.fill;

posClose = [ ];
inside = '';
thisLevel = '';

if posOpen>length(inputText)
   return
end

%--------------------------------------------------------------------------

inputText = inputText(:).';
openBracket = inputText(posOpen);
switch openBracket
   case '('
      closeBracket = ')';
   case '['
      closeBracket = ']';
   case '{'
      closeBracket = '}';
   case '<'
      closeBracket = '>';
   otherwise
      return
end

% Find out the positions of opening and closing brackets.
x = zeros(size(inputText));
x(inputText==openBracket) = 1;
x(inputText==closeBracket) = -1;
x(1:posOpen-1) = NaN;

% Assign the level numbers to the contents of nested brackets. The closing
% brackets have always the level number of the outside contents.
cumX = x;
cumX(posOpen:end) = cumsum(x(posOpen:end));
posClose = find(cumX==0, 1, 'first');
if nargout>1
   if ~isempty(posClose)
      inside = inputText(posOpen+1:posClose-1);
      if ~isempty(inside)
         x = x(posOpen+1:posClose-1);
         cumX = cumX(posOpen+1:posClose-1);
         thisLevel = inside;
         % Replace the content of higher-level nested brackets with `fill`.
         thisLevel(cumX>cumX(1)) = fill;
         % Replace also the closing higher-level brackets (they are not
         % captured above).
         thisLevel(x==-1) = fill;
      else
         thisLevel = '';
      end
   end
end

end
