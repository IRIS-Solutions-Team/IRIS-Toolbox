function outputDate = dec2dat(varargin)
% dec2dat  Convert decimal representation of date to DateWrapper object
%
% __Syntax__
%
%     outputDate = dec2dat(dec, freq)
%
%
% __Input Arguments__
%
% * `dec` [ numeric ] - Decimal representation of a date.
%
% * `freq` [ freq ] - Date frequency.
%
%
% __Output Arguments__
%
% * `outputDate` [ DateWrapper ] - DateWrapper object representing the
% input date.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

dateCode = numeric.dec2dat(varargin{:});
outputDate = DateWrapper(dateCode);

end%

