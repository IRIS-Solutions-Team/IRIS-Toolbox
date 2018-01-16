function eom = dateom(dat)
% dateom  End of month for the specified daily date.
%
% Syntax
% =======
%
%     eom = dateom(dat)
%
%
% Input arguments
% ================
%
% * `dat` [ numeric ] - Daily serial date number.
%
%
% Output arguments
% =================
%
% * `eom` [ numeric ] - Daily serial date number for the last day of the
% same month as `dat`.
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

[y, m] = datevec( double(dat) );
eom = datenum([y, m, eomday(y, m)]);

end
