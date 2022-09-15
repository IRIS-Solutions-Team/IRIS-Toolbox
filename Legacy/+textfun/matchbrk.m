function [close, inside, thisLevel] = matchbrk(c, open, fill)
% matchbrk  Match an opening bracket found at the beginning of char string.
%
% Syntax
% =======
%
%     [Close,Inside,ThisLevel] = textfun.matchbrk(Text)
%     [Close,Inside,ThisLevel] = textfun.matchbrk(Text,Open)
%     [Close,Inside,ThisLevel] = textfun.matchbrk(Text,Open,Fill)
%
% Input arguments
% ================
%
% * `Text` [ char ] - Text string.
%
% * `Open` [ numeric ] - Position of the requested opening bracket; if not
% specified the opening bracket is assumed at the beginning of `Text`.
%
% * `Fill` [ char ] - Auxiliary character that will be used to replace the
% content of nested brackets in `ThisLevel`; if not specified `Fill` is a
% white space, `' '`.
%
% Output arguments
% =================
%
% * `Close` [ numeric ] - Position of the matching closing bracket.
%
% * `Inside` [ char ] - Text string inside the matching brackets.
%
% * `ThisLevel` [ char ] - Text string inside the matching brackets where
% nested brackets are replaced with `Fill`.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    open; %#ok<*VUNUS>
catch %#ok<*CTCH>
    open = 1;
end


try
    fill;
catch
    fill = ' ';
end

% Parse input arguments.
isnumericscalar = @(x) isnumeric(x) && isscalar(x);
pp = inputParser( );
pp.addRequired('Text',@ischar);
pp.addRequired('Open',isnumericscalar);
pp.addRequired('Fill',@(x) ischar(x) && length(x)==1);
pp.parse(c,open,fill);

close = [ ];
inside = '';
thisLevel = '';

if open > length(c)
   return
end

%--------------------------------------------------------------------------

c = c(:).';
openBrk = c(open);
switch openBrk
   case '('
      closeBrk = ')';
   case '['
      closeBrk = ']';
   case '{'
      closeBrk = '}';
   case '<'
      closeBrk = '>';
   otherwise
      return
end

% Find out the positions of opening and closing brackets.
x = zeros(size(c));
x(c==openBrk) = 1;
x(c==closeBrk) = -1;
x(1:open-1) = NaN;
% Assign the level numbers to the content of nested brackets. The closing
% brackets have always the level number of the outside content.
cumX = x;
cumX(open:end) = cumsum(x(open:end));
close = find(cumX==0,1,'first');
if nargout>1
   if ~isempty(close)
      inside = c(open+1:close-1);
      if ~isempty(inside)
         x = x(open+1:close-1);
         cumX = cumX(open+1:close-1);
         thisLevel = inside;
         % Replace the content of higher-level nested brackets with `Fill`.
         thisLevel(cumX > cumX(1)) = fill;
         % Replace also the closing higher-level brackets (they are not
         % captured above).
         thisLevel(x==-1) = fill;
      else
         thisLevel = '';
      end
   end
end

end
