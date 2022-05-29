% dater.fromIsoString  Convert ISO string to numeric dateCode
%{
% Syntax
%--------------------------------------------------------------------------
%
%     output = dater.fromIsoString(freq, isoString)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __``__ [ ]
%
%>    Description
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __``__ [ ]
%
%>    Description
%
%
% Options
%--------------------------------------------------------------------------
%
%
% __`=`__ [ | ]
%
%>    Description
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function dateCode = fromIsoString(freq, isoDate)

freq = double(Frequency(freq));
freq = freq(1);

isoDate = strip(string(isoDate));

if isequal(freq, 0)
    dateCode = double(isoDate);
    return
end

reshapeOutput = size(isoDate);
isoDate = reshape(isoDate, 1, [ ]);
[isoDate, inxMissing] = local_fixIsoDate(isoDate);
[year, month, day] = local_getYearMonthDay(isoDate);

serial = dater.serialFromYmd(freq, year, month, day);

dateCode = nan(size(inxMissing));
dateCode(~inxMissing) = dater.fromSerial(freq, serial);
dateCode = reshape(dateCode, reshapeOutput);

end%

%
% Local functions
%

function [isoDate, inxMissing] = local_fixIsoDate(isoDate)
    inxMissing = ismissing(isoDate);
    isoDate(inxMissing) = [ ];
    lenIsoDate = strlength(isoDate);

    % "2020-01-31 xxx"
    inx10 = lenIsoDate>10;
    if any(inx10)
        isoDate(inx10) = extractBefore(isoDate(inx10), 11);
    end

    % "2020-01"
    inx7 = lenIsoDate==7;
    if any(inx7)
        isoDate(inx7) = isoDate(inx7) + "-01";
    end

    % "2020"
    inx4 = lenIsoDate==4;
    if any(inx4)
        isoDate(inx4) = isoDate(inx4) + "-01-01";
    end

    % "20200131"
    inx8 = lenIsoDate==8 & ~contains(isoDate, "-");
    if any(inx8)
        isoDate(inx8) = extractBetween(isoDate(inx8), 1, 4) + "-" + extractBetween(isoDate(inx8), 5, 6) + "-" + extractBetween(isoDate(inx8), 7, 8);
    end
end%


function [year, month, day] = local_getYearMonthDay(isoDate)
    [year, month, day] = textual.split(isoDate, "-");
    year = double(year);
    month = double(month);
    day = double(day);
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=dater/fromIsoStringUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);


%% Test Full String
    assertEqual(testCase, dater.fromIsoString(Frequency.DAILY, "2020-05-15"), dater.dd(2020,05,15));
    assertEqual(testCase, dater.fromIsoString(Frequency.WEEKLY, "2020-05-15"), dater.ww(2020,05,15));
    assertEqual(testCase, dater.fromIsoString(Frequency.MONTHLY, "2020-05-15"), dater.mm(2020,05));
    assertEqual(testCase, dater.fromIsoString(Frequency.QUARTERLY, "2020-05-15"), dater.qq(2020,2));
    assertEqual(testCase, dater.fromIsoString(Frequency.YEARLY, "2020-05-15"), dater.yy(2020));


%% Test Year Month String
    assertEqual(testCase, dater.fromIsoString(Frequency.DAILY, "2020-05"), dater.dd(2020,05,01));
    assertEqual(testCase, dater.fromIsoString(Frequency.WEEKLY, "2020-05"), dater.ww(2020,05,01));
    assertEqual(testCase, dater.fromIsoString(Frequency.MONTHLY, "2020-05"), dater.mm(2020,05));
    assertEqual(testCase, dater.fromIsoString(Frequency.QUARTERLY, "2020-05"), dater.qq(2020,2));
    assertEqual(testCase, dater.fromIsoString(Frequency.YEARLY, "2020-05"), dater.yy(2020));
    

%% Test Year String
    assertEqual(testCase, dater.fromIsoString(Frequency.DAILY, "2020"), dater.dd(2020,01,01));
    assertEqual(testCase, dater.fromIsoString(Frequency.WEEKLY, "2020"), dater.ww(2020,01,01));
    assertEqual(testCase, dater.fromIsoString(Frequency.MONTHLY, "2020"), dater.mm(2020,01));
    assertEqual(testCase, dater.fromIsoString(Frequency.QUARTERLY, "2020"), dater.qq(2020,1));
    assertEqual(testCase, dater.fromIsoString(Frequency.YEARLY, "2020"), dater.yy(2020));
    
##### SOURCE END #####
%}
