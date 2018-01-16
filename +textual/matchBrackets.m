function [posClose, inside, thisLevel] = matchBrackets(inputText, varargin)
% matchBrakets  Match an opening bracket found at the beginning of char string
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [Close, Inside, ThisLevel] = textfun.matchBrakets(InputText, ~Open, ~Fill)
%
%
% __Input Arguments__
%
% * `InputText` [ char ] - Input text string.
%
% * `~Open` [ numeric ] - Position of the requested opening bracket; if
% omitted the opening bracket is assumed at the beginning of `InputText`.
%
% * `~Fill` [ char ] - Auxiliary character that will be used to replace the
% content of nested brackets in `ThisLevel`; if omitted `~Fill` is a
% white space, `' '`.
%
%
% __Output Arguments__
%
% * `Close` [ numeric ] - Position of the matching closing bracket.
%
% * `Inside` [ char ] - Input text string inside the matching brackets.
%
% * `ThisLevel` [ char ] - Input text string inside the matching brackets
% where nested brackets are replaced with `Fill`.
%
%
% __Example__
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (inputText) 2007-2018 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('textual.matchBrackets');
    INPUT_PARSER.addRequired('InputText', @(x) ischar(x) || isa(x, 'string'));
    INPUT_PARSER.addOptional('PosOpen', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
    INPUT_PARSER.addOptional('Fill', ' ', @(x) ischar(x) && isscalar(x));
end
INPUT_PARSER.parse(inputText, varargin{:});
posOpen = INPUT_PARSER.Results.PosOpen;
fill = INPUT_PARSER.Results.Fill;

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
         % Replace the content of higher-level nested brackets with `Fill`.
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
