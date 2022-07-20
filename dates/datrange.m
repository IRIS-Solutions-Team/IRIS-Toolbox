function Rng = datrange(Start,End,Step)
% datrange  Numerically safe way to create a date range.
%
% Syntax
% =======
%
%     Rng = datrange(Start,End)
%     Rng = datrange(Start,End,Step)
%
%
% Input arguments
% ================
%
% * `Start` [ numeric ] - Start date of the range.
%
% * `End` [ numeric ] - End date of the range.
%
% * `Step` [ numeric ] - Step size in the number of base periods; if
% omitted, `Step = 1`.
%
%
% Output arguments
% =================
% 
% * `Rng` [ numeric ] - Date vector `Start : Step : End`.
%
%
% Description
% ============
%
% Most of the time, using a colon operator to create a date range works
% fine,
%
%     Start : Step : End
%
% Under some (rather rare) circumstances, the colon operator may give
% incorrect results caused by rounding error difficulties since IRIS serial
% date numbers are non-integer values. In that case, the function
% `datrange` provides a safe workaround:
%
%     datrange(Start,End,Step)
%
% is equivalent (but numerically safer) to
%
%     Start : Step : End
%
%
% Example
% ========
%
% The date ranges created in this example are identical, and no numerical
% inaccuracies exist:
%
%     r1 = qq(2000,1) : qq(2010,4);
%     r2 = datrange(qq(2000,1),qq(2010,4));
%     format long
%     r1 - r2
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    Step; %#ok<VUNUS>
catch
    Step = 1;
end

isintscalar = @(x) isnumeric(x) && isscalar(x) && round(x)==x;
isnumericscalar = @(x) isnumeric(x) && isscalar(x);

pp = inputParser();
pp.addRequired('Start',isnumericscalar);
pp.addRequired('End',@(x) isnumericscalar(x) && freqcmp(x,Start));
pp.addRequired('Step',isintscalar);
pp.parse(Start,End,Step);

%--------------------------------------------------------------------------

flrStart = floor(Start);
flrEnd = floor(End);
dec = round(100*(Start - flrStart));
Rng = flrStart : Step : flrEnd;
Rng = Rng + dec/100;

end
