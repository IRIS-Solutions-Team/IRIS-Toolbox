function dat = endDate(x)
% enddate  Date of the last available observation in Series object.
%
% Syntax
% =======
%
%     D = endDate(X)
%
%
% Input arguments
% ================
%
% * `X` [ Series ] - Series object.
%
%
% Output arguments
% =================
%
% * `D` [ numeric ] - IRIS serial date number representing the date of the
% last observation available in the input series.
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

dat = x.Start + size(x.Data, 1) - 1;
dat = dates.Date(dat);

end
