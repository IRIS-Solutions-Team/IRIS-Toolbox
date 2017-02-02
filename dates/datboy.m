function boy = datboy(dat)
% datboy  Beginning of year for the specified daily date.
%
% Syntax
% =======
%
%     boy = dateboy(dat)
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
% * `boy` [ numeric ] - Daily serial date number for the first day of the
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

[y, ~] = datevec(double(dat));
boy = datenum([y, 1, 1]);

end
