% Type `web Series/grow.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function this = grow(this, operator, change, dates, legacyShift, opt)

arguments
    this {local_validateLevelInput}
    operator {validate.anyString(operator, ["*", "+", "/", "-", "diff", "difflog", "roc", "pct"])}
    change {local_validateGrowthInput(change)}
    dates {validate.properDates(dates)}
    legacyShift (1, :) double {mustBeInteger} = double.empty(1, 0)

    opt.Direction (1, 1) string {validate.anyString(opt.Direction, ["forward", "backward"])} = "forward" 
    opt.Shift (1, 1) double {mustBeInteger} = -1
end
%}
% >=R2019b


% <=R2019a
%(
function this = grow(this, operator, change, dates, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addOptional(ip, "legacyShift", [], @isnumeric);

    addParameter(ip, "Direction", "forward");
    addParameter(ip, "Shift", -1);
end
parse(ip, varargin{:});
legacyShift = ip.Results.legacyShift;
opt = ip.Results;
%)
% <=R2019a


% Legacy positional argument
if isscalar(legacyShift) && opt.Shift==-1
    opt.Shift = legacyShift;
end


func = local_chooseFunction(operator, opt.Direction);

% Make sure dates run forward in time at this point
dates = reshape(double(dates), 1, [ ]);
dates = local_ensureRangeDirection(dates);

shift = dater.resolveShift(dates, opt.Shift);
if startsWith(opt.Direction, "b", "ignoreCase", true)
    % Backward direction
    shift = -shift;
end

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
if isa(change, 'Series')
    growthData = getDataFromTo(change, startAll, endAll);
    growthData = growthData(:, :);
else
    growthData = repmat(change, size(levelData));
end


%==========================================================================
posDates = round(dates - startAll + 1);
posDatesShifted = round(datesShifted - startAll + 1);
if startsWith(opt.Direction, "f", "ignoreCase", true)
    % Forward direction
    posDatesGrowth = posDates;
else
    % Backward direction
    posDates = fliplr(posDates);
    posDatesShifted = fliplr(posDatesShifted);
    posDatesGrowth = posDatesShifted;
end

for i = 1 : numel(posDates)
    levelData(posDates(i), :) ...
        = func(levelData(posDatesShifted(i), :), growthData(posDatesGrowth(i), :));
end
%==========================================================================


here_checkMissingObs( );

% Reshape output data back
if numel(sizeLevelData)>2
    levelData = reshape(levelData, [size(levelData, 1), sizeLevelData(2:end)]);
end

% Update output series
if isa(this, 'Series')
    this = setData(this, dater.colon(startAll, endAll), levelData);
else
    this = Series(startAll, levelData);
end

return

    function here_checkMissingObs( )
        if isa(this, 'Series')
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
% Local functions
%

function func = local_chooseFunction(operator, direction)
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


function dates = local_ensureRangeDirection(dates)
    %(
    if dates(1)>dates(end)
        dates = fliplr(dates);
    end
    %)
end%

%
% Local validators
%

function local_validateGrowthInput(input)
    %(
    if isa(input, 'Series') || validate.numericScalar(input)
        return
    end
    error("Validation:Failed", "Input value must be a time series or a numeric scalar");
    %)
end%


function local_validateShift(input)
    %(
    if validate.roundScalar(input, -Inf, -1) || validate.anyString(input, ["YoY", "EoPY", "BoY"])
        return
    end
    error("Validation:Failed", "Input value must be a negative integer or one of {""YoY"", ""EoPY"", ""BoY""}");
    %)
end%


function local_validateLevelInput(input)
    if isa(input, 'Series') || validate.numericScalar(input)
        return
    end
    error("Validation:Failed", "Input value for the level series must be a time series or a numeric scalar");
end%

