function dat = yy(varargin)
% yy  IRIS serial date number for yearly date.
%
% Syntax
% =======
%
%     dat = yy(year)
%
%
% Input arguments
% ================
%
% * `year` [ numeric ] - Calendar year.
%
%
% Output arguments
% =================
%
% * `dat` [ dates.date ] - IRIS serial date numbers.
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

dat = datcode(1, varargin{:});
dat = dates.Date(dat);

end
