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
% * `newFreq` [ Frequency.YEARLY | Frequency.HALFYEARLY |
% Frequency.QUARTERLY | Frequency.MONTHLY | Frequency.WEEKLY |
% Frequency.DAILY ] - New frequency to which the `inputDate` will be
% converted.
%
%
% __Output Arguments__
%
% * `outputDate` [ DateWrapper ] - DateWrapper object representing the new
% frequency.
%
%
% __Options__
%
% * `ConversionDay=1` [ numeric | `'last'` ] - Day within the
% `ConversionMonth` that will be used to represent the `inputDate` in
% low-requency to daily-frequency conversions.
%
% * `ConversionMonth=1` [ numeric | `'last'` ] - Month that will be
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
% -Copyright (c) 2007-2019 IRIS Solutions Team

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

