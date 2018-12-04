function outputDate = mm(year, varargin)
% mm  Create DateWrapper object representing a monthly date
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted
%
%     dw = mm(year, ~month)
%
% Input arguments
% ================
%
% * `year` [ numeric ] - Year.
%
% * `month` [ numeric | char | string ] - Numeric month or three-letter
% abbreviation of a month name (English); if omitted, `month=1`.
%
%
% __Output Arguments__
%
% * `dw` [ numeric ] - IRIS serial date number representing the monthly
% date.
%
% __Description__
%
% The `mm(~)` function returns a DateWrapper object representing a monthly
% date. To obtain a plain numeric representation, use the low-level
% function `numeric.mm(~)` with the same input arguments.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

dateCode = numeric.mm(year, varargin{:});
outputDate = DateWrapper(dateCode);

end%

