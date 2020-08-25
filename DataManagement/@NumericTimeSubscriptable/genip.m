% genip  Generalized indicator based interpolation
%{
% Syntax
%--------------------------------------------------------------------------
%
%>    [highOutput, info] = genip(lowInput, highFreq, order, aggregation, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`lowInput`__ [ Series ] 
%
%>    Low-frequency input series that will be interpolated to the `highFreq`
%>    frequency using the `Indicator`, hard conditions specified in `Hard=`,
%>    and soft conditions specified in `Soft=`.
%
%
% __`highFreq`__ [ Frequency ]
% 
%>    Target frequency to which the `lowInput` series will be interpolated;
%>    `highFreq` must be higher than the date frequency of the `lowInput`.
%
%
% __`order`__ [ `0` | `1` | `2` ]
%
%>    Autoregressive order of the transition equation for the dynamics
%>    of the interpolated series, and for the relationship between
%>    the interpolated series and the indicator (if included).
%
%
% __`aggregation`__ [ `"Mean"` | `"Sum"` | `"First"` | `"Last"` | numeric ]
%
%>     Type of aggregation of quarterly observations to yearly observations;
%>     the `aggregation` can be assigned a `1-by-N` numeric vector with
%>     the weights given, respectively, for the individual high-frequency
%>     periods within the encompassing low-frequency period.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`highOutput`__ [ Series ] 
%
%>    High-frequency output series constructed by interpolating the input
%>    `lowInput` using the dynamics of the `indicator`.
%
%
% __`info`__ [ struct ]
%
%>    Output information struct with the the following fields:
%>
%>    * `.FromFreq` - Original (low) frequency of the input series
%>    * `.ToFreq` - Target (high) frequency to which the input series has been interpolated
%>    * `.LowRange` - Low frequency date range from which the input series has been interpolated
%>    * `.HighRange` - High frequency date range to which the input series has been interpolated
%>    * `.EffectiveLowRange` - Low frequency range after excluding years with full conditioning level information
%>    * `.StackedSystem` - Stacked-time linear system (StackedSystem) object used to run the interpolation
%
%
% Options
%--------------------------------------------------------------------------
%
%
% __`Range=Inf`__ [ `Inf` | DateWrapper ]
%
%>    Low-frequency range on which the interpolation will be calculated;
%>    `Inf` means from the date of the first observation to
%>    the date of the last observation in the `lowInput` time series.
%
%
% __`ResolveConflicts=true`__ [ `true` | `false` ]
%
%>    Resolve potential conflicts (singularity) between the `lowInput`
%>    obervatations and the data supplied through the `HighLevel=` option.
%
%
% __`Indicator.Level=[ ]`__ [ empty | Series ] 
%
%>    High-frequency indicator whose dynamics will be used to interpolate
%>    the `lowInput`.
%
%
% __`Indicator.Model="Difference"`__ [ `"Difference"` | `"Ratio"` ]
%
%>    Type of model for the relationship between the interpolated series
%>    and the indicator in the transition equation: `"Difference"`
%>    means the indicator will be subtracted from the series, `"Ratio"`
%>    means the series will be divided by the indicator.
%
%
% __`Initial=@auto`__ [ `@auto` | Series ]
%
%>    Initial (presample condition) for the Kalman filter; `@auto` means
%>    the initial condition will be extracted from the `Hard.Level`
%>    time series; if no observations are supplied either directly
%>    through `Initial=` or through `Hard.Level=`, then the initial
%>    condition will be estimated by maximum likelihood.
%
%
% __`Hard.Level=[ ]`__ [ empty | Series ]
%
%>    Hard conditioning information; any values in this time series within
%>    the interpolation range or the presample initial condition (see also
%>    the option `Initial=`) will be imposed on the resulting `highOutput`.
%
%
% __`Transition.Intercept=0`__ [ numeric | `@auto` ]
%
%>    Intercept in the transition equation; if `@auto` the intercept will
%>    be estimated by GLS.
%
%
% __`Transition.Rate=1`__ [ numeric ]
%
%>    Rate of autoregression in the differencing term in the transition
%>    equation.
%
%
%
% Description
%--------------------------------------------------------------------------
%
%
% The interpolated `lowInput` is obtained from the first element of the state
% vector estimated using the following quarterly state-space model
% estimated by a Kalman filter:
% 
%
% #### State Transition Equation ####
%
%
% $$ \left(1 - \rho L\right)^k \hat x_t = v_t $$
%
% where $ \hat x_t $ is a transformation of the unobserved higher-frequencuy interpolated
% series, $ x_t $, depending on the option `Indicator.Model=`:
%
% * $ \hat x_t = x_t $ if no indicator is specified;
%
% * $ \hat x_t = x_t - q_t $ if an indicator $ q_t $ is entered through
% `Indicator.Level=` and `Indicator.Model="Difference"`;
%
% * $ \hat x_t = x_t / q_t $ if an indicator $ q_t $ is entered through
% `Indicator.Level=` and `Indicator.Model="Ratio"`;
%
% $ L $ is the lag operator, $ k $ is the order of differencing
% specified by `order`, and $\rho$ is the transition rate of
% autoregression specified in `Transition.Rate=`.
%
%
% #### Measurement Equation ####
%
%
% $$ y_t = Z x_t + w_t $$
%
% where 
%
% * $ y_t $ is a measurement variables containing the yearly data
% placed in the last (fourth) quarter of every year; in other words, only
% every fourth observation is available, and the three in between are
% missing
%
% * $ x_t $ is a state vector consisting of $N$ elements, where $N$
% is the number of high-frequency periods within one low-frequency period:
% the unobserved high-frequency lags $t-N, \dots, t-1, t$.
% 
% * $ Z $ is a time-invariant aggregation matrix depending on
% `aggregation`: 
%
%     * $ Z=[1, 1, 1, 1] $ for `aggregation="Sum"`, 
%     * $ Z=[1/4, 1/4, 1/4, 1/4] $ for `aggregation="Average"`, 
%     * $ Z=[0, 0, 0, 1] $ for `aggregation="Last"`, 
%     * $ Z=[1, 0, 0, 0] $ for `aggregation="First"`, 
%     * or a user supplied 1-by-$ N $ vector
%
% * $ v_t $ is a transition error with constant variance
%
% * $ w_t $ is a vector of measurement errors associated with soft
% conditions.
%
%
% Example
%--------------------------------------------------------------------------
%
%}

function [output, info, Xi] = genip(lowInput, highFreq, transitionOrder, aggregationModel, varargin)

if isempty(lowInput)
    output = lowInput;
    info = struct( );
    return
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('NumericTimeSubscriptable/genip');
    pp.KeepDefaultOptions = true;

    addRequired(pp, 'lowInput', @(x) isa(x, 'NumericTimeSubscriptable'));
    addRequired(pp, 'highFreq', @(x) isa(x, 'Frequency') || isnumeric(x));
    addRequired(pp, 'order', @(x) isequal(x, 0) || isequal(x, 1) || isequal(x, 2) || validate.anyString(x, 'Level', 'Diff', 'DiffDiff'));
    addRequired(pp, 'aggregation', @(x) locallyValidateAggregation(x));

    % Options
    addParameter(pp, 'Range', Inf, @(x) isequal(x, Inf) || DateWrapper.validateProperRangeInput(x));
    addParameter(pp, 'Initial', @auto, @(x) isequal(x, @auto) || isnumeric(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'ResolveConflicts', true, @validate.logicalScalar);

    % Nested options
    addParameter(pp, 'Transition.Intercept', 0, @(x) isequal(x, @auto) || validate.numericScalar(x));
    addParameter(pp, 'Transition.Rate', 1, @(x) isequal(x, @auto) || validate.numericScalar(x));
    addParameter(pp, 'Transition.Std', 1, @(x) isequal(x, 1) || isa(x, 'NumericTimeSubscriptable'));

    addParameter(pp, 'Hard.Level', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'Hard.Diff', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'Hard.Rate', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));

    %{
    addParameter(pp, 'Soft.Level', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'Soft.Diff', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'Soft.Rate', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    %}

    addParameter(pp, 'Indicator.Model', 'Difference', @(x) (ischar(x) || isstring(x)) && startsWith(x, ["Diff", "Rat"]));
    addParameter(pp, 'Indicator.Level', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
end
%)
[skip, opt] = maybeSkip(pp, varargin{:});
if ~skip
    opt = parse(pp, lowInput, highFreq, transitionOrder, aggregationModel, varargin{:});
end

%--------------------------------------------------------------------------

transition = struct( );
transition = locallyResolveTransitionModel(transition, transitionOrder);

%
% Resolve source frequency and the conversion factor
%
[fromFreq, numWithin] = hereResolveFrequencyConversion( );


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
highStart = numeric.convert(lowStart, highFreq, "--skip");
highEnd = numeric.convert(lowEnd, highFreq, 'ConversionMonth=', 'Last', "--skip");

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
    hereResolveConflictsInMeasurement( );

    [inxRunLow, inxRunHigh, inxInit, lowLevel, hard, indicator] = ...
        locallyClipRange(lowLevel, hard, indicator, transition, aggregation);

    hereCheckIndicatorForNaNs( );

    Xi0 = series.genip.prepareInitialCondition( ...
        transition, hard, [highStart, highEnd], inxInit, opt ...
    );

    [stacked, Y, Xi0, transition, indicator] = ...
        series.genip.setupStackedSystem(lowLevel, aggregation, transition, hard, indicator, Xi0);

    [Xi, Xi0] = smoother(stacked, Y, Xi0);

    if isequal(transition.Intercept, @auto)
        transition.Intercept = Xi0(end);
        Xi0(end) = [ ];
    end

    %
    % Compose output data from Xi0, Hard.Level and adjust for
    % Indicator.Level if needed.
    %
    outputData = hereComposeOutputData( );
end


%
% Create output time series
%
highExtStart = dater.plus(highStart, -numInit);
output = Series(highExtStart, outputData);


%
% Create output information struct if requested
%
info = struct( );
if nargout>=2
    wholeRange = opt.Range(1) : opt.Range(end);
    info.LowFreq = fromFreq;
    info.HighFreq = highFreq;
    info.LowRange = DateWrapper(lowStart):DateWrapper(lowEnd);
    info.HighRange = DateWrapper(highStart):DateWrapper(highEnd);
    info.EffectiveLowRange = wholeRange(inxRunLow);
    info.TransitionRate = transition.Rate;
    info.TransitionIntercept = transition.Intercept;
    info.StackedSystem = stacked;
    info.NumYearsStacked = nnz(inxRunLow);
end

return

    function [fromFreq, numWithin] = hereResolveFrequencyConversion( )
        %(
        fromFreq = lowInput.Frequency;
        if double(highFreq)<=double(fromFreq)
            thisError = [ 
                "NumericTimeSubscriptable:CannotInterpolateToLowerFreq"
                "Series can only be interpolated from a lower to a higher frequency. "
                "You are attempting to interpolate from %s to %s." 
            ];
            throw(exception.Base(thisError, 'error'), char(fromFreq), char(highFreq));
        end
        numWithin = double(highFreq)/double(fromFreq);
        if numWithin~=round(numWithin)
            thisError = [ 
                "NumericTimeSubscriptable:CannotInterpolateToLowerFreq"
                "Function genip( ) can only be used to interpolate between "
                "YEARLY, HALFYEARLY, QUARTERLY and MONTHLY frequencies. "
                "You are attempting to interpolate from %s to %s." 
            ];
            throw(exception.Base(thisError, 'error'), char(fromFreq), char(highFreq));
        end
        %)
    end%


    function hereResolveConflictsInMeasurement( )
        %(
        if ~opt.ResolveConflicts
            return
        end
        % Aggregate vs Level
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


    function hereCheckIndicatorForNaNs( )
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


    function outputData = hereComposeOutputData( )
        %(
        outputData = Xi(end:-1:1);
        if ~isempty(indicator.Level)
            if indicator.Model=="Difference"
                outputData = outputData + indicator.Level;
            elseif indicator.Model=="Ratio"
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

function flag = locallyValidateAggregation(x)
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


function transition = locallyResolveTransitionModel(transition, transitionOrder)
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
    locallyClipRange(lowLevel, hard, indicator, transition, aggregation)
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

    lastFull = find(~inxFull, 1, "First") - 1; % [^1]
    if ~isempty(lastFull) && lastFull>1;
        inxRunLow(1:lastFull-1) = false;
        inxRunHigh(1:(lastFull-1)*numWithin) = false;
        inxInit = circshift(inxInit, [0, (lastFull-1)*numWithin]);
    end
    % [^1]: `lastFull` is the column of the last year that has all
    % observations, counting only the uninterrupted sequence of
    % full-observation years from the beginning. This last full year will
    % be included in clipped range (becuase it may be needed for initial
    % condition).

    firstFull = find(~inxFull, 1, "Last") + 1;
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




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Series/genipUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up Once

startQ = qq(1990,1);
endQ = qq(2050,4);
startY = convert(startQ, Frequency.YEARLY) + 1;
endY = convert(endQ, Frequency.YEARLY);
quarterly = cumprod(1 + Series(startQ:endQ, @randn)/100);
indicator = quarterly + Series(startQ:endQ, @randn)/100;
yearly = convert(quarterly, Frequency.YEARLY, "Method=", "sum");


%% Test Initial Condition

interp = genip( ...
    yearly, Frequency.QUARTERLY, 2, "sum" ...
    , "Range=", startY:endY ...
    , "Hard.Level=", clip(quarterly, -Inf, startQ+3) ...
);

assertEqual(testCase, interp(startQ+2:startQ+3), quarterly(startQ+2:startQ+3), "AbsTol", 1e-12);


%% Test Initial Condition and Hard Level


for k = 4 : 40
    interp = genip( ...
        yearly, Frequency.QUARTERLY, 2, "sum" ...
        , "Range=", startY:endY ...
        , "Hard.Level=", clip(quarterly, -Inf, startQ+k) ...
    );

    assertEqual(testCase, interp(startQ+2:startQ+k), quarterly(startQ+2:startQ+k), "AbsTol", 1e-12);
end


%% Test Hard Level but No Initial Condition

interp1 = genip( ...
    yearly, Frequency.QUARTERLY, 2, "sum" ...
    , "Range=", startY:endY ...
    , "Hard.Level=", clip(quarterly, startQ+4, startQ+12) ...
);

interp2 = genip( ...
    yearly, Frequency.QUARTERLY, 2, "sum" ...
    , "Range=", startY:endY ...
    , "Initial=", NaN ...
    , "Hard.Level=", clip(quarterly, -Inf, startQ+12) ...
);

assertEqual(testCase, interp1(startQ+4:end), interp2(startQ+4:end), "AbsTol", 1e-12);
assertEqual(testCase, interp1(startQ+(4:12)), quarterly(startQ+(4:12)), "AbsTol", 1e-12);

%% Test Indicator

interp1 = genip( ...
    yearly, Frequency.QUARTERLY, 2, "sum" ...
    , "Range=", startY:endY ...
    , "Hard.Level=", clip(quarterly, -Inf, startQ+40) ...
);

interp2 = genip( ...
    yearly, Frequency.QUARTERLY, 2, "sum" ...
    , "Range=", startY:endY ...
    , "Hard.Level=", clip(quarterly, -Inf, startQ+40) ...
    , "Indicator.Level=", indicator ...
    , "Indicator.Model=", "Ratio" ...
);

[~, r1] = acf(pct([interp1, indicator]));
[~, r2] = acf(pct([interp2, indicator]));

assertGreaterThan(testCase, r2(1), r1(2));


%% Test Indicator and Hard Level

indicator1 = indicator;
indicator2 = clip(indicator, startQ+38, Inf);
indicator2 = fillMissing(indicator2, startQ:endQ, "Next");

interp1 = genip( ...
    yearly, Frequency.QUARTERLY, 2, "sum" ...
    , "Range=", startY:endY ...
    , "Hard.Level=", clip(quarterly, -Inf, startQ+40) ...
    , "Indicator.Level=", indicator1 ...
    , "Indicator.Model=", "Ratio" ...
);

interp2 = genip( ...
    yearly, Frequency.QUARTERLY, 2, "sum" ...
    , "Range=", startY:endY ...
    , "Hard.Level=", clip(quarterly, -Inf, startQ+40) ...
    , "Indicator.Level=", indicator2 ...
    , "Indicator.Model=", "Ratio" ...
);

assertEqual(testCase, interp1(:), interp2(:), "AbsTol", 1e-9);

##### SOURCE END #####
%}

