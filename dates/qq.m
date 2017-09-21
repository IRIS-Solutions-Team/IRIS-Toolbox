function dat = qq(varargin)
% qq  Create quarterly date.
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     dat = qq(year, ~quarter)
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
% * `dat` [ DateWrapper ] - Quarterly date.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

dat = datcode(4, varargin{:});
dat = DateWrapper(dat);

end
