function this = roc(this, shift, varargin)

if isempty(this.Data)
    return
end

try, shift;
    catch, shift = -1;
end

[shift, power] = dater.resolveShift(getRangeAsNumeric(this), shift, varargin{:});


%==========================================================================
this = unop(@series.change, this, 0, @rdivide, shift);
%==========================================================================


if power~=1
    this.Data = this.Data .^ power;
end

end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Series/rocUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up Once
x = Series(qq(2020,1):qq(2024,4), @rand);

%% Test Implicit -1
rx1 = roc(x);
rx2 = x/x{-1};
assertEqual(testCase, rx1.Data, rx2.Data, "absTol", 1e-10);

%% Test Explicit -4
rx1 = roc(x, -4);
rx2 = x/x{-4};
assertEqual(testCase, rx1.Data, rx2.Data, "absTol", 1e-10);

%% Test YoY
rx1 = roc(x, "YoY");
rx2 = x/x{-4};
assertEqual(testCase, rx1.Data, rx2.Data, "absTol", 1e-10);

%% Test EoPY
rx1 = roc(x, "EoPY");
rx2 = Series();
for t = reshape(x.Range, 1, [])
    t0 = qq(round(dater.getYearPeriodFrequency(t)-1), 4);
    rx2(t) = x(t) / x(t0);
end
assertEqual(testCase, rx1.Data, rx2.Data, "absTol", 1e-10);

##### SOURCE END #####
%}
