function dat = bb(varargin)
% bb  IRIS serial date number for bimonthly date.
%
% Syntax
% =======
%
%     Dat = bb(Y)
%     Dat = bb(Y,B)
%
% Input arguments
% ================
%
% * `Y` [ numeric ] - Years.
%
% * `B` [ numeric ] - Bimonth; if omitted, first bimonth
% (January-February) is assumed.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers representing the
% bimonthly date.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

dat = datcode(6, varargin{:});
dat = dates.Date(dat);

end
