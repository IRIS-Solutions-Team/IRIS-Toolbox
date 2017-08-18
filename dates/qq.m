function dat = qq(varargin)
% qq  Create quarterly date.
%
% Syntax
% =======
%
% Input arguments marked with a `~` sign may be omitted.
%
%     dat = qq(year, ~quarter)
%
% Input arguments
% ================
%
% * `year` [ numeric ] - Year of vector of years.
%
% * `~quarter` [ numeric ] - Quarter of the year or vector of quarters; if
% omitted, first quarter is assumed.
%
% Output arguments
% =================
%
% * `dat` [ DateWrapper ] - Quarterly date.
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

dat = datcode(4, varargin{:});
dat = DateWrapper(dat);

end
