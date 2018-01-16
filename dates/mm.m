function dat = mm(varargin)
% mm  IRIS serial date number for monthly date.
%
% Syntax
% =======
%
%     Dat = mm(Y)
%     Dat = mm(Y,M)
%
% Input arguments
% ================
%
% * `Y` [ numeric ] - Year.
%
% * `M` [ numeric ] - Month; if omitted, first month (January) is assumed.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date number representing the monthly
% date.
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

dat = datcode(12, varargin{:});
dat = DateWrapper(dat);

end
