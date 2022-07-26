% convert   Convert dates to another frequency
%{
% ## Syntax ##
%
%
%     outputDate = convert(inputDate, newFreq, ...)
%
%
% ## Input Arguments ##
%
%
% __`inputDate`__ [ Dater ]
% >
% IRIS serial date numbers that will be
% converted to the new frequency, `NewFreq`.
%
%
% __`newFreq`__ [ Frequency.YEARLY | Frequency.HALFYEARLY | Frequency.QUARTERLY | Frequency.MONTHLY | Frequency.WEEKLY | Frequency.DAILY ]
% >
% New frequency to which the `inputDate` will be
% converted.
%
%
% ## Output Arguments ##
%
%
% __`outputDate`__ [ Dater ]
% >
% Dater object representing the new frequency.
%
%
% ## Options ##
%
%
% __`ConversionDay=1`__ [ numeric | `'last'` ]
% >
% Day within the `ConversionMonth` that will be used to represent the
% `inputDate` in low-requency to daily-frequency conversions.
%
%
% __`ConversionMonth=1`__ [ numeric | `'last'` ]
% >
% Month that will be used to represent a certain period of time in low- to
% high-frequency conversions.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDate = convert(inputDate, toFreq, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('dates.convert');
    addRequired(pp, 'inputDate', @validate.date);
    addRequired(pp, 'newFreq', @Frequency.validateFrequency);
end
pp.parse(inputDate, toFreq);

isDater = isa(inputDate, 'DateWrapper');

[flag, toFreq] = Frequency.validateFrequency(toFreq);
outputDate = dater.convert(double(inputDate), double(toFreq), varargin{:});

if isDater
    outputDate = Dater(outputDate);
end

end%

