function dat = wwtoday( )
% wwtoday  IRIS serial date number for current week.
%
% Syntax
% =======
%
%     dat = wwtoday( )
%
%
% Output arguments
% =================
%
% * `dat` [ numeric ]  - IRIS serial date number for current week.
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

today = floor(now( ));
dat = day2ww(today);
dat = DateWrapper(dat);

end
