function dat = mmtoday( )
% mmtoday  IRIS serial date number for current month.
%
% Syntax
% =======
%
%     dat = mmtoday( )
%
%
% Output arguments
% =================
%
% * `dat` [ numeric ]  - IRIS serial date number for current month.
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
dat = mm(year, month);

end
