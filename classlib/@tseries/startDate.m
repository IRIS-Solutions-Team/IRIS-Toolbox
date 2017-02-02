function dat = startDate(x)
% startdate  Date of the first available observation in Series object.
%
% Syntax
% =======
%
%     D = startDate(X)
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
% first observation available in the input series.
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

dat = x.Start;
dat = dates.Date(dat);

end
