% roc  Gross rate of change
%{
% Syntax
%--------------------------------------------------------------------------
%
% Input arguments marked with a `~` sign may be omitted
%
%     x = roc(x, ~shift, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`x`__ [ Series ]
%
%>    Input time series.
%
%
% __`~shift=-1`__ [ numeric | `"YoY"` | `"BoY"` | `"EoLY"` ]
% 
%>    Time shift (lag or lead) over which the rate of change will be computed,
%>    i.e. between time t and t+k; the `shift` specified as `"YoY"`, `"BoY"` or
%>    `"EoLY"` means year-on-year changes, changes relative to the beginning of
%>    current year, or changes relative to the end of previous year,
%>    respectively (these do not work with `INTEGER` date frequency).
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`x`__ [ Series ]
%
%>    Percentage rate of change in the input data.
%
%
% Options
%--------------------------------------------------------------------------
%
% __`'OutputFreq='`__ [ *empty* | Frequency ]
%
%>    Convert the rate of change to the requested date
%>    frequency; empty means plain rate of change with no conversion.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%-----------------------
%
% Here, `x` is a monthly time series. The following command computes the
% rate of change between month t and t-1:
%
%     roc(x, -1)
%
% The following line computes the rate of change between
% month t and t-3:
%
%     roc(x, -3)
%
%
% Example
%--------------------------------------------------------------------------
%
% In this example, `xm` is a monthly time series and `xq` is a quarterly
% series. The following pairs of commands are equivalent for calculating
% the year-over-year rates of change:
% 
%     roc(xm, -12)
%     roc(xm, 'YoY')
%
% and
%
%     roc(xq, -4)
%     roc(xq, 'YoY')
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

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
