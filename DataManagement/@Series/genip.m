function ...
    [output, info, Xi] ...
    = genip(lowInput, highFreq, transitionOrder, aggregationModel, varargin)

if isempty(lowInput)
    output = lowInput;
    info = struct();
    return
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser();
    pp.KeepDefaultOptions = true;

    addRequired(pp, 'lowInput', @(x) isa(x, 'Series'));
    addRequired(pp, 'highFreq', @(x) isa(x, 'Frequency') || isnumeric(x));
    addRequired(pp, 'order', @(x) isequal(x, 0) || isequal(x, 1) || isequal(x, 2) || validate.anyString(x, 'level', 'diff', 'diffDiff'));
    addRequired(pp, 'aggregation', @(x) local_validateAggregation(x));

    % Options
    addParameter(pp, 'Range', Inf, @(x) isequal(x, Inf) || validate.properRange(x));
    addParameter(pp, 'Initials', @auto, @(x) isequal(x, @auto) || isnumeric(x) || isa(x, 'Series'));
    addParameter(pp, 'ResolveConflicts', true, @validate.logicalScalar);

    % Nested options
    addParameter(pp, 'TransitionIntercept', 0, @(x) isequal(x, @auto) || validate.numericScalar(x));
    % addParameter(pp, 'Transition_Rate', 1, @(x) isequal(x, @auto) || validate.numericScalar(x));
    addParameter(pp, 'TransitionStd', 1, @(x) isequal(x, 1) || isa(x, 'Series'));

    addParameter(pp, 'HardLevel', [ ], @(x) isempty(x) || isa(x, 'Series'));
    addParameter(pp, 'HardDiff', [ ], @(x) isempty(x) || isa(x, 'Series'));
    addParameter(pp, 'HardRate', [ ], @(x) isempty(x) || isa(x, 'Series'));

    %{
    addParameter(pp, 'SoftLevel', [ ], @(x) isempty(x) || isa(x, 'Series'));
    addParameter(pp, 'SoftDiff', [ ], @(x) isempty(x) || isa(x, 'Series'));
    addParameter(pp, 'SoftRate', [ ], @(x) isempty(x) || isa(x, 'Series'));
    %}

    addParameter(pp, 'IndicatorModel', 'Difference', @(x) (ischar(x) || isstring(x)) && startsWith(x, ["diff", "rat"], "ignoreCase", true));
    addParameter(pp, 'IndicatorLevel', [ ], @(x) isempty(x) || isa(x, 'Series'));
end
%)

[skip, opt] = maybeSkip(pp, varargin{:});
if ~skip
    opt = parse(pp, lowInput, highFreq, transitionOrder, aggregationModel, varargin{:});
end


transition = struct();
transition = local_resolveTransitionModel(transition, transitionOrder);

%
% Resolve source frequency and the conversion factor
%
[fromFreq, numWithin] = here_resolveFrequencyConversion();


%
% Define low-frequency dates
% 
lowRange = double(opt.Range);
if isequal(lowRange, Inf)
    lowRange = lowInput.RangeAsNumeric;
end
lowStart = lowRange(1);
lowEnd = lowRange(end);
numLowPeriods = round(lowEnd - lowStart + 1);

%
% Define high-frequency dates
%
highStart = dater.convert(lowStart, highFreq, "--skip");
highEnd = dater.convert(lowEnd, highFreq, 'ConversionMonth', 'Last', "--skip");

%
% Get low-frequency level data
%
lowLevel = getDataFromTo(lowInput, lowStart, lowEnd);


%
% Resolve Aggregation 
%
aggregation = series.genip.prepareAggregation(aggregationModel, numLowPeriods, numWithin);


%
% Resolve Indicator=, Transition= and Hard= options
%
transition = series.genip.prepareTransitionOptions(transition, aggregation, [highStart, highEnd], lowLevel, opt);
indicator = series.genip.prepareIndicatorOptions(transition, [ ], [highStart, highEnd], [ ], opt);
hard = series.genip.prepareHardOptions(transition, [ ], [highStart, highEnd], [ ], opt);


numInit = transition.NumInit;
if ~isempty(hard.Level) && all(isfinite(hard.Level))
    outputData = hard.Level;
    inxRunLow = true(1, numLowPeriods);
    stacked = [ ];
else
    %
    % Resolve conflicts between observed low frequency levels and conditioning
    %
    here_resolveConflictsInMeasurement();

    [inxRunLow, inxRunHigh, inxInit, lowLevel, hard, indicator] = ...
        local_clipRange(lowLevel, hard, indicator, transition, aggregation);

    here_checkIndicatorForNaNs();

    Xi0 = series.genip.prepareInitialCondition( ...
        transition, hard, [highStart, highEnd], inxInit, opt ...
    );

    [stacked, Y, Xi0, transition, indicator] = ...
        series.genip.setupStackedSystem(lowLevel, aggregation, transition, hard, indicator, Xi0);

    %
    % Run stacked-time Kalman smoother
    %
    [Xi, Xi0] = stackedSmoother(stacked, Y, Xi0);

    if isequal(transition.Intercept, @auto)
        transition.Intercept = Xi0(end);
        Xi0(end) = [];
    end

    %
    % Compose output data from Xi0, HardLevel and adjust for
    % IndicatorLevel if needed.
    %
    outputData = here_composeOutputData();
end


%
% Create output time series
%
highExtStart = dater.plus(highStart, -numInit);
output = Series(highExtStart, outputData);


%
% Create output information struct if requested
%
info = struct();
if nargout>=2
    wholeRange = opt.Range(1) : opt.Range(end);
    info.Initials = Xi0(end:-1:1);
    info.LowFreq = fromFreq;
    info.HighFreq = highFreq;
    info.LowRange = Dater(lowStart):Dater(lowEnd);
    info.HighRange = Dater(highStart):Dater(highEnd);
    info.EffectiveLowRange = wholeRange(inxRunLow);
    % info.TransitionRate = transition.Rate;
    info.TransitionIntercept = transition.Intercept;
    info.StackedSystem = stacked;
    info.NumYearsStacked = nnz(inxRunLow);
end

return

    function [fromFreq, numWithin] = here_resolveFrequencyConversion()
        %(
        fromFreq = lowInput.Frequency;
        if double(highFreq)<=double(fromFreq)
            thisError = [ 
                "Series:CannotInterpolateToLowerFreq"
                "Series can only be interpolated from a lower to a higher frequency. "
                "You are attempting to interpolate from %s to %s." 
            ];
            throw(exception.Base(thisError, 'error'), char(fromFreq), char(highFreq));
        end
        numWithin = double(highFreq)/double(fromFreq);
        if numWithin~=round(numWithin)
            thisError = [ 
                "Series:CannotInterpolateToLowerFreq"
                "Function genip() can only be used to interpolate between "
                "YEARLY, HALFYEARLY, QUARTERLY and MONTHLY frequencies. "
                "You are attempting to interpolate from %s to %s." 
            ];
            throw(exception.Base(thisError, 'error'), char(fromFreq), char(highFreq));
        end
        %)
    end%


    function here_resolveConflictsInMeasurement()
        %(
        if ~opt.ResolveConflicts
            return
        end
        % Aggregate vs hard level
        if ~isempty(hard.Level) && any(isfinite(hard.Level))
            inxAggregation = aggregation.Model~=0;
            temp = reshape(hard.Level(numInit+1:end, :), numWithin, [ ]);
            temp = temp(inxAggregation, :);
            inxLowLevel = reshape(isfinite(lowLevel), 1, [ ]);
            inxHighLevel = all(isfinite(temp), 1);
            inxToResolve = inxLowLevel & inxHighLevel;
            if any(inxToResolve)
                lowLevel(inxToResolve) = NaN;
            end
        end
        %)
    end%


    function here_checkIndicatorForNaNs()
        %(
        if ~isempty(indicator.Level) && ~all(isfinite(indicator.Level))
            thisError = [
                "Genip:MissingObservationsIndicator"
                "Time series supplied as Indicator.Level= must have observations "
                "avaliable for the entire higher-frequency interpolation range "
                "plus the initial conditions as given by the difference order. "
                ];
            throw(exception.Base(thisError, 'error'));
        end
        %)
    end%


    function outputData = here_composeOutputData()
        %(
        outputData = Xi(end:-1:1);
        if ~isempty(indicator.Level)
            if indicator.Model=="difference"
                outputData = outputData + indicator.Level;
            elseif indicator.Model=="ratio"
                outputData = outputData .* indicator.Level;
            end
        end
        if any(~inxRunHigh)
            x__ = outputData;
            outputData = hard.LevelUnclipped;
            outputData(inxRunHigh) = x__;
        end
        % Remove ill-identified initial conditions from the output data
        outputData(1:numInit-transition.Order) = NaN;
        %)
    end%
end%

%
% Local Validation and Resolution
%

function flag = local_validateAggregation(x)
%(
    if any(strcmpi(char(x), {'sum', 'average', 'mean', 'last'}))
        flag = true;
        return
    end
    if isnumeric(x)
        flag = true;
        return
    end
    flag = false;
%)
end%


function transition = local_resolveTransitionModel(transition, transitionOrder)
%(
    if isnumeric(transitionOrder)
        transition.Order = transitionOrder;
        return
    end
    transitionOrder = strip(string(transitionOrder));
    if strcmpi(transitionOrder, "Level")
        transition.Order = 0;
    elseif strcmpi(transitionOrder, "Diff")
        transition.Order = 1;
    elseif strcmpi(transitionOrder, "DiffDiff")
        transition.Order = 2;
    end
%)
end%

%
% Local Functions
%

function [inxRunLow, inxRunHigh, inxInit, lowLevel, hard, indicator] = ...
    local_clipRange(lowLevel, hard, indicator, transition, aggregation)
    %
    % If the hard conditions are available for a continuous span of dates
    % from the beginning of the interpolation range, and/or backwards from
    % the end of the interpolation range, clip the Kalman filter range to a
    % subset of inner years.
    %
    %(
    numInit = transition.NumInit;
    numLowPeriods = size(lowLevel, 1);
    numWithin = size(aggregation.Model, 2);
    numHighPeriods = numWithin*numLowPeriods;

    inxRunLow = true(1, numLowPeriods);
    inxRunHigh = true(1, numHighPeriods+numInit);
    inxInit = [true(1, numInit), false(1, numHighPeriods)];
    hard.LevelUnclipped = hard.Level;

    if isempty(hard.Level)
        return
    end

    x__ = reshape(hard.Level(numInit+1:end), numWithin, [ ]);
    inxFull = all(isfinite(x__), 1);

    lastFull = find(~inxFull, 1, 'first') - 1; % [^1]
    if ~isempty(lastFull) && lastFull>1
        inxRunLow(1:lastFull-1) = false;
        inxRunHigh(1:(lastFull-1)*numWithin) = false;
        inxInit = circshift(inxInit, [0, (lastFull-1)*numWithin]);
    end
    % [^1]: `lastFull` is the column of the last year that has all
    % observations, counting only the uninterrupted sequence of
    % full-observation years from the beginning. This last full year will
    % be included in clipped range (because it may be needed for initial
    % condition).

    firstFull = find(~inxFull, 1, 'last') + 1;
    if ~isempty(firstFull) && firstFull<numLowPeriods
        numLowRemove = numLowPeriods - firstFull;
        numHighRemove = numLowRemove*numWithin;
        inxRunLow(end-numLowRemove+1:end) = false;
        inxRunHigh(end-numHighRemove+1:end) = false;
    end

    if any(~inxRunLow)
        lowLevel = lowLevel(inxRunLow);
        hard.Level = hard.Level(inxRunHigh);
        if ~isempty(indicator.Level)
            indicator.Level = indicator.Level(inxRunHigh);
        end
        if ~isempty(hard.Diff)
            hard.Diff = hard.Diff(inxRunHigh);
        end
        if ~isempty(hard.Rate)
            hard.Rate = hard.Rate(inxRunHigh);
        end
    end
    %)
end%

