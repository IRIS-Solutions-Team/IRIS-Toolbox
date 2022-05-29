% isfreq  True for dates of the specified frequency
%{
% ## Syntax ##
%
%
%     flag = isfreq(date, frequency)
%
%
% ## Input Arguments ##
%
%
% __`date`__ [ DateWrapper | numeric ]
% >
% IRIS date whose frequency will be tested against the other input argument
% `frequency`; the `date` can be either a DateWrapper object or a plain
% numeric date.
%
%
% __`frequency`__ [ Frequency | numeric ]
% >
% IRIS frequency against which the `date` will be tested; the `frequency`
% can be either a Frequency object or a plain numeric frequency.
%
%
% ## Output Arguments ##
%
%
% __`flag`__ [ logical ]
% >
% True for dates whose frequencies match the specified `frequency`.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function flag = isfreq(date, freq)

%--------------------------------------------------------------------------

flag = dater.getFrequency(date)==round(freq);

end%




%
% Unit Tests 
%
%{
##### SOURCE BEGIN #####
% saveAs=dates/isfreqUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);


%% Test DateWrapper
    i = ii(100);
    y = yy(2000);
    h = hh(2000);
    q = qq(2000);
    m = mm(2000);
    w = ww(2000);
    d = dd(2000);
    x = [i, y, h, q, m, w, d];
    assertEqual(testCase, isfreq(x, Frequency.INTEGER), logical([1, 0, 0, 0, 0, 0, 0]));
    assertEqual(testCase, isfreq(x, Frequency.YEARLY), logical([0, 1, 0, 0, 0, 0, 0]));
    assertEqual(testCase, isfreq(x, Frequency.HALFYEARLY), logical([0, 0, 1, 0, 0, 0, 0]));
    assertEqual(testCase, isfreq(x, Frequency.QUARTERLY), logical([0, 0, 0, 1, 0, 0, 0]));
    assertEqual(testCase, isfreq(x, Frequency.MONTHLY), logical([0, 0, 0, 0, 1, 0, 0]));
    assertEqual(testCase, isfreq(x, Frequency.WEEKLY), logical([0, 0, 0, 0, 0, 1, 0]));
    assertEqual(testCase, isfreq(x, Frequency.DAILY), logical([0, 0, 0, 0, 0, 0, 1]));



%% Test Numeric
    i = 100;
    y = numeric.yy(2000);
    h = numeric.hh(2000);
    q = numeric.qq(2000);
    m = numeric.mm(2000);
    w = numeric.ww(2000);
    d = numeric.dd(2000);
    x = [i, y, h, q, m, w, d];
    assertEqual(testCase, isfreq(x, 0), logical([1, 0, 0, 0, 0, 0, 0]));
    assertEqual(testCase, isfreq(x, 1), logical([0, 1, 0, 0, 0, 0, 0]));
    assertEqual(testCase, isfreq(x, 2), logical([0, 0, 1, 0, 0, 0, 0]));
    assertEqual(testCase, isfreq(x, 4), logical([0, 0, 0, 1, 0, 0, 0]));
    assertEqual(testCase, isfreq(x, 12), logical([0, 0, 0, 0, 1, 0, 0]));
    assertEqual(testCase, isfreq(x, 52), logical([0, 0, 0, 0, 0, 1, 0]));
    assertEqual(testCase, isfreq(x, 365), logical([0, 0, 0, 0, 0, 0, 1]));

##### SOURCE END #####
%}

