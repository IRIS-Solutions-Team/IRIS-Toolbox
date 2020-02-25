function [output, info] = genip(lowInput, toFreq, model, aggregation, varargin)
% genip  Generalized indicator based interpolation
%{
% ## Syntax ##
%
%
%     [output, info] = genip(lowInput, toFreq, model, indicator, ...)
%
%
% ## Input Arguments ##
%
%
% __`lowInput`__ [ Series ] 
% >
% Low-frequency input series that will be interpolated to the `toFreq`
% frequency using the `indicator`.
%
%
% __`toFreq`__ [ Frequency ]
% >
% Target frequency to which the `lowInput` series will be interpolated;
% `toFreq` must be higher than the frequency of the `lowInput`.
%
%
% __`model`__ [ `'Level'` | `'Diff'` | `'DiffDiff'` | `'Rate'` ]
% >
% Type of state-space model for the dynamics of the interpolated series,
% and for the relationship between the interpolated series and the
% indicator (if included).
%
%
% __`aggregation`__ [ `'mean'` | `'sum'` | `'lowEnd'` | numeric ]
% >
% Type of aggregation of quarterly observations to yearly observations; the
% `aggregation` can be assigned a `1-by-N` numeric vector with the weights
% given, respectively, for the individual high-frequency periods within the
% encompassing low-frequency period.
%
%
% ## Output Arguments ##
%
%
% __`output`__ [ Series ] 
% >
% High-frequency output series constructed by interpolating the input
% `lowInput` using the dynamics of the `indicator`.
%
%
%
% __`info`__ [ struct ]
% >
% Output information struct with the the following fields:
% * `.FromFreq` - Original (low) frequency of the input series
% * `.ToFreq` - Target (high) frequency to which the input series has been interpolated
% * `.LowRange` - Low frequency date range from which the input series has been interpolated
% * `.HighRange` - High frequency date range to which the input series has been interpolated
% * `.LinearSystem` - Time-varying LinearSystem object used to run the interpolation
% * `.InitCond` - Numerical initial condition used in the Kalman filter: {mean, MSE}
% * `.ObservedData` - Array with all observed data including conditioning and indicators
% * `.OutputData` - Complete Kalman filter output data
%
%
% ## Options ##
%
%
% __`DiffuseFactor=@auto`__ [ `@auto` | numeric ]
% >
% Numeric scaling factor used to approximate an infinite variance for
% diffuse initial conditions.
%
%
% __`HighLevel=[ ]`__ [ empty | Series ]
% >
% High-frequency observations already available on the input series;
% conflicting low-frequency observations will be removed from the
% `lowInput` if `RemoveConflicts=true`.
%
%
% __`Indicator=`__ [ Series | numeric ] 
% >
% High-frequency indicator whose dynamics will be used to
% interpolate the `lowInput`.
%
%
% __`Range=Inf`__ [ `Inf` | DateWrapper ]
% >
% Low-frequency range on which the interpolation will be calculated; `Inf`
% means from the start of the `lowInput` to the end.
%
%
% __`ResolveConflicts=true`__ [ `true` | `false` ]
% >
% Resolve potential conflicts (singularity) between the `lowInput`
% obervatations and the data supplied through the `HighLevel=` option.
%
%
% __`StdIndicator=1e-3`__ [ numeric ]
% >
% Relative std deviation of the measurement error associated with the
% indicator measurement equation; the std deviation is entered relative to
% the std deviation of the transition shock.
%
%
% ## Description ##
%
%
% The interpolated `lowInput` is obtained from the first element of the state
% vector estimated using the following quarterly state-space model
% estimated by a Kalman filter:
% 
%
% #### State transition equation ####
%
% \[ x_t = T_t x_{t-1} + v_t \]
%
% #### Measurement equation ####
%
% \[ y_t = Z x_t \]
%
% where 
%
% * \( y_t \) is a measurement variables containing the yearly data
% placed in the last (fourth) quarter of every year; in other words, only
% every fourth observation is available, and the three in between are
% missing
%
% * \( x_t \) is a state vector consisting of four elements: the unobserved
% quarterly lowInput lags \(t-3\), \(t-2\), \(t-1\), and its current
% dated value.
%
% * \( T_t \) is a time-varying transition matrix based on the quarterly rate
% of change in the indicator variables, \(\rho_t = i_t / i_{t-1}\)
%
% \[ T_t = \begin{bmatrix} \rho_t & 0 & 0 & 0 \\ 
%                               1 & 0 & 0 & 0 \\ 
%                               0 & 1 & 0 & 0 \\
%                               0 & 0 & 1 & 0 \end{bmatrix} \]
% 
% * \( Z \) is a time-invariant aggregation matrix depending on the option
% `Aggregation=`: 
% \( Z=[1, 1, 1, 1] \) for `Aggregation='sum'`, 
% \( Z=[1/4, 1/4, 1/4, 1/4] \) for `Aggregation='average'`, 
% \( Z=[0, 0, 0, 1] \) for `Aggregation='lowEnd'`, 
% or a user supplied 1-by-4 vector
%
% * \( v_t \) is a transition error with constant variance
%
%
% ## Example ##
%
%}

persistent pp
if isempty(pp)
    pp = extend.InputParser('genip');
    addRequired(pp, 'lowInput', @(x) isa(x, 'NumericTimeSubscriptable') && x.Frequency==Frequency.YEARLY);
    addRequired(pp, 'toFreq', @(x) isa(x, 'Frequency') || isnumeric(x));
    addRequired(pp, 'model', @(x) validate.anyString(strip(x), 'Rate', 'Level', 'Diff', 'DiffDiff'));
    addRequired(pp, 'aggregation', @localValidateAggregation);

    addParameter(pp, 'Range', Inf, @(x) isequal(x, Inf) || DateWrapper.validateProperRangeInput(x));
    addParameter(pp, 'StdScale', 1, @(x) isequal(x, 1) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'InitCond', @auto);
    addParameter(pp, 'ResolveConflicts', true, @validate.logicalScalar);
    addParameter(pp, 'TransitionRate', @auto, @(x) isequal(x, @auto) || validate.numericScalar(x));
    addParameter(pp, 'TransitionConstant', @auto, @(x) isequal(x, @auto) || validate.numericScalar(x));

    % Conditioning options
    addParameter(pp, 'HighLevel', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'HighRate', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'HighDiff', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'HighDiffDiff', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));

    % Indicator options
    addParameter(pp, 'Indicator', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'StdIndicator', 1e-3, @(x) validate.numericScalar(x, eps( ), Inf));
end
parse(pp, lowInput, toFreq, model, aggregation, varargin{:});
opt = pp.Options;
model = localResolveModel(model);

%--------------------------------------------------------------------------

%
% Resolve source frequency and the conversion factor
%
[fromFreq, numPeriodsWithin] = hereResolveFrequencyConversion( );

%
% Check frequency of all input series
%
hereCheckFrequency( );

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
highStart = numeric.convert(lowStart, toFreq);
highEnd = numeric.convert(lowEnd, toFreq, 'ConversionMonth=', 'Last');
numHighPeriods = numPeriodsWithin*numLowPeriods;

%
% Resolve Indicator= option
%
indicatorTransformed = hereResolveIndicator( );

%
% Resolve Aggregation= option
%
aggregation = localResolveAggregation(aggregation, numPeriodsWithin);

%
% Resolve std dev scale
%
stdScale = hereResolveStdScale( );

%
% Resolve low frequency level data
%
lowLevel = hereGetLowLevelData( );

%
% Resolve rate of change conditioning
%
[highLevel, highRate, highDiff, highDiffDiff] = hereGetConditioningData( );

%
% Resolve conflicts between observed low frequency levels and conditioning
%
hereResolveConflictsInMeasurement( );

%
% Set up a linear Kalman filter object
%
[kalmanObj, observed] = series.genip.setupKalmanObject( ...
    model, lowLevel, aggregation, stdScale ...
    , highLevel, highRate, highDiff, highDiffDiff ... 
    , indicatorTransformed, opt.StdIndicator ...
    , opt ...
);

%
% Set up initial conditions
%
initCond = hereSetupInitCond( );

%
% Run the Kalman filter
%
outputData = filter( ...
    kalmanObj, observed, highStart:highEnd ...
    , 'Init=', initCond, 'Relative=', false ...
);

%
% Extract the last state variable
%
output = retrieveColumns(outputData.SmoothMean.Xi, numPeriodsWithin);
output = clip(output, highStart, highEnd);

info = struct( );
if nargout>=2
    info.FromFreq = fromFreq;
    info.ToFreq = toFreq;
    info.LowRange = DateWrapper(lowStart):DateWrapper(lowEnd);
    info.HighRange = DateWrapper(highStart):DateWrapper(highEnd);
    info.LinearSystem = kalmanObj;
    info.InitCond = initCond;
    info.ObservedData = observed;
    info.OutputData = outputData;
end

return


    function [fromFreq, numPeriodsWithin] = hereResolveFrequencyConversion( )
        fromFreq = lowInput.Frequency;
        if double(toFreq)<=double(fromFreq)
            thisError = [ 
                "NumericTimeSubscriptable:CannotInterpolateToLowerFreq"
                "Series can only be interpolated from a lower to a higher frequency. "
                "You are attempting to interpolate from %s to %s." 
            ];
            throw(exception.Base(THIS_ERROR, 'error'), char(fromFreq), char(toFreq));
        end
        numPeriodsWithin = double(toFreq)/double(fromFreq);
        if numPeriodsWithin~=round(numPeriodsWithin)
            thisError = [ 
                "NumericTimeSubscriptable:CannotInterpolateToLowerFreq"
                "Function genip( ) can only be used to interpolate between "
                "YEARLY, HALFYEARLY, QUARTERLY and MONTHLY frequencies. "
                "You are attempting to interpolate from %s to %s." 
            ];
            throw(exception.Base(THIS_ERROR, 'error'), char(fromFreq), char(toFreq));
        end
    end%




    function hereCheckFrequency( )
    %(
        if ~verifyFrequency(opt.Indicator, toFreq)
            hereThrowInvalidFrequency('Indicator', toFreq);
        end

        if ~verifyFrequency(opt.HighLevel, toFreq)
            hereThrowInvalidFrequency('HighLevel', toFreq);
        end

        if ~verifyFrequency(opt.HighRate, toFreq)
            hereThrowInvalidFrequency('HighRate', toFreq);
        end

        if ~verifyFrequency(opt.HighDiff, toFreq)
            hereThrowInvalidFrequency('HighDiff', toFreq);
        end

        if ~verifyFrequency(opt.HighDiffDiff, toFreq)
            hereThrowInvalidFrequency('HighDiffDiff', toFreq);
        end

        return

            function flag = verifyFrequency(input, freq)
                if ~isa(input, 'NumericTimeSubscriptable')
                    flag = isempty(input);
                    return
                end
                flag = input.Frequency==freq;
            end%


            function hereThrowInvalidFrequency(option, freq)
                thisError = [
                    "Series:InvalidFrequencyGenip"
                    "Time series assigned to option %s= "
                    "must be of the following date frequency: %s"
                ];
                throw(exception.Base(thisError, 'error'), option, char(freq));
            end%
    %)
    end%




    function lowLevel = hereGetLowLevelData( )
        lowLevel = getDataFromTo(lowInput, lowStart, lowEnd);
    end%




    function [highLevel, highRate, highDiff, highDiffDiff] = hereGetConditioningData( )
    %(
        highLevel = [ ];
        if isa(opt.HighLevel, 'NumericTimeSubscriptable') && isfreq(opt.HighLevel, toFreq)
            highLevel = getDataFromTo(opt.HighLevel, highStart, highEnd);
        end
        highRate = [ ];
        if isa(opt.HighRate, 'NumericTimeSubscriptable') && isfreq(opt.HighRate, toFreq)
            highRate = getDataFromTo(opt.HighRate, highStart, highEnd);
        end
        highDiff = [ ];
        if isa(opt.HighDiff, 'NumericTimeSubscriptable') && isfreq(opt.HighDiff, toFreq)
            highDiff = getDataFromTo(opt.HighDiff, highStart, highEnd);
        end
        highDiffDiff = [ ];
        if isa(opt.HighDiffDiff, 'NumericTimeSubscriptable') && isfreq(opt.HighDiffDiff, toFreq)
            highDiffDiff = getDataFromTo(opt.HighDiffDiff, highStart, highEnd);
        end
    %)
    end%




    function indicatorTransformed = hereResolveIndicator( )
        indicatorTransformed = [ ];
        if isempty(opt.Indicator)
            return
        end
        indicator = opt.Indicator;
        switch string(model)
            case "Level"
                func = @(x) x;
            case "Rate"
                func = @roc;
            case "Diff"
                func = @diff;
            case "DiffDiff"
                func = @(x) diff(diff(x));
        end
        indicatorTransformed = getDataFromTo(func(indicator), highStart, highEnd);
    end%


    function stdScale = hereResolveStdScale( )
        if isa(opt.StdScale, 'NumericTimeSubscriptable')
            stdScale = getDataFromTo(opt.StdScale, highStart, highEnd);
            stdScale = abs(stdScale);
            if any(isnan(stdScale))
                stdScale = numeric.fillMissing(stdScale, NaN, 'globalLoglinear');
            end
            stdScale = stdScale/stdScale(1);
            stdScale = reshape(stdScale, 1, 1, [ ]);
        else
            stdScale = ones(1, 1, numHighPeriods);
        end
    end%


    function initCond = hereSetupInitCond( )
        if isequal(opt.InitCond, @auto)
            %
            % All initial conditions are treated as fixed unknown, and
            % initialized at a point derived from the first low-frequency
            % observation
            %
            %{
            posFirst = find(isfinite(lowLevel), 1);
            if ~isempty(posFirst)
                x0 = lowLevel(posFirst);
            else
                x0 = 0;
            end
            x0 = x0 / sum(aggregation(:));
            initCond = { 
                repmat(x0, numPeriodsWithin, 1)
                [ ] % Shortcut to indicate all initial conditions are fixed uknown
            };
            %}
            initCond = 'FixedUnknown';
        else
            %
            % User-supplied initial condition
            %
            initCond = opt.InitCond;
        end
    end%




    function hereResolveConflictsInMeasurement( )
        if ~opt.ResolveConflicts
            return
        end
        % Aggregate vs Level
        if ~isempty(highLevel) && any(isfinite(highLevel))
            inxAggregation = aggregation~=0;
            temp = reshape(highLevel, numPeriodsWithin, [ ]);
            temp = temp(inxAggregation, :);
            inxLowLevel = reshape(isfinite(lowLevel), 1, [ ]);
            inxHighLevel = all(isfinite(temp), 1);
            inxToResolve = inxLowLevel & inxHighLevel;
            if any(inxToResolve)
                lowLevel(inxToResolve) = NaN;
            end
        end
    end%
end%


%
% Local validators
%


function flag = localValidateAggregation(x)
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


function aggregation = localResolveAggregation(aggregation, numPeriodsWithin)
%(
    if isnumeric(aggregation)
        aggregation = reshape(aggregation, 1, numPeriodsWithin);
        return
    elseif any(strcmpi(char(aggregation), {'average', 'mean'}))
        aggregation = ones(1, numPeriodsWithin)/numPeriodsWithin;
        return
    elseif strcmpi(char(aggregation), 'last')
        aggregation = zeros(1, numPeriodsWithin);
        aggregation(end) = 1;
        return
    elseif strcmpi(char(aggregation), 'first')
        aggregation = zeros(1, numPeriodsWithin);
        aggregation(1) = 1;
    else
        % Default 'sum'
        aggregation = ones(1, numPeriodsWithin);
        return
    end
%)
end%


function model = localResolveModel(model)
%(
    model = strip(string(model));
    if strcmpi(model, "Rate")
        model = "Rate";
    elseif strcmpi(model, "Level")
        model = "Level";
    elseif strcmpi(model, "Diff")
        model = "Diff";
    elseif strcmpi(model, "DiffDiff")
        model = "DiffDiff";
    end
%)
end%

