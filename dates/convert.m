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
% * `InputDate` [ DateWrapper ] - IRIS serial date numbers that will be
% converted to the new frequency, `NewFreq`.
%
% * `NewFreq` [ `1` | `2` | `4` | `6` | `12` | `52` | `365` ] - New
% frequency to which the dates `d1` will be converted.
%
%
% __Output Arguments__
%
% * `OutputDate` [ DateWrapper ] - IRIS serial date numbers representing
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

persistent parser
if isempty(parser)
    parser = extend.InputParser('dates.convert');
    parser.addRequired('InputDate', @DateWrapper.validateDateInput);
    parser.addRequired('NewFreq', @Frequency.validateFrequency);
end
parser.parse(inputDate, toFreq);

%--------------------------------------------------------------------------

if isa(inputDate, 'DateWrapper')
    outputClass = 'DateWrapper';
else
    outputClass = 'double';
end

[flag, toFreq] = Frequency.validateFrequency(toFreq);
outputDate = numeric.convert(inputDate, double(toFreq), varargin{:});

if strcmpi(outputClass, 'DateWrapper')
    outputDate = DateWrapper(outputDate);
end

end%

