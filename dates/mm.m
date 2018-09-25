function outputDate = mm(year, varargin)
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

dateCode = numeric.mm(year, varargin{:});
outputDate = DateWrapper(dateCode);

end%

