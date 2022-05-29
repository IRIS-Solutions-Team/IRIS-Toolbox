function eoy = dateoy(dat)
% dateoy  End of year for the specified daily date.
%
% Syntax
% =======
%
%     eoy = dateoy(dat)
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
% * `eoy` [ numeric ] - Daily serial date number for the last day of the
% same year as `dat`.
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
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[y, ~] = datevec( double(dat) );
eoy = datenum([y, 12, eomday(y, 12)]);

end
