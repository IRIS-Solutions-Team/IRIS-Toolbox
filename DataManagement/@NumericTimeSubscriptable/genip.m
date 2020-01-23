function varargout = genip(lowInput, varargin)
% genip  Generalized indicator based interpolation
%{
% ## Syntax ##
%
%
%     [output, kalmanObj, info] = genip(lowInput, toFreq, model, indicator, ...)
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
% Type of state-space relationship assumed between the interpolated series
% and the indicator; see Description.
%
%
% __`indicator`__ [ Series | numeric ] 
% >
% High-frequency indicator whose dynamics will be used to
% interpolate the `lowInput`; if the `indicator` is a numeric scalar, the
% same value will be used throughout the entire interpolation range.
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
% __`kalmanObj`__ [ BareLinearKalman ]
% >
% A BareLinearKalman object used to calculated the interpolated values.
%
%
% __`info`__ [ struct ]
% >
% Output information struct with the initial condition, `.InitCond`, and a
% complete Kalman filter data output, `.OutputData`
%
%
% ## Options ##
%
%
% __`Aggregation='mean'`__ [ `'mean'` | `'sum'` | `'lowEnd'` | numeric ]
% >
% Type of aggregation of quarterly observations to yearly observations; the
% option `Aggregation=` can be assigned a `1-by-N` numeric vector with the
% weights given, respectively, for the individual high-frequency periods
% within the encompassing low-frequency period.
%
%
% __`DiffuseFactor=@auto`__ [ `@auto` | numeric ]
% >
% Numeric scaling factor used to approximate an infinite variance for
% diffuse initial conditions.
%
%
% __`QuarterlyLevel=[ ]`__ [ empty | Series ]
% >
% High-frequency observations already available on the input series;
% conflicting low-frequency observations will be removed from the
% `lowInput` if `RemoveConflicts=true`.
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
% obervatations and the data supplied through the `QuarterlyLevel=` option.
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

% Invoke unit tests
%(
if nargin==2 && strcmp(varargin{1}, '--test')
    varargout{1} = unitTests( );
    return
end
%)


persistent pp
if isempty(pp)
    pp = extend.InputParser('genip');
    addRequired(pp, 'lowInput', @(x) isa(x, 'NumericTimeSubscriptable') && x.Frequency==Frequency.YEARLY);
    addRequired(pp, 'toFreq', @(x) isequal(x, Frequency.QUARTERLY));
    addRequired(pp, 'model', @(x) validate.anyString(erase(string(x), "="), 'Rate', 'Level', 'Diff', 'DiffDiff'));
    addRequired(pp, 'indicator', @(x) isequal(x, @auto) || validate.numericScalar(x) || isa(x, 'NumericTimeSubscriptable'));

    addParameter(pp, 'Aggregation', @mean, @hereValidateAggregation);
    addParameter(pp, 'DiffuseFactor', @auto, @(x) isequal(x, auto) || validate.numericScalar(x));
    addParameter(pp, 'Range', Inf, @(x) isequal(x, Inf) || DateWrapper.validateProperRangeInput(x));
    addParameter(pp, 'InitCond', @auto);
    addParameter(pp, 'QuarterlyLevel', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'ResolveConflicts', true, @validate.logicalScalar);
    addParameter(pp, 'StdScale', 1, @(x) isequal(x, 1) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'QuarterlyRate', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
end
parse(pp, lowInput, varargin{:});
model = erase(string(pp.Results.model), "=");
indicator = pp.Results.indicator;
toFreq = pp.Results.toFreq;

opt = pp.Options;

%--------------------------------------------------------------------------

%
% Resolve source frequency and the conversion factor
%
[fromFreq, numPeriodsWithin] = hereResolveFrequencyConversion( );

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
highStart = convert(lowStart, Frequency.QUARTERLY);
highEnd = convert(lowEnd, Frequency.QUARTERLY) + 3;
numHighPeriods = highEnd - highStart + 1;

%
% Resolve std dev scale
%
stdScale = hereResolveStdScale( );

%
% Resolve high-frequency indicator
%
hereResolveHighIndicator( );

%
% Resolve rate of change conditioning
%
quarterlyRate = hereResolveRateConditioning( );

%
% Resolve Aggregation= option
%
aggregation = hereResolveAggregation(opt.Aggregation, numPeriodsWithin);

%
% Set up a linear Kalman filter object
%
kalmanObj = hereSetupKalmanObject( );

%
% Set up initial conditions
%
initCond = hereSetupInitCond( );

%
% Create measurement variables and resolve conflicts (singularity) between
% `lowInput` and `quarterlyLevel`
%
observed = hereCreateObservedArray( );

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
output = retrieveColumns(outputData.SmoothMean.Xi, 4);
output = clip(output, highStart, highEnd);

info = struct( );
if nargout>=3
    info.FromFreq = fromFreq;
    info.ToFreq = toFreq;
    info.InitCond = initCond;
    info.ObservedData = observed;
    info.OutputData = outputData;
end


%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
varargout = { output, kalmanObj, info };
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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



    function hereResolveHighIndicator( )
        if ~isequal(indicator, @auto)
            return
        end
        yearlyData = getDataFromTo(lowInput, lowStart, lowEnd);
        indicator = (yearlyData(end)/yearlyData(1))^(1/(4*numLowPeriods));
    end%




    function quarterlyRate = hereResolveRateConditioning( )
        if isempty(opt.QuarterlyRate)
            quarterlyRate = nan(1, numHighPeriods);
            return
        end
        quarterlyRate = getDataFromTo(opt.QuarterlyRate, highStart, highEnd);
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
            stdScale = ones(1, numHighPeriods);
        end
    end%




    function kalmanObj = hereSetupKalmanObject( )
        nw = numPeriodsWithin;

        indicatorVector = hereGetHighIndicatorVector( );

        % 
        % Transition matrix
        %
        T = hereSetupTransitionMatrix( );

        %
        % Transition innovation multiplier
        %
        R = zeros(nw+1, 1);
        R(nw, 1) = 1;

        %
        % Transition intercept
        %
        k = hereSetupTransitionConstant( );

        %
        % Measurement (aggregation) matrix
        %
        Z = hereSetupMeasurementMatrix( );

        %
        % Measurement innovation and intercept
        %
        H = zeros(3, 0);
        d = zeros(3, 1);

        %
        % Innovation covariance matrices
        %
        OmegaV = stdScale.^2;
        OmegaW = [ ];

        kalmanObj = BareLinearKalman([nw+1, 1, 3, 0], numHighPeriods);
        kalmanObj = steadySystem(kalmanObj, 'NotNeeded');
        kalmanObj = timeVaryingSystem(kalmanObj, 1:numHighPeriods, {T, R, k, Z, H, d}, {OmegaV, OmegaW});

        return

            function indicatorVector = hereGetHighIndicatorVector( )
                if isa(indicator, 'NumericTimeSubscriptable')
                    indicatorVector = getDataFromTo(indicator, highStart, highEnd);
                else
                    indicatorVector = indicator;
                    if isscalar(indicatorVector)
                        indicatorVector = repmat(indicatorVector, 1, 1, numHighPeriods);
                    end
                end
                indicatorVector = reshape(indicatorVector, 1, 1, numHighPeriods);
            end%


            function T = hereSetupTransitionMatrix( )
                % Transition for individual high-frequency periods
                T = zeros(nw+1, nw+1);
                T(1:nw, 1:nw) = diag(ones(1, nw-1), 1);
                T = repmat(T, 1, 1, numHighPeriods);
                switch model
                    case "Rate"
                        T(nw, nw, :) = indicatorVector;
                    case "Diff"
                        T(nw, nw, :) = 1;
                    case "DiffDiff"
                        T(nw, nw, :) = 2;
                        T(nw, nw-1, :) = -1;
                    otherwise
                        % Level indicator, do nothing
                end
                % Transition for rate of change judgmental adjustments
                inxRateObserved = ~isnan(quarterlyRate);
                T(nw+1, nw, inxRateObserved) = quarterlyRate(inxRateObserved);
            end%


            function k = hereSetupTransitionConstant( )
                switch model
                    case "Rate"
                        k = zeros(nw+1, 1);
                    otherwise
                        % Level, Diff or DiffDiff indicator
                        k = zeros(nw+1, 1, numHighPeriods);
                        if isa(indicator, 'NumericTimeSubscriptable')
                            k(nw, 1, :) = getDataFromTo(indicator, highStart, highEnd);
                        else
                            k(nw, 1, :) = indicator;
                        end
                end
            end%


            function Z = hereSetupMeasurementMatrix( )
                %
                % Aggregation
                %
                Z1 = [aggregation, 0];

                %
                % Quarterly levels
                %
                Z2 = zeros(1, nw+1);
                Z2(nw) = 1;

                %
                % Quarterly rates
                %
                Z3 = zeros(1, nw+1);
                Z3(nw) = 1;
                Z3(nw+1) = -1;

                %
                % Measurement matrix
                %
                Z = [Z1; Z2; Z3];
            end%
    end%


    function initCond = hereSetupInitCond( )
        if isequal(opt.InitCond, @auto)
            %
            % Diffuse initial condition around values matching approximately the
            % first year of the `lowInput` in the pre-sample period
            %
            diffuseFactor = opt.DiffuseFactor;
            if isequal(diffuseFactor, @auto)
                diffuseFactor = kalmanObj.DIFFUSE_SCALE;
            end
            x0 = getDataFromTo(lowInput, lowStart, lowStart);
            x0 = x0 / sum(aggregation(:));
            initCond = { 
                repmat(x0, numPeriodsWithin, 1)
                ones(numPeriodsWithin)*diffuseFactor
            };
        else
            %
            % User-supplied initial condition
            %
            initCond = opt.InitCond;
        end

        %
        % Add zero init conditions for rate judgment
        %
        initCond{1} = [initCond{1}; 0];
        initCond{2} = blkdiag(initCond{2}, 0);
    end%


    function observed = hereCreateObservedArray( )
        nw = numPeriodsWithin;
        aggregateObserved = nan(nw, numLowPeriods);
        aggregateObserved(end, :) = getDataFromTo(lowInput, lowStart, lowEnd);
        aggregateObserved = reshape(aggregateObserved, 1, [ ]);
        levelObserved = nan(1, numHighPeriods);
        rateObserved = nan(1, numHighPeriods);
        inxRateObserved = ~isnan(quarterlyRate);
        rateObserved(inxRateObserved) = 0;
        if isa(opt.QuarterlyLevel, 'NumericTimeSubscriptable')
            levelObserved(1, :) = getDataFromTo(opt.QuarterlyLevel, highStart, highEnd);
            if opt.ResolveConflicts
                % Aggregate vs Level
                inxAggregation = reshape(aggregation~=0, [ ], 1);
                aggregateTemp = reshape(aggregateObserved, nw, [ ]);
                levelTemp = reshape(levelObserved, nw, [ ]);
                levelTemp = levelTemp(inxAggregation, :);
                inxAggregate = ~isnan(aggregateTemp(end, :));
                inxLevel = all(~isnan(levelTemp), 1);
                inxToResolve = inxAggregate & inxLevel;
                if any(inxToResolve)
                    aggregateTemp(:, inxToResolve) = NaN;
                    aggregateObserved = reshape(aggregateTemp, 1, [ ]);
                end
                % Level vs Rate
                % TODO
            end
        end
        observed = [aggregateObserved; levelObserved; rateObserved];
    end%
end%


%
% Local validators
%


function flag = hereValidateYearlyRange(x)
    flag = DateWrapper.validateProperRangeInput(x) ...
           && all(DateWrapper.getFrequencyAsNumeric(x)==Frequency.YEARLY);
end%




function flag = hereValidateAggregation(x)
    if any(strcmpi(char(x), {'sum', 'average', 'mean', 'last'}))
        flag = true;
        return
    end
    if isnumeric(x)
        flag = true;
        return
    end
    flag = false;
end%




function aggregation = hereResolveAggregation(aggregation, numPeriodsWithin)
    if isnumeric(aggregation)
        aggregation = reshape(aggregation(1:numPeriodsWithin), 1, [ ]);
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
end%




%
% Unit test functions
%
%(
function tests = unitTests( )
    tests = functiontests({ 
        @meanRateTest
        @meanLevelTest
        @meanDiffTest
        @meanDiffDiffTest
        @averageTest
        @lastTest
        @userSuppliedAggregationTest
        @identicalTest
    });
    tests = reshape(tests, [ ], 1);
end%


function meanRateTest(this)
    lowRange = yy(2001):yy(2020);
    highStart = qq(lowRange(1)-1, 1);
    highEnd = qq(lowRange(end), 4);
    highRange = highStart:highEnd;
    x = Series(lowRange, exp(cumsum(randn(numel(lowRange), 1)/10)));
    y = Series(highStart:highEnd, exp(cumsum(randn(numel(highRange), 1)/40)));
    dy = roc(y);

    %
    % Run genip
    %
    [zq, kalmanObj, info] = genip( ...
        x, Frequency.QUARTERLY, 'Rate', dy ...
    );

    %
    % Test output series
    %
    zy = convert(zq, Frequency.YEARLY);
    assertEqual(this, getData(zy, lowRange), getData(x, lowRange), 'AbsTol', 1e-7);

    % 
    % Test aggregation matrix
    %
    Z = kalmanObj.SystemMatrices{4};
    assertEqual(this, Z(:, :, 2), [1/4, 1/4, 1/4, 1/4, 0; 0, 0, 0, 1, 0; 1, 0, 0, 0, -1]);

    %
    % Test size of transition matrix
    %
    T = kalmanObj.SystemMatrices{1};
    T = reshape(T(4, 4, 2:end), [ ], 1);
    assertEqual(this, T, getData(dy, highRange(5:end)), 'AbsTol', 1e-10);

    % 
    % Test default versus explicit option Aggregation=
    %
    [zq1, kalmanObject1] = genip( ...
        x, Frequency.QUARTERLY, 'Rate', dy ...
        , 'Aggregation=', @mean...
    );
    assertEqual(this, zq.Data, zq1.Data, 'AbsTol', 1e-10);

    tempRange = highRange(9:end);
    xi1 = retrieveColumns(info.OutputData.SmoothMean.Xi, 1);
    xi2 = retrieveColumns(info.OutputData.SmoothMean.Xi, 2);
    xi3 = retrieveColumns(info.OutputData.SmoothMean.Xi, 3);
    xi4 = retrieveColumns(info.OutputData.SmoothMean.Xi, 4);
    assertEqual(this, getData(xi4, tempRange-1), getData(xi3, tempRange), 'AbsTol', 1e-7); 
    assertEqual(this, getData(xi4, tempRange-2), getData(xi2, tempRange), 'AbsTol', 1e-7); 
    assertEqual(this, getData(xi4, tempRange-3), getData(xi1, tempRange), 'AbsTol', 1e-7); 

    %
    % Test default versus explicit Range=
    %
    [zq2, kalmanObject2] = genip( ...
        x, Frequency.QUARTERLY, 'Rate', dy ...
        , 'Range', lowRange ...
    );
    assertEqual(this, zq.Data, zq2.Data, 'AbsTol', 1e-10);
end%




function meanLevelTest(testCase)
    lowRange = yy(2001):yy(2020);
    highStart = qq(lowRange(1)-1, 1);
    highEnd = qq(lowRange(end), 4);
    highRange = highStart:highEnd;
    x = Series(lowRange, randn(numel(lowRange), 1));
    ind = Series(highRange, randn(numel(highRange), 1));

    [z0, kalmanObj0, info0] = genip( ...
        x, Frequency.QUARTERLY, 'Level', 0 ...
    );
    [z1, kalmanObj1, info1] = genip( ...
        x, Frequency.QUARTERLY, 'Level', ind ...
    );

    assertEqual(testCase, getData(convert(z0, 1), lowRange), getData(x, lowRange), 'AbsTol', 1e-7);
    assertEqual(testCase, getData(convert(z1, 1), lowRange), getData(x, lowRange), 'AbsTol', 1e-7);
    [~, r0] = acf([ind, z0]);
    [~, r1] = acf([ind, z1]);
    assertGreaterThan(testCase, r1(2, 1), 0);
    assertGreaterThan(testCase, r1(2, 1), 3*r0(2, 1));
    T = [0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1; 0, 0, 0, 0];
    assertEqual(testCase, kalmanObj0.SystemMatrices{1}(1:end-1, 1:end-1, 2), T);
    assertEqual(testCase, kalmanObj1.SystemMatrices{1}(1:end-1, 1:end-1, 2), T);
end%




function meanDiffTest(testCase)
    lowRange = yy(2001):yy(2020);
    highStart = qq(lowRange(1)-1, 1);
    highEnd = qq(lowRange(end), 4);
    highRange = highStart:highEnd;
    x = Series(lowRange, randn(numel(lowRange), 1));
    ind = Series(highRange, randn(numel(highRange), 1));
    dind = diff(ind);

    [z0, kalmanObj0, info0] = genip( ...
        x, Frequency.QUARTERLY, 'Diff', 0 ...
    );
    [z1, kalmanObj1, info1] = genip( ...
        x, Frequency.QUARTERLY, 'Diff', dind ...
    );

    assertEqual(testCase, getData(convert(z0, 1), lowRange), getData(x, lowRange), 'AbsTol', 1e-7);
    assertEqual(testCase, getData(convert(z1, 1), lowRange), getData(x, lowRange), 'AbsTol', 1e-7);
    [~, r0] = acf([dind, diff(z0)]);
    [~, r1] = acf([dind, diff(z1)]);
    assertGreaterThan(testCase, r1(2, 1), 0);
    assertGreaterThan(testCase, r1(2, 1), 5*abs(r0(2, 1)));
    T = [0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1; 0, 0, 0, 1];
    assertEqual(testCase, kalmanObj0.SystemMatrices{1}(1:end-1, 1:end-1, 2), T);
    assertEqual(testCase, kalmanObj1.SystemMatrices{1}(1:end-1, 1:end-1, 2), T);
end%




function meanDiffDiffTest(testCase)
    lowRange = yy(2001):yy(2020);
    highStart = qq(lowRange(1)-1, 1);
    highEnd = qq(lowRange(end), 4);
    highRange = highStart:highEnd;
    x = Series(lowRange, randn(numel(lowRange), 1));
    ind = Series(highRange, randn(numel(highRange), 1));
    ddind = diff(diff(ind));

    [z0, kalmanObj0, info0] = genip( ...
        x, Frequency.QUARTERLY, 'DiffDiff', 0 ...
    );
    [z1, kalmanObj1, info1] = genip( ...
        x, Frequency.QUARTERLY, 'DiffDiff', ddind ...
    );

    assertEqual(testCase, getData(convert(z0, 1), lowRange), getData(x, lowRange), 'AbsTol', 1e-7);
    assertEqual(testCase, getData(convert(z1, 1), lowRange), getData(x, lowRange), 'AbsTol', 1e-7);
    [~, r0] = acf([ddind, diff(diff(z0))]);
    [~, r1] = acf([ddind, diff(diff(z1))]);
    assertGreaterThan(testCase, r1(2, 1), 0);
    assertGreaterThan(testCase, r1(2, 1), 5*abs(r0(2, 1)));
    T = [0, 1, 0, 0; 0, 0, 1 0; 0, 0, 0, 1; 0, 0, -1, 2];
    assertEqual(testCase, kalmanObj0.SystemMatrices{1}(1:end-1, 1:end-1, 2), T);
    assertEqual(testCase, kalmanObj1.SystemMatrices{1}(1:end-1, 1:end-1, 2), T);
end%




function averageTest(this)
    lowRange = yy(2001):yy(2020);
    highStart = qq(lowRange(1)-1, 1);
    highEnd = qq(lowRange(end), 4);
    highRange = highStart:highEnd;
    x = Series(lowRange, exp(cumsum(randn(numel(lowRange), 1)/40)));
    y = Series(highStart:highEnd, exp(cumsum(randn(numel(highRange), 1)/40)));
    dy = roc(y);

    [zq, kalmanObj] = genip( ...
        x, Frequency.QUARTERLY, 'Rate', dy ...
    );

    %
    % Test output series
    %
    zy = convert(zq, Frequency.YEARLY, 'Method=', @mean);
    assertEqual(this, getData(zy, lowRange), getData(x, lowRange), 'AbsTol', 1e-7);

    %
    % Test aggregation matrix
    %
    Z = kalmanObj.SystemMatrices{4};
    assertEqual(this, Z(:, :, 2), [[1, 1, 1, 1, 0]/4; 0, 0, 0, 1, 0; 1, 0, 0, 0, -1]);

    % 
    % Test size of transition matrix
    %
    T = kalmanObj.SystemMatrices{1};
    T = reshape(T(4, 4, 2:end), [ ], 1);
    assertEqual(this, T, getData(dy, highRange(5:end)), 'AbsTol', 1e-10);
end%




function lastTest(this)
    lowRange = yy(2001):yy(2020);
    highStart = qq(lowRange(1)-1, 1);
    highEnd = qq(lowRange(end), 4);
    highRange = highStart:highEnd;
    x = Series(lowRange, exp(cumsum(randn(numel(lowRange), 1)/40)));
    y = Series(highStart:highEnd, exp(cumsum(randn(numel(highRange), 1)/40)));
    dy = roc(y);

    %
    % Run genip
    %
    [zq, kalmanObj] = genip( ...
        x, Frequency.QUARTERLY, 'Rate', dy ...
        , 'Aggregation=', 'last' ...
    );

    %
    % Test output series
    %
    zy = convert(zq, Frequency.YEARLY, 'Method=', 'last');
    assertEqual(this, getData(zy, lowRange), getData(x, lowRange), 'AbsTol', 1e-7);

    %
    % Test aggregation matrix
    %
    Z = kalmanObj.SystemMatrices{4};
    assertEqual(this, Z(:, :, 2), [0, 0, 0, 1, 0; 0, 0, 0, 1, 0; 1, 0, 0, 0, -1]);

    % 
    % Test size of transition matrix
    %
    T = kalmanObj.SystemMatrices{1};
    T = reshape(T(4, 4, 2:end), [ ], 1);
    assertEqual(this, T, getData(dy, highRange(5:end)), 'AbsTol', 1e-10);
end%




function userSuppliedAggregationTest(this)
    lowRange = yy(2001):yy(2020);
    highStart = qq(lowRange(1)-1, 1);
    highEnd = qq(lowRange(end), 4);
    highRange = highStart:highEnd;
    x = Series(lowRange, exp(cumsum(randn(numel(lowRange), 1)/40)));
    y = Series(highStart:highEnd, exp(cumsum(randn(numel(highRange), 1)/40)));
    dy = roc(y);

    aggregation = randn(1, 4);
    aggregation = aggregation / sum(aggregation, 2);
    [zq, kalmanObj] = genip( ...
        x, Frequency.QUARTERLY, 'Rate', dy ...
        , 'Aggregation=', aggregation ...
    );

    %
    % Test output series
    %
    zy = convert(zq, Frequency.YEARLY, 'Method=', aggregation);
    assertEqual(this, getData(zy, lowRange), getData(x, lowRange), 'AbsTol', 1e-7);

    %
    % Test aggregation matrix
    %
    Z = kalmanObj.SystemMatrices{4};
    assertEqual(this, Z(:, :, 2), [aggregation, 0; 0, 0, 0, 1, 0; 1, 0, 0, 0, -1]);
end%




function identicalTest(this)
    lowRange = yy(2001):yy(2020);
    highStart = qq(lowRange(1)-1, 1);
    highEnd = qq(lowRange(end), 4);
    highRange = highStart:highEnd;
    testRange = qq(lowRange(1), 1) : highEnd;
    y = 100*Series(highStart:highEnd, exp(cumsum(randn(numel(highRange), 1)/100)));
    dy = roc(y);

    %
    % Aggregation=sum
    %
    x = convert(y, Frequency.YEARLY, 'Method=', 'sum');
    [zq, kalmanObj, info] = genip( ...
        x, Frequency.QUARTERLY, 'Rate', dy ...
        , 'Aggregation=', 'sum' ...
        , 'Range=', lowRange ...
    );
    assertEqual(this, getData(zq, testRange), getData(y, testRange), 'AbsTol', 1e-7);

    %
    % Aggregation=mean (average)
    %
    x = convert(y, Frequency.YEARLY, 'Method=', 'mean');
    [zq, kalmanObj] = genip( ...
        x, Frequency.QUARTERLY, 'Rate', dy ...
        , 'Aggregation=', 'mean' ...
        , 'Range=', lowRange ...
    );
    assertEqual(this, getData(zq, testRange), getData(y, testRange), 'AbsTol', 1e-7);

    %
    % Aggregation=last 
    %
    x = convert(y, Frequency.YEARLY, 'Method=', 'last');
    [zq, kalmanObj] = genip( ...
        x, Frequency.QUARTERLY, 'Rate', dy ...
        , 'Aggregation=', 'last' ...
        , 'Range=', lowRange ...
    );
    assertEqual(this, getData(zq, testRange), getData(y, testRange), 'AbsTol', 1e-7);

    %
    % Aggregation=[...]
    %
    aggregation = 0.5 + 0.5*rand(1, 4);
    x = convert(y, Frequency.YEARLY, 'Method=', aggregation);
    [zq, kalmanObj] = genip( ...
        x, Frequency.QUARTERLY, 'Rate', dy ...
        , 'Aggregation=', aggregation ...
        , 'Range=', lowRange ...
    );
    assertEqual(this, getData(zq, testRange), getData(y, testRange), 'AbsTol', 1e-7);
end%
%)

