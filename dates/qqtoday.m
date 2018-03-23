function dat = qqtoday( )
% qqtoday  IRIS serial date number for current quarter.
%
% Syntax
% =======
%
%     dat = qqtoday( )
%
%
% Output arguments
% =================
%
%
% * `dat` [ numeric ]  - IRIS serial date number for current quarter.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

[year, month] = datevec(now( ));
dat = qq(year, 1+floor((month-1)/3));

end
