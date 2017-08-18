function dat = yytoday( )
% yytoday  IRIS serial date number for current year.
%
% Syntax
% =======
%
%     dat = yytoday( )
%
%
% Output arguments
% =================
%
% * `dat` [ DateWrapper ]  - IRIS serial date number for current year.
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

[year, ~] = datevec(now( ));
dat = yy(year);

end
