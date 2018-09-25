function outputDate = convert(inputDate, toFreq, varargin)
% convert   Convert dates to another frequency
%
% __Syntax__
%
%     outputDate = convert(inputDate, newFreq, ...)
%
%
% __Input Arguments__
%
% * `inputDate` [ DateWrapper ] - IRIS serial date numbers that will be
% converted to the new frequency, `NewFreq`.
%
% * `newFreq` [ `1` | `2` | `4` | `6` | `12` | `52` | `365` ] - New
% frequency to which the dates `d1` will be converted.
%
%
% __Output Arguments__
%
% * `outputDate` [ DateWrapper ] - IRIS serial date numbers representing
% the new frequency.
%
%
% __Options__
%
% * `ConversionMonth=1` [ numeric | `'last'` | `1` ] - Month that will be
% used to represent a certain period of time in low- to high-frequency
% conversions.
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

if isa(inputDate, 'DateWrapper')
    outputClass = 'DateWrapper';
else
    outputClass = 'double';
end

outputDate = numeric.convert(inputDate, toFreq, varargin{:});

if strcmpi(outputClass, 'DateWrapper')
    outputDate = DateWrapper(outputDate);
end

end%
