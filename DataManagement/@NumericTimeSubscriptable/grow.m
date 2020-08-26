% grow  Cumulate time series at specified growth rates or differences
%{
% Syntax
%--------------------------------------------------------------------------
%
% Input arguments marked with a `~` sign may be omitted
%
%     outputSeries = grow(inputSeries, operator, growth, dates, ~shift)
%
%
% Input arguments
%--------------------------------------------------------------------------
%
% __`inputSeries`__ [ Series ] 
%
%>    Input time series including at least the initial condition for the level.
%
%
% __`operator`__ [ `*` | `+` | `/` | `-` | function_handle ] 
%
%>    Operator applied to cumulate the time series.
%
%
% __`growth`__ [ Series | numeric ] 
%
%>    Time series or numeric scalar specifying the growth rates or differences.
%
%
% __`dates`__ [ DateWrapper ] 
%
%>    Date range or a vector of dates on which the level series will be
%>    cumulated.
%
%
% __`shift=-1`__ [ numeric ]
%
%>    Negative number specifying the lag of the base period to which the growth
%>    rates apply.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`outputSeries`__ [ Series ] 
%
%>    Output time series constructed from the input time series, `inputSeries`, extended by
%>    its growth rates or differences, `growth`.
%
%
% Description
%--------------------------------------------------------------------------
%
% The function `grow(~)` calculates new values at `dates` (which may not
% constitute a continuous range, and be discrete time periods instead)
% using one of the the following formulas (depending on the `operator`):
%
% * $$ x_t = x_{t-k} \cdot g_t $$
%
% * $$ x_t = x_{t-k} + g_t $$
%
% * $$ x_t = x_{t-k} / g_t $$
%
% * $$ x_t = x_{t-k} - g_t $$
%
% where $$ k $$ is a time lag specified by the option `BaseShift=`, and the
% values $$ g_t $$ are given by the second input series `growth`.
% Alternatively, the operator applied to $$ x_{t-k} $$ and $$ g_t $$ can be
% any user-specified function.
%
% Any values contained in the input time series `inputSeries` outside the
% `dates` are preserved in the output time series unchanged.
%
%
% Example
%--------------------------------------------------------------------------
%
% Extend a quarterly time series `x` using the gross rates of growth calculated
% from another time series, `y`:
%
%     >> x = grow(x, '*', roc(y), qq(2020,1):qq(2030,4));
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function this = grow(this, operator, growth, dates, varargin)

%( Input pp
persistent pp
if isempty(pp)
    pp = extend.InputParser('@Series/grow');
    addRequired(pp, 'inputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    addRequired(pp, 'operator', @(x) validate.anyString(x, ["*", "+", "/", "-", "diff", "roc", "pct"]) || isa(x, "function_handle"));
    addRequired(pp, 'growth', @(x) isa(x, 'NumericTimeSubscriptable') || validate.numericScalar(x));
    addRequired(pp, 'dates', @DateWrapper.validateProperDateInput);
    addOptional(pp, 'shift', -1, @(x) validate.roundScalar(x, -intmax( ), -1) || validate.anyString(x, ["YoY", "EoPY", "BoY"]));

    % Legacy option
    addParameter(pp, 'BaseShift', @auto, @(x) isequal(x, @auto) || validate.roundScalar(x, -intmax( ), -1));
end
%)
opt = parse(pp, this, operator, growth, dates, varargin{:});
if isequal(opt.BaseShift, @auto)
    shift = pp.Results.shift;
else
    % Legacy option
    shift = opt.BaseShift;
end

%--------------------------------------------------------------------------

if isa(operator, "function_handle")
    func = operator;
else
    switch string(operator)
        case {"*", "roc"}
            func = @times;
        case {"+", "diff"}
            func = @plus;
        case "/"
            func = @rdivide;
        case "-"
            func = @minus;
        case "pct"
            func = @(x, y) x.*(1 + y/100);
    end
end

dates = reshape(double(dates), 1, [ ]);
shift = DateWrapper.resolveShift(dates, shift);
datesShifted = dater.plus(dates, shift);
startAll = min([dates, datesShifted]);
endAll = max([dates, datesShifted]);

% Get level data
xData = getDataFromTo(this, startAll, endAll);
sizeX = size(xData);
xData = xData(:, :);

% Get growth rate data
if isa(growth, 'NumericTimeSubscriptable')
    growthData = getDataFromTo(growth, startAll, endAll);
    growthData = growthData(:, :);
else
    growthData = repmat(growth, size(xData));
end


% /////////////////////////////////////////////////////////////////////////
posDates = round(dates - startAll + 1);
posDatesShifted = round(datesShifted - startAll + 1);
for i = 1 : numel(posDates)
    xData(posDates(i), :) = func(xData(posDatesShifted(i), :), growthData(posDates(i), :));
end
% /////////////////////////////////////////////////////////////////////////

hereCheckMissingObs( );

% Reshape output data back
if numel(sizeX)>2
    xData = reshape(xData, [size(xData, 1), sizeX(2:end)]);
end

% Update output series
this = setData(this, dater.colon(startAll, endAll), xData);

return

    function hereCheckMissingObs( )
        inxFinite = all(isfinite(xData(posDates, :)), 2);
        if all(inxFinite)
            return
        end
        report = join(dater.toDefaultString(dates(inxFinite)));
        throw(exception.Base([ 
            "Series:OutputWithMissingObs"
            "Output time series contains Inf or NaN observations "
            "in these periods: %s"
        ], "warning"), report);
    end%
end%



%
% Unit Tests 
%
%{
##### SOURCE BEGIN #####
% saveAs=Series/growUnitTest.m

% Set Up Once
this = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

%% Test Grow Default Multiplicative
    x = Series(qq(2001,1):qq(2010,4), @rand);
    g = 1 + Series(qq(2005,1):qq(2020,4), @rand) / 10;
    y = grow(x, '*', g, g.Range);
    z = y / y{-1};
    assertEqual(this, y.Start, x.Start, 'AbsTol', 1e-10);
    assertEqual(this, y.End, g.End, 'AbsTol', 1e-10);
    assertEqual(this, z(g.Range), g(g.Range), 'AbsTol', 1e-10);


%% Test Grow Default Additive

x = Series(qq(2001,1):qq(2010,4), @rand);
g = 1 + Series(qq(2005,1):qq(2020,4), @rand) / 10;

y = grow(x, '+', g, g.Range);
z = y - y{-1};

assertEqual(this, y.Start, x.Start, 'AbsTol', 1e-10);
assertEqual(this, y.End, g.End, 'AbsTol', 1e-10);
assertEqual(this, z(g.Range), g(g.Range), 'AbsTol', 1e-10);


%% Test Grow with BaseShift=-4

x = Series(qq(2001,1):qq(2010,4), @rand);
g = 1 + Series(qq(2005,1):qq(2020,4), @rand) / 10;

y = grow(x, '*', g, g.Range, 'BaseShift=', -4);
z = y / y{-4};

assertEqual(this, y.Start, x.Start, 'AbsTol', 1e-10);
assertEqual(this, y.End, g.End, 'AbsTol', 1e-10);
assertEqual(this, z(g.Range), g(g.Range), 'AbsTol', 1e-10);


%% Test Grow with Discrete Dates

x = Series(qq(2001,1):qq(2010,4), @rand);
g = 1 + Series(qq(2005,1):qq(2010,4), @rand) / 10;

dates = qq(2005,1) : 3 : qq(2010,4);
y = grow(x, '*', g, dates);
z = roc(y);

assertEqual(this, y.Start, x.Start, 'AbsTol', 1e-10);
assertEqual(this, y.End, g.End, 'AbsTol', 1e-10);
assertEqual(this, z(dates), g(dates), 'AbsTol', 1e-10);

z1 = z;
z(dates) = -9999;
assertNotEqual(this, round(z(g.Range), 8), round(g(g.Range), 8));

##### SOURCE END #####
%}
