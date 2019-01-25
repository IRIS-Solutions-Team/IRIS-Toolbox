function outputDate = yy(year, varargin)
% yy  IRIS yearly date
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
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

dateCode = numeric.yy(year, varargin{:});
outputDate = DateWrapper(dateCode);

end
