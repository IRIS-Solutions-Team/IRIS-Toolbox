% grow  Cumulate time series at specified growth rates or differences
%{
% Syntax
%--------------------------------------------------------------------------
%
% Input arguments marked with a `~` sign may be omitted
%
%     outputSeries = grow(inputSeries, operator, changeSeries, dates, ~shift)
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
% __`operator`__ [ `"diff"` | `"roc"` | `"pcr"` ]
%
%>    Function expressing the relationship between the resulting
%>    `outputSeries` and the input `changeSeries` series.
%
%
% __`changeSeries`__ [ Series | numeric ] 
%
%>    Time series or numeric scalar specifying the change in the input time
%>    series (difference, gross rate of change, or percent change, see the
%>    input argument `operator`).
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
%>    Negative number specifying the lag of the base period to which the change
%>    `operator` function applies.
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
% Options
%--------------------------------------------------------------------------
%
% __`Direction="Forward"`__ [ `"Forward"` | `"Backward"` ]
% 
%>    Direction of calculations in time; `Direction="Backward"` means that
%>    the calculations start from the last date in `dates` going backwards
%>    to the first one, and an inverse operator is applied.
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

% >=R2019b
%{
function this = grow(this, operator, growth, dates, shift, opt)

arguments
    this NumericTimeSubscriptable
    operator {validate.anyString(operator, ["*", "+", "/", "-", "diff", "roc", "pct"])}
    growth {locallyValidateGrowth(growth)}
    dates {validate.properDates(dates)}
    shift {locallyValidateShift(shift)} = -1

    opt.Direction (1, 1) string {validate.anyString(opt.Direction, ["forward", "backward"])} = "forward" 
end
%}
% >=R2019b

% <=R2019a
%(
function this = grow(this, operator, growth, dates, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('@Series/grow');
    addRequired(pp, 'inputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    addRequired(pp, 'operator', @(x) validate.anyString(x, ["*", "+", "/", "-", "diff", "roc", "pct"]) || isa(x, 'function_handle'));
    addRequired(pp, 'growth', @locallyValidateGrowth);
    addRequired(pp, 'dates', @DateWrapper.validateProperDateInput);
    addOptional(pp, 'shift', -1, @locallyValidateShift);

    addParameter(pp, "Direction", "Forward", @(x) any(strcmpi(x, ["Forward", "Backward"])));

    % Legacy option
    addParameter(pp, 'BaseShift', @auto, @(x) isequal(x, @auto) || validate.roundScalar(x, -intmax( ), -1));
end
opt = parse(pp, this, operator, growth, dates, varargin{:});
if isequal(opt.BaseShift, @auto)
    shift = pp.Results.shift;
else
    % Legacy option
    shift = opt.BaseShift;
end
%)
% <=R2019a

if startsWith(opt.Direction, "backward", "ignoreCase", true)
    shift = -shift;
end

%--------------------------------------------------------------------------

func = locallyChooseFunction(operator, opt.Direction);

dates = reshape(double(dates), 1, [ ]);
shift = dater.resolveShift(dates, shift);
datesShifted = dater.plus(dates, shift);
startAll = min([dates, datesShifted]);
endAll = max([dates, datesShifted]);

% Get level data
levelData = getDataFromTo(this, startAll, endAll);
sizeLevelData = size(levelData);
levelData = levelData(:, :);

% Get growth rate data
if isa(growth, 'NumericTimeSubscriptable')
    growthData = getDataFromTo(growth, startAll, endAll);
    growthData = growthData(:, :);
else
    growthData = repmat(growth, size(levelData));
end


%==========================================================================
posDates = round(dates - startAll + 1);
posDatesShifted = round(datesShifted - startAll + 1);
if strcmpi(opt.Direction, "Forward")
    posDatesGrowth = posDates;
else
    posDates = fliplr(posDates);
    posDatesShifted = fliplr(posDatesShifted);
    posDatesGrowth = posDatesShifted;
end

for i = 1 : numel(posDates)
    levelData(posDates(i), :) ...
        = func(levelData(posDatesShifted(i), :), growthData(posDatesGrowth(i), :));
end
%==========================================================================


hereCheckMissingObs( );

% Reshape output data back
if numel(sizeLevelData)>2
    levelData = reshape(levelData, [size(levelData, 1), sizeLevelData(2:end)]);
end

% Update output series
this = setData(this, dater.colon(startAll, endAll), levelData);

return

    function hereCheckMissingObs( )
        inxMissing = any(this.MissingTest(levelData(posDates, :)), 2);
        if ~any(inxMissing)
            return
        end
        report = join(dater.toDefaultString(dates(inxMissing)));
        throw(exception.Base([ 
            "Series:OutputWithMissingObs"
            "Output time series resulted in missing observations "
            "in some columns in these periods: %s"
        ], "warning"), report);
    end%
end%

%
% Local Functions
%

function func = locallyChooseFunction(operator, direction)
    %(
    if isa(operator, "function_handle")
        func = operator;
    else
        switch string(operator)
            case {"*", "roc"}
                if strcmpi(direction, "Forward")
                    func = @times;
                else
                    func = @rdivide;
                end
            case {"+", "diff"}
                if strcmpi(direction, "Forward")
                    func = @plus;
                else
                    func = @minus;
                end
            case "/"
                func = @rdivide;
            case "-"
                func = @minus;
            case "pct"
                if strcmpi(direction, "Forward")
                    func = @(x, y) x.*(1 + y/100);
                else
                    func = @(x, y) x./(1 + y/100);
                end
        end
    end
    %)
end%


function locallyValidateGrowth(input)
    %(
    if isa(input, 'NumericTimeSubscriptable') || validate.numericScalar(input)
        return
    end
    error("Validation:Failed", "Input value must be a time series or a numeric scalar");
    %)
end%


function locallyValidateShift(input)
    %(
    if validate.roundScalar(input, -Inf, -1) || validate.anyString(input, ["YoY", "EoPY", "BoY"])
        return
    end
    error("Validation:Failed", "Input value must be a negative integer or one of {""YoY"", ""EoPY"", ""BoY""}");
    %)
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


%% Test Grow with Shift=-4

x = Series(qq(2001,1):qq(2010,4), @rand);
g = 1 + Series(qq(2005,1):qq(2020,4), @rand) / 10;

y = grow(x, '*', g, g.Range, -4);
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

