function dat = hh(varargin)
% hh  IRIS serial date number for half-yearly date.
%
% Syntax
% =======
%
%     Dat = hh(Y)
%     Dat = hh(Y,H)
%
% Input arguments
% ================
%
% * `Y` [ numeric ] - Year.
%
% * `H` [ numeric ] - Half-year; if missing, first half-year (January-June)
% is assumed.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers representing the
% half-yearly date.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

dat = datcode(2, varargin{:});
dat = DateWrapper(dat);

end
