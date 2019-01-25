function eoq = dateoq(dat)
% dateoq  End of quarter for the specified daily date.
%
% Syntax
% =======
%
%     eoq = dateoq(dat)
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
% * `eoq` [ numeric ] - Daily serial date number for the last day of the
% same quarter as `dat`.
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
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

[y, m] = datevec( double(dat) );
m = 3*(ceil(m/3)-1) + 3;
eoq = datenum([y, m, eomday(y, m)]);

end
