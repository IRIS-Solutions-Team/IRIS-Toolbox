function dat = hhtoday( )
% hhtoday  IRIS serial date number for current half-year.
%
% Syntax
% =======
%
%     dat = hhtoday( )
%
%
% Output arguments
% =================
%
% * `dat` [ numeric ] - IRIS serial date number for current half-year.
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

[year, month] = datevec(now( ));
dat = hh(year, 1+floor((month-1)/6));

end
