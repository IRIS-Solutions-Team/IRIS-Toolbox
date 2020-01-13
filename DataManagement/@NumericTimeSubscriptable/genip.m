function varargout = genip(varargin)
% genip  Generalized indicator based interpolation
%{
% ## Syntax ##
%
%     interp = genip(yearlySeries, quarterlyIndicator, yearlyRange, ...)
%
%
% ## Input Arguments ##
%
% __`yearlySeries`__ [ Series ] -
% Input time yearlySeries at yearly frequency that will be converted to quarterly
% frequency using the `quarterlyIndicator`.
%
% __`quarterlyIndicator`__ [ Series ] -
% Indicator time yearlySeries at quarterly frequency whose dynamics will be used
% to interpolate the `yearlySeries`.
%
% __`yearlyRange`__ [ DateWrapper ] -
% Date range at yearly frequency; the `yearlySeries` data will be
% interpolated within this range to quarterly frequency.
%
%
% ## Output Arguments ##
%
% __`interp`__ [ Series ] -
% Output time yearlySeries at quarterly frequency constructed by interpolating
% the input `yearlySeries` using the dynamics of the `quarterlyIndicator`.
% 
%
% ## Options ##
%
% __`Aggregation='sum'`__ [ `'average'` | `'sum'` | `'endYear'` | numeric ] -
% Type of aggregation of quarterly observations to yearly observations; the
% option `Aggregation=` can be assigned a `1-by-4` numeric vector with the
% weights given, respectively, to the 1st, 2nd, 3rd and 4th quarter.
%
% __`RescaleIndicator=true`__ [ `true` | `false` ] -
% Rescale the initical condition extracted from the `quarterlyIndicator` by
% the average ratio of the `yearlySeries` to the `yearlyIndicator` on the
% interpolation range, where `yearlyIndicator` is the `quarterlyIndicator`
% converted to yearly frequency using the same aggregation method as the
% option `Aggregation=`.
%
%
% ## Description ##
%
% The interpolated `yearlySeries` is obtained from the first element of the state
% vector estimated using the following quarterly state-space model
% estimated by a Kalman filter:
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
% quarterly yearlySeries lags \(t-3\), \(t-2\), \(t-1\), and its current
% dated value.
%
% * \( T_t \) is a time-varying transition matrix based on the quarterly rate
% of change in the indicator variables, \(\rho_t = i_t / i_{t-1}\)
%
% \[ T_t = \begin{bmatrix} rho_t & 0 & 0 & 0 \\ 
%                              1 & 0 & 0 & 0 \\ 
%                              0 & 1 & 0 & 0 \\
%                              0 & 0 & 1 & 0 \end{bmatrix} \]
% 
% * \( Z \) is a time-invariant aggregation matrix depending on the option
% `Aggregation=`: 
% \( Z=[1, 1, 1, 1] \) for `Aggregation='sum'`, 
% \( Z=[1/4, 1/4, 1/4, 1/4] \) for `Aggregation='average'`, 
% \( Z=[0, 0, 0, 1] \) for `Aggregation='endYear'`, 
% or a user supplied 1-by-4 vector
%
% * \( v_t \) is a transition error with constant variance
%
%
% ## Syntax to Run Unit Tests ##
%
%     run(genip('test'))
%
%
% ## Example ##
%
%}

%
% Unit test `run(genip('test'))` 
%
if nargin==1 && strcmp(varargin{1}, 'test')
    varargout{1} = functiontests(localfunctions( ));
    return
end

%
% Parse input arguments
%
persistent pp
if isempty(pp)
    pp = extend.InputParser('genip');
    addRequired(pp, 'yearlySeries', @(x) isa(x, 'NumericTimeSubscriptable') && x.Frequency==Frequency.YEARLY);
    addRequired(pp, 'quarterlyIndicator', @(x) isequal(x, @auto) || validate.numericScalar(x) || (isa(x, 'NumericTimeSubscriptable') && x.FrequencyAsNumeric==Frequency.QUARTERLY));
    addRequired(pp, 'yearlyRange', @hereValidateYearlyRange);
    % Options
    addParameter(pp, 'Aggregation', 'sum', @hereValidateAggregation);
    addParameter(pp, 'RescaleIndicator', true, @validate.logicalScalar);
    addParameter(pp, 'InitCond', @auto);
    addParameter(pp, 'StdScale', @auto, @(x) isequal(x, @auto) || isa(x, 'NumericTimeSubscriptable'));
end
parse(pp, varargin{:});
yearlySeries = pp.Results.yearlySeries;
quarterlyIndicator = pp.Results.quarterlyIndicator;
yearlyRange = pp.Results.yearlyRange;
opt = pp.Options;

%--------------------------------------------------------------------------

%
% Define yearly dates
% 
yearlyRange = double(yearlyRange);
startYear = yearlyRange(1);
endYear = yearlyRange(end);
numYears = round(endYear - startYear + 1);

%
% Resolve quarterly indicator
%
hereResolveQuarterlyIndicator( );

%
% Resolve Aggregation= option
%
aggregation = hereResolveAggregation(opt.Aggregation);

%
% Define quarterly dates
%
startQuarter = convert(startYear, Frequency.QUARTERLY);
endQuarter = convert(endYear, Frequency.QUARTERLY) + 3;
numQuarters = endQuarter - startQuarter + 1;

%
% Set up a linear Kalman filter object
%
kalmanObject = hereSetupKalmanObject( );

%
% Create quarterly measurement variable
%
observed = convert(yearlySeries, Frequency.QUARTERLY, 'Method=', 'WriteToEnd');

%
% Run Kalman filter with fixed initial condition
%
if isequal(opt.InitCond, @auto)
    x0 = getDataFromTo(yearlySeries, startYear, startYear);
    x0 = x0 / sum(aggregation(:));
    initCond = {repmat(x0, 4, 1), ones(4)*kalmanObject.DIFFUSE_SCALE};
else
    initCond = opt.InitCond;
end
outputData = filter( kalmanObject, observed, startQuarter:endQuarter, ...
                     'Init=', initCond, 'Relative=', false );

%
% Extract the 4th state variable
%
quarterlySeries = retrieveColumns(outputData.SmoothMean.Xi, 4);
quarterlySeries = clip(quarterlySeries, startQuarter, endQuarter);

outputInfo = struct( );
if nargout>=3
    outputInfo.InitCond = initCond;
    outputInfo.OutputData = outputData;
end


%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
varargout = { quarterlySeries, kalmanObject, outputInfo };
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

return

    function kalmanObject = hereSetupKalmanObject( )
        T = zeros(4, 4, numQuarters);
        if isa(quarterlyIndicator, 'NumericTimeSubscriptable')
            T(4, 4, :) = getDataFromTo(quarterlyIndicator, startQuarter, endQuarter);
        else
            T(4, 4, :) = quarterlyIndicator;
        end
        T(3, 4, :) = 1;
        T(2, 3, :) = 1;
        T(1, 2, :) = 1;

        R = [0; 0; 0; 1];
        k = zeros(4, 1);
        Z = aggregation;
        H = zeros(1, 0);
        d = zeros(1, 1);

        if isa(opt.StdScale, 'NumericTimeSubscriptable')
            stdScale = getDataFromTo(opt.StdScale, startQuarter, endQuarter);
            stdScale = abs(stdScale);
            stdScale = stdScale/stdScale(1);
            stdScale = reshape(stdScale, 1, 1, [ ]);
            OmegaV = stdScale.^2;
        else
            OmegaV = 1;
        end
        OmegaW = [ ];

        kalmanObject = BareLinearKalman([4, 1, 1, 0], numQuarters);
        kalmanObject = steadySystem(kalmanObject, 'NotNeeded');
        kalmanObject = timeVaryingSystem(kalmanObject, 1:numQuarters, {T, R, k, Z, H, d}, {OmegaV, OmegaW});
    end%


    function hereResolveQuarterlyIndicator( )
        if ~isequal(quarterlyIndicator, @auto)
            return
        end
        yearlyData = getDataFromTo(yearlySeries, startYear, endYear);
        quarterlyIndicator = (yearlyData(end)/yearlyData(1))^(1/(4*numYears));
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
    if any(strcmpi(x, {'sum', 'average', 'mean', 'last'}))
        flag = true;
        return
    end
    if isnumeric(x) && isequal(size(x), [1, 4])
        flag = true;
        return
    end
    flag = false;
end%


function aggregation = hereResolveAggregation(aggregation)
    if isnumeric(aggregation)
        return
    end
    if any(strcmpi(aggregation, {'average', 'mean'}))
        aggregation = [1, 1, 1, 1]/4;
        return
    elseif strcmpi(aggregation, 'last')
        aggregation = [0, 0, 0, 1];
        return
    elseif strcmpi(aggregation, 'first')
        aggregation = [1, 0, 0, 0];
    else
        % Default 'sum'
        aggregation = [1, 1, 1, 1];
        return
    end
end%


%
% Unit test functions
%
%(
function sumTest(this)
    yearlyRange = yy(2001):yy(2020);
    startQuarter = qq(yearlyRange(1)-1, 1);
    endQuarter = qq(yearlyRange(end), 4);
    quarterlyRange = startQuarter:endQuarter;
    x = Series(yearlyRange, exp(cumsum(randn(numel(yearlyRange), 1)/10)));
    y = Series(startQuarter:endQuarter, exp(cumsum(randn(numel(quarterlyRange), 1)/40)));
    dy = roc(y);

    %
    % Run genip
    %
    [zq, kalmanObject] = genip(x, y, yearlyRange);

    %
    % Test output series
    %
    zy = convert(zq, Frequency.YEARLY, 'Method=', @sum);
    assertEqual(this, zy(yearlyRange), x(yearlyRange), 'AbsTol', 1e-10);

    % 
    % Test aggregation matrix
    %
    Z = kalmanObject.SystemMatrices{4};
    assertEqual(this, Z(:, :, 2), [1, 1, 1, 1]);

    %
    % Test size of transition matrix
    %
    T = kalmanObject.SystemMatrices{1};
    T = reshape(T(4, 4, 2:end), [ ], 1);
    assertEqual(this, T, dy(quarterlyRange(5:end)), 'AbsTol', 1e-10);

    % 
    % Test default versus explicit option Aggregation=
    %
    [zq1, kalmanObject1] = genip(x, y, yearlyRange, 'Aggregation=', 'sum');
    assertEqual(this, zq.Data, zq1.Data, 'AbsTol', 1e-15);
    Z1 = kalmanObject1.SystemMatrices{4};
    assertEqual(this, Z1(:, :, 2), [1, 1, 1, 1]);
end%




function averageTest(this)
    yearlyRange = yy(2001):yy(2020);
    startQuarter = qq(yearlyRange(1)-1, 1);
    endQuarter = qq(yearlyRange(end), 4);
    quarterlyRange = startQuarter:endQuarter;
    x = Series(yearlyRange, exp(cumsum(randn(numel(yearlyRange), 1)/40)));
    y = Series(startQuarter:endQuarter, exp(cumsum(randn(numel(quarterlyRange), 1)/40)));
    dy = roc(y);

    %
    % Run genip
    %
    [zq, kalmanObject] = genip(x, y, yearlyRange, 'Aggregation=', 'average');

    %
    % Test output series
    %
    zy = convert(zq, Frequency.YEARLY, 'Method=', @mean);
    assertEqual(this, zy(yearlyRange), x(yearlyRange), 'AbsTol', 1e-10);

    %
    % Test aggregation matrix
    %
    Z = kalmanObject.SystemMatrices{4};
    assertEqual(this, Z(:, :, 2), [1, 1, 1, 1]/4);

    % 
    % Test size of transition matrix
    %
    T = kalmanObject.SystemMatrices{1};
    T = reshape(T(4, 4, 2:end), [ ], 1);
    assertEqual(this, T, dy(quarterlyRange(5:end)), 'AbsTol', 1e-10);
end%




function endYearTest(this)
    yearlyRange = yy(2001):yy(2020);
    startQuarter = qq(yearlyRange(1)-1, 1);
    endQuarter = qq(yearlyRange(end), 4);
    quarterlyRange = startQuarter:endQuarter;
    x = Series(yearlyRange, exp(cumsum(randn(numel(yearlyRange), 1)/40)));
    y = Series(startQuarter:endQuarter, exp(cumsum(randn(numel(quarterlyRange), 1)/40)));
    dy = roc(y);

    %
    % Run genip
    %
    [zq, kalmanObject] = genip(x, y, yearlyRange, 'Aggregation=', 'endYear');

    %
    % Test output series
    %
    zy = convert(zq, Frequency.YEARLY, 'Method=', 'last');
    assertEqual(this, zy(yearlyRange), x(yearlyRange), 'AbsTol', 1e-10);

    %
    % Test aggregation matrix
    %
    Z = kalmanObject.SystemMatrices{4};
    assertEqual(this, Z(:, :, 2), [0, 0, 0, 1]);

    % 
    % Test size of transition matrix
    %
    T = kalmanObject.SystemMatrices{1};
    T = reshape(T(4, 4, 2:end), [ ], 1);
    assertEqual(this, T, dy(quarterlyRange(5:end)), 'AbsTol', 1e-10);
end%




function userSuppliedAggregationTest(this)
    yearlyRange = yy(2001):yy(2020);
    startQuarter = qq(yearlyRange(1)-1, 1);
    endQuarter = qq(yearlyRange(end), 4);
    quarterlyRange = startQuarter:endQuarter;
    x = Series(yearlyRange, exp(cumsum(randn(numel(yearlyRange), 1)/40)));
    y = Series(startQuarter:endQuarter, exp(cumsum(randn(numel(quarterlyRange), 1)/40)));
    dy = roc(y);

    %
    % Run genip
    %
    aggregation = randn(1, 4);
    aggregation = aggregation / sum(aggregation, 2);
    [zq, kalmanObject] = genip(x, y, yearlyRange, 'Aggregation=', aggregation);

    %
    % Test output series
    %
    zy = convert(zq, Frequency.YEARLY, 'Method=', aggregation);
    assertEqual(this, zy(yearlyRange), x(yearlyRange), 'AbsTol', 1e-10);

    %
    % Test aggregation matrix
    %
    Z = kalmanObject.SystemMatrices{4};
    assertEqual(this, Z(:, :, 2), aggregation);
end%




function identicalTest(this)
    yearlyRange = yy(2001):yy(2020);
    startQuarter = qq(yearlyRange(1)-1, 1);
    endQuarter = qq(yearlyRange(end), 4);
    quarterlyRange = startQuarter:endQuarter;
    testRange = qq(yearlyRange(1), 1) : endQuarter;
    y = Series(startQuarter:endQuarter, exp(cumsum(randn(numel(quarterlyRange), 1)/40)));

    %
    % Aggregation=sum
    %
    x = 100*convert(y, Frequency.YEARLY, 'Method=', 'sum');
    [zq, kalmanObject] = genip(x, y, yearlyRange, 'Aggregation=', 'sum');
    assertEqual(this, zq(testRange), 100*y(testRange), 'AbsTol', 1e-10);

    %
    % Aggregation=sum, RescaleIndicator=false
    % Test NotEqual
    %
    x = 100*convert(y, Frequency.YEARLY, 'Method=', 'sum');
    [zq, kalmanObject] = genip(x, y, yearlyRange, 'Aggregation=', 'sum', 'RescaleIndicator=', false);
    assertNotEqual(this, round(zq(testRange)), round(100*y(testRange)));

    %
    % Aggregation=mean (average)
    %
    x = 100*convert(y, Frequency.YEARLY, 'Method=', 'mean');
    [zq, kalmanObject] = genip(x, y, yearlyRange, 'Aggregation=', 'mean');
    assertEqual(this, zq(testRange), 100*y(testRange), 'AbsTol', 1e-10);

    %
    % Aggregation=last (endYear)
    %
    x = 100*convert(y, Frequency.YEARLY, 'Method=', 'last');
    [zq, kalmanObject] = genip(x, y, yearlyRange, 'Aggregation=', 'last');
    assertEqual(this, zq(testRange), 100*y(testRange), 'AbsTol', 1e-10);

    %
    % Aggregation=[...]
    %
    aggregation = rand(1, 4);
    x = 100*convert(y, Frequency.YEARLY, 'Method=', aggregation);
    [zq, kalmanObject] = genip(x, y, yearlyRange, 'Aggregation=', aggregation);
    assertEqual(this, zq(testRange), 100*y(testRange), 'AbsTol', 1e-10);
end%
%)

