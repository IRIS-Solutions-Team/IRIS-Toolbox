% Type `web Series/regress.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function [b, stdB, e, stdE, fit, dates, covB] = regress(lhs, rhs, legacyDates, opt)

arguments
    lhs Series
    rhs Series

    % Legacy positional argument
    legacyDates double = [] 

    opt.Dates double = Inf
    opt.Intercept (1, 1) logical = false
        opt.Constant__Intercept = []
    opt.Weights {local_validateWeights} = []
end
%}
% >=R2019b


% <=R2019a
%(
function [b, stdB, e, stdE, fit, dates, covB] = regress(lhs, rhs, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addOptional(ip, "legacyDates", [], @isnumeric);

    addParameter(ip, "Dates", Inf);
    addParameter(ip, "Intercept", false);
        addParameter(ip, "Constant__Intercept", []);
    addParameter(ip, "Weights", []);
end
parse(ip, varargin{:});
legacyDates = ip.Results.legacyDates;
opt = ip.Results;
%)
% <=R2019a


opt = iris.utils.resolveOptionAliases(opt, [], true);


%( Legacy input arguments
if ~isempty(legacyDates) && isnumeric(legacyDates)
    exception.warning([
        "Deprecated"
        "Specifying the regression dates as a third positional input argument "
        "is deprecated, and will be disallowed in a future release. "
        "Use the option Dates= instead."
    ]);
    opt.Dates = double(legacyDates);
end
%)


dates = double(opt.Dates);
checkFrequency(lhs, dates);
[dataY, dates] = getData(lhs, dates);
dates = double(dates);
checkFrequency(rhs, dates);
dataX = getData(rhs, dates);
if opt.Intercept
    dataX(:, end+1) = 1;
end

if isempty(opt.Weights)
    inxRows = all(~isnan([dataX, dataY]), 2);
    [b, stdB, eVar, covB] = lscov(dataX(inxRows, :), dataY(inxRows, :));
else
    checkFrequency(opt.Weights, dates);
    dataWeights = getData(opt.Weights, dates);
    inxRows = all(~isnan([dataX, dataY, dataWeights]), 2);
    [b, stdB, eVar, covB] = lscov(dataX(inxRows, :), dataY(inxRows, :), dataWeights(inxRows, :));
end
stdE = sqrt(eVar);

if nargout>2
    dataFit = dataX*b;
    dataE = dataY - dataFit;
    e = lhs.empty(lhs);
    e = setData(e, dates, dataE);
    e = resetComment(e);
    if nargout>4
        fit = lhs.empty(lhs);
        fit = setData(fit, dates, dataFit);
        fit = resetComment(fit);
    end
end

end%

%
% Local validators
%

function local_validateWeights(x)
    %(
    if isempty(x) || isa(x, 'Series')
        return
    end
    error("Input value must be empty or a time series.");
    %)
end%




%
% Unit tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Series/regressUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up once

d = struct();
d.x = Series(qq(2020,1), rand(10000,1));
d.y = Series(qq(2020,1), rand(10000,1));
d.z = Series(qq(2020,1), rand(10000,1));
d.e = Series(qq(2020,1), 0.1*randn(10000,1));

d.a = 1;
d.b = -1;
d.c = 0.5;

d.lhs = d.a*d.x + d.b*d.y + d.c*d.z + d.e;

range = getRange(d.x);
range1 = range(1:5000);
range2 = range(5001:end);
d.lhsw = [ 
    0.5*d.a*d.x{range1} + 0.5*d.b*d.y{range1} + 0.5*d.c*d.z{range1} + d.e{range1}
    d.a*d.x{range2} + d.b*d.y{range2} + d.c*d.z{range2} + d.e{range2}
];

d.w = Series();
d.w(range1) = 1;
d.w(range2) = 3;


%% Test vanilla   

est = regress(d.lhs, [d.x, d.y, d.z]);
assertEqual(testCase, round(est(1), 1), round(d.a, 1));
assertEqual(testCase, round(est(2), 1), round(d.b, 1));
assertEqual(testCase, round(est(3), 1), round(d.c, 1));


%% Test dates   

est = regress(d.lhs, [d.x, d.y, d.z]);
est1 = regress(d.lhs, [d.x, d.y, d.z], 'dates', Inf);
est2 = regress(d.lhs, [d.x, d.y, d.z], 'dates', qq(2020,1)+(0:5000));

assertEqual(testCase, est, est1);
assertNotEqual(testCase, round(est(1), 5), round(est2(1), 5));
assertNotEqual(testCase, round(est(2), 5), round(est2(2), 5));
assertNotEqual(testCase, round(est(3), 5), round(est2(3), 5));


%% Test weights   

estw1 = regress(d.lhsw, [d.x, d.y, d.z]);
estw2 = regress(d.lhsw, [d.x, d.y, d.z], 'weights', d.w);
assertGreaterThan(testCase, abs(estw1(1)-d.a), abs(estw2(1)-d.a));
assertGreaterThan(testCase, abs(estw1(2)-d.b), abs(estw2(2)-d.b));
assertGreaterThan(testCase, abs(estw1(3)-d.c), abs(estw2(3)-d.c));


##### SOURCE END #####
%}
