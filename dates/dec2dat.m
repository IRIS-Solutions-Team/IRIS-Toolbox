% dec2dat  Convert decimal representation of date to Dater object
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
% * `outputDate` [ Dater ] - Dater object representing the input date.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function outputDate = dec2dat(varargin)

dateCode = numeric.dec2dat(varargin{:});
outputDate = Dater(dateCode);

end%

