% setupKalmanObject  Set up StackedLinearSystem and array of observed data for genip model
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function ...
    [stacked, Y, Xi0, transition, indicator] ...
    = setupStackedSystem(lowLevel, aggregation, transition, hard, indicator, Xi0)

    persistent STACKED_LINEAR_SYSTEM
    if ~isa(STACKED_LINEAR_SYSTEM, 'StackedLinearSystem')
        STACKED_LINEAR_SYSTEM = StackedLinearSystem();
    end

    here_normalizeIndicator( );
    here_createFlippedTimeSeries( );

    numInit = transition.NumInit;
    numWithin = size(aggregation.Model, 2);

    numLowPeriods = size(lowLevel, 1);
    numHighPeriods = numWithin*numLowPeriods;

    if isequal(transition.Order, 0)
        R = eye(numHighPeriods);
        T = zeros(numHighPeriods, numInit);
    elseif isequal(transition.Order, 1)
        R = triu(toeplitz(ones(1, numHighPeriods)));
        T = [ones(numHighPeriods, 1), zeros(numHighPeriods, 1)];
    elseif isequal(transition.Order, 2)
        R = triu(toeplitz(1:numHighPeriods));
        T = [ (numHighPeriods+1:-1:2)', -(numHighPeriods:-1:1)' ];
    end
    if isscalar(transition.Std)
        transition.Std = repmat(transition.Std, numHighPeriods, 1);
    end
    stdV = reshape(transition.Std, [ ], 1);
    R = [R; zeros(numInit, numHighPeriods)];
    T = [T; eye(numInit)];

    Y = zeros(0, 1);
    Z = zeros(0, numHighPeriods+numInit);
    H = zeros(0);
    d = 0;
    stdW = zeros(0, 1);


    %
    % Add aggregation to measurement
    %
    here_addAggregation( );


    %
    % Add hard conditions to measurement
    %
    here_addHardLevel( );
    here_addHardDiff( );
    here_addHardRate( );


    %
    % Adjust measurement matrix and intercept for indicator
    %
    here_adjustForIndicator();

    K = here_setupTransitionIntercept();

    stacked = STACKED_LINEAR_SYSTEM;
    stacked.SystemMatrices = {T, R, K, Z, H, d, [ ], [ ]};
    stacked.StdVectors = {stdV, stdW};

return
    
    function here_normalizeIndicator( )
        %(
        if isempty(indicator.Level)
            return
        end
        if indicator.Model=="difference"
            indicator.Level = indicator.Level - indicator.Level(end);
        elseif indicator.Model=="ratio"
            indicator.Level = indicator.Level / indicator.Level(end);
        end
        %)
    end%


    function here_createFlippedTimeSeries( )
        %(
        if ~isempty(indicator.Level)
            indicator.LevelFlipped = indicator.Level(end:-1:1);
        end
        if ~isempty(hard.Level)
            hard.LevelFlipped = hard.Level(end:-1:1);
        end
        if ~isempty(hard.Diff)
            hard.DiffFlipped = hard.Diff(end:-1:1);
        end
        if ~isempty(hard.Rate)
            hard.RateFlipped = hard.Rate(end:-1:1);
        end
        %)
    end%


    function here_addAggregation( )
        %(
        lowLevelFlipped = lowLevel(end:-1:1);
        inxAggregation = isfinite(lowLevelFlipped);
        if ~any(inxAggregation)
            return
        end

        numAggregation = nnz(inxAggregation);
        row = zeros(1, numHighPeriods);
        row(1:numWithin) = aggregation.ModelFlipped;
        for i = reshape(find(inxAggregation), 1, [ ])
            addZ = [circshift(row, [0, (i-1)*numWithin]), zeros(1, numInit)];
            Z = [Z; addZ];
        end
        Y = [Y; reshape(lowLevelFlipped(inxAggregation), [ ], 1)];
        H = [H; zeros(numAggregation, 0)];
        %)
    end%


    function here_addHardLevel( )
        %(
        if isempty(hard.Level)
            return
        end

        hard.LevelFlipped(end-numInit+1:end) = NaN;
        inxConditionsLevel = isfinite(hard.LevelFlipped);
        if ~any(inxConditionsLevel)
            return
        end

        numHardLevel = nnz(inxConditionsLevel);
        addZ = eye(numHighPeriods+numInit);
        addZ = addZ(inxConditionsLevel, :);
        Z = [Z; addZ];
        Y = [Y; reshape(hard.LevelFlipped(inxConditionsLevel), [ ], 1)];
        H = [H; zeros(numHardLevel, 0)];
        %)
    end%


    function here_addHardDiff( )
        %(
        if isempty(hard.Diff)
            return
        end

        hard.DiffFlipped(end-numInit+1:end) = NaN;
        inxHardDiff = isfinite(hard.DiffFlipped);
        if ~any(inxHardDiff)
            return
        end

        numHardDiff = nnz(inxHardDiff);
        addZ = eye(numHighPeriods+numInit) - diag(ones(numHighPeriods+numInit-1, 1), 1);
        addZ = addZ(inxHardDiff, :);
        Z = [Z; addZ];
        Y = [Y; reshape(hard.DiffFlipped(inxHardDiff), [ ], 1)];
        H = [H; zeros(numHardDiff, 0)];
        %)
    end%


    function here_addHardRate( )
        %(
        if isempty(hard.Rate)
            return
        end

        hard.RateFlipped(end-numInit+1:end) = NaN;
        inxHardRate = isfinite(hard.RateFlipped);
        if ~any(inxHardRate)
            return
        end

        numHardRate = nnz(inxHardRate);
        addZ = eye(numHighPeriods+numInit) - diag(hard.RateFlipped(1:end-1), 1);
        addZ = addZ(inxHardRate, :);
        Z = [Z; addZ];
        Y = [Y; zeros(numHardRate, 1)];
        H = [H; zeros(numHardRate, 0)];
        %)
    end%


    function here_adjustForIndicator()
        %(
        if isempty(indicator.Level)
            return
        elseif indicator.Model=="difference"
            d = Z*indicator.LevelFlipped; 
            if ~isempty(Xi0)
                Xi0 = Xi0 - indicator.LevelFlipped(end-numInit+1:end);
            end
        elseif indicator.Model=="ratio"
            Z = Z .* reshape(indicator.LevelFlipped, 1, [ ]);
            if ~isempty(Xi0)
                Xi0 = Xi0 ./ indicator.LevelFlipped(end-numInit+1:end);
            end
        end
        %)
    end%


    function K = here_setupTransitionIntercept()
        %(
        if isequal(transition.Intercept, @auto)
            addT = ones(numHighPeriods, 1);
            for ii = 1 : transition.Order
                addT = cumsum(addT, 1);
            end
            addT = [addT; zeros(numInit, 1)];
            T = [T, addT];
            Xi0 = [Xi0; NaN];
            K = 0;
        else
            K = R*repmat(transition.Intercept, numHighPeriods, 1);
        end
        %)
    end%
end%

