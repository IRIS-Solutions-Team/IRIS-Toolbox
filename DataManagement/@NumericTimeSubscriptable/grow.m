% Type `web Series/grow.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function this = grow(this, operator, change, dates, shift, opt)

arguments
    this {locallyValidateLevelInput}
    operator {validate.anyString(operator, ["*", "+", "/", "-", "diff", "difflog", "roc", "pct"])}
    change {locallyValidateGrowthInput(change)}
    dates {validate.properDates(dates)}
    shift {locallyValidateShift(shift)} = -1

    opt.Direction (1, 1) string {validate.anyString(opt.Direction, ["forward", "backward"])} = "forward" 
end
%)
% >=R2019b


% <=R2019a
%{
function this = grow(this, operator, change, dates, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('@Series/grow');
    addRequired(pp, 'level', @locallyValidateLevelInput);
    addRequired(pp, 'operator', @(x) validate.anyString(x, ["*", "+", "/", "-", "diff", "roc", "pct"]) || isa(x, 'function_handle'));
    addRequired(pp, 'change', @locallyValidateGrowthInput);
    addRequired(pp, 'dates', @validate.properDate);
    addOptional(pp, 'shift', -1, @locallyValidateShift);

    addParameter(pp, "Direction", "Forward", @(x) any(strcmpi(x, ["Forward", "Backward"])));

    % Legacy option
    addParameter(pp, 'BaseShift', @auto, @(x) isequal(x, @auto) || validate.roundScalar(x, -intmax( ), -1));
end
opt = parse(pp, this, operator, change, dates, varargin{:});
if isequal(opt.BaseShift, @auto)
    shift = pp.Results.shift;
else
    % Legacy option
    shift = opt.BaseShift;
end
%}
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
if isnumeric(this)
    numPeriods = round(endAll - startAll + 1);
    sizeGrowth = size(change.Data);
    levelData = repmat(this, [numPeriods, sizeGrowth(2:end)]);
else
    levelData = getDataFromTo(this, startAll, endAll);
end
sizeLevelData = size(levelData);
levelData = levelData(:, :);

% Get change rate data
if isa(change, 'NumericTimeSubscriptable')
    growthData = getDataFromTo(change, startAll, endAll);
    growthData = growthData(:, :);
else
    growthData = repmat(change, size(levelData));
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
if isa(this, 'NumericTimeSubscriptable')
    this = setData(this, dater.colon(startAll, endAll), levelData);
else
    this = Series(startAll, levelData);
end

return

    function hereCheckMissingObs( )
        if isa(this, 'NumericTimeSubscriptable')
            missingTest = this.MissingTest;
        else
            missingTest = @isnan;
        end
        inxMissing = any(missingTest(levelData(posDates, :)), 2);
        if ~any(inxMissing)
            return
        end
        report = join(dater.toDefaultString(dates(inxMissing)));
        exception.warning([
            "Series:OutputWithMissingObs"
            "Output time series resulted in missing observations "
            "in some columns in these periods: %s"
        ], report);
    end%
end%

%
% Local Functions
%

function func = locallyChooseFunction(operator, direction)
    %(
    if isa(operator, 'function_handle')
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
            case "difflog"
                func = @(x, y) x.*exp(y);
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


function locallyValidateGrowthInput(input)
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
% Local Validators
%

function locallyValidateLevelInput(input)
    if isa(input, 'NumericTimeSubscriptable') || validate.numericScalar(input)
        return
    end
    error("Validation:Failed", "Input value for the level series must be a time series or a numeric scalar");
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

