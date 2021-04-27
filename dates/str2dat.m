function outputDate = str2dat(string, varargin)
% str2dat  Convert strings to DateWrapper objects
%
% __Syntax__
%
%     Dat = str2dat(S, ...)
%
%
% __Input Arguments__
%
% * `s` [ char | cellstr ] - Cell array of strings representing dates.
%
%
% __Output Arguments__
%
% * `Dat` [ DateWrapper ] - Dates.
%
%
% __Options__
%
% * `Freq=[ ]` [ `1` | `2` | `4` | `6` | `12` | `52` | `365` | empty ] -
% Enforce frequency.
%
% * `OutputClass='DateWrapper'` [ `'DateWrapper'` | `'double'` ] - Type
% (class) of output dates.
%
% See help on [`dat2str`](dates/dat2str) for other options available
%
%
% __Description__
%
%
% __Example__
%
%     d = str2dat('04-2010','dateFormat=','MM-YYYY');
%     dat2str(d)
%     ans =
%        '2010M04'
%
%     d = str2dat('04-2010','dateFormat=','MM-YYYY','freq=',4);
%     dat2str(d)
%     ans =
%        '2010Q2'
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2021 IRIS Solutions Team

%--------------------------------------------------------------------------

dateCode = numeric.str2dat(string, varargin{:});
outputDate = DateWrapper(dateCode);

end%
