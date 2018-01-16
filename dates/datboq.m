function boq = datboq(dat)
% datboq  Beginning of quarter for the specified daily date.
%
% Syntax
% =======
%
%     boq = datboq(dat)
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
% * `boq` [ numeric ] - Daily serial date number for the first day of the
% same quarter as `D`.
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
m = 3*(ceil(m/3)-1) + 1;
boq = datenum([y, m, 1]);

end
