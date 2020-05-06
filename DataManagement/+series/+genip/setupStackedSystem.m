function [stacked, Y, Xi0, transition, indicator] = ...
    setupStackedSystem(lowLevel, aggregation, transition, hard, indicator)
% setupKalmanObject  Set up time-varying LinearSystem and array of observed data for genip model
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent STACKED_LINEAR_SYSTEM
if ~isa(STACKED_LINEAR_SYSTEM, 'StackedLinearSystem')
    STACKED_LINEAR_SYSTEM = StackedLinearSystem( );
end

%--------------------------------------------------------------------------

hereNormalizeIndicator( );
hereCreateFlippedTimeSeries( );

numWithin = size(aggregation.Model, 2);
numInit = transition.Order;

numLowPeriods = size(lowLevel, 1);
numHighPeriods = numWithin*numLowPeriods;

if isequal(transition.Order, 0)
    R = eye(numHighPeriods);
    T = zeros(numHighPeriods, 0);
elseif isequal(transition.Order, 1)
    R = triu(toeplitz(ones(1, numHighPeriods)));
    T = ones(numHighPeriods, 1);
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
Xi0 = nan(numInit, 1);


%
% Add aggregation to measurement
%
hereAddAggregation( );


%
% Add hard.Level to measurement
%
hereAddConditionsLevel( );


%
% Adjust measurement matrix and intercept for indicator
%
hereAdjustForIndicator( );

K = hereSetupTransitionIntercept( );

stacked = STACKED_LINEAR_SYSTEM;
stacked.SystemMatrices = {T, R, K, Z, H, d, [ ], [ ]};
stacked.StdVectors = {stdV, stdW};

return
    
    function hereNormalizeIndicator( )
        %(
        if isempty(indicator.Level)
            return
        end
        if indicator.Model=="Difference"
            indicator.Level = indicator.Level - indicator.Level(end);
        elseif indicator.Model=="Ratio"
            indicator.Level = indicator.Level / indicator.Level(end);
        end
        %)
    end%


    function hereCreateFlippedTimeSeries( )
        %(
        if ~isempty(indicator.Level)
            indicator.LevelFlipped = indicator.Level(end:-1:1);
        end
        if ~isempty(hard.Level)
            hard.LevelFlipped = hard.Level(end:-1:1);
        end
        %)
    end%


    function K = hereSetupTransitionIntercept( )
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


    function hereAddAggregation( )
        %(
        lowLevelFlipped = lowLevel(end:-1:1);
        inxAggregation = isfinite(lowLevelFlipped);
        if any(inxAggregation)
            aggregation.ModelFlipped = aggregation.Model(end:-1:1);
            numAggregation = nnz(inxAggregation);
            rowZ = zeros(1, numHighPeriods+numInit);
            rowZ(1:numWithin) = aggregation.ModelFlipped;
            for i = reshape(find(inxAggregation), 1, [ ])
                Z = [ Z; circshift(rowZ, [1, numWithin*(i-1)]) ];
            end
            Y = [Y; reshape(lowLevelFlipped(inxAggregation), [ ], 1)];
            H = [H; zeros(numAggregation, 0)];
        end
        %)
    end%


    function hereAddConditionsLevel( )
        %(
        if isempty(hard.Level)
            return
        end

        Xi0 = hard.LevelFlipped(end-numInit+1:end);
        hard.LevelFlipped(end-numInit+1:end) = NaN;

        inxConditionsLevel = isfinite(hard.LevelFlipped);
        if any(inxConditionsLevel)
            numConditionsLevel = nnz(inxConditionsLevel);
            addZ = eye(numHighPeriods+numInit, numHighPeriods+numInit);
            addZ = addZ(inxConditionsLevel, :);
            Z = [Z; addZ];
            Y = [Y; reshape(hard.LevelFlipped(inxConditionsLevel), [ ], 1)];
            H = [H; zeros(numConditionsLevel, 0)];
        end
        %)
    end%


    function hereAdjustForIndicator( )
        %(
        if isempty(indicator.Level)
            return
        elseif indicator.Model=="Difference"
            d = Z*indicator.LevelFlipped; 
            Xi0 = Xi0 - indicator.LevelFlipped(end-numInit+1:end);
        elseif indicator.Model=="Ratio"
            Z = Z .* reshape(indicator.LevelFlipped, 1, [ ]);
            Xi0 = Xi0 ./ indicator.LevelFlipped(end-numInit+1:end);
        end
        %)
    end%
end%

