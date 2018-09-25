function outputDate = qq(year, varargin)
% qq  Quarterly date
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted
%
%     OutputDate = qq(Year, ~Quarter)
%
%
% __Input Arguments__
%
% * `year` [ numeric ] - Year of vector of years.
%
% * `~quarter` [ numeric ] - Quarter of the year or vector of quarters; if
% omitted, first quarter is assumed.
%
%
% __Output arguments__
%
% * `OutputDate` [ DateWrapper | double ] - Quarterly date.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

dateCode = numeric.qq(year, varargin{:});
outputDate = DateWrapper(dateCode);

end%
