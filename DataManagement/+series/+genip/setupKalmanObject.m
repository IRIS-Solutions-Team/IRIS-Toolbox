function [kalmanObj, observed] = setupKalmanObject( ...
    model, lowLevel, aggregation, stdScale ...
    , highLevel, highRate, highDiff, highDiffDiff ... 
    , indicatorTransformed, stdIndicator ...
    , opt ...
)
% setupKalmanObject  Set up time-varying LinearSystem and array of observed data for genip model
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numXi = size(aggregation, 2);
numLowPeriods = size(lowLevel, 1);
numHighPeriods = numXi*numLowPeriods;

% 
% Transition matrix
%
T = hereSetupTransitionMatrix( );

%
% Transition equation innovation multiplier
%
R = zeros(numXi, 1);
R(numXi, 1) = 1;

%
% Transition equation constant
%
k = hereSetupTransitionConstant( );

%
% Innovation covariance matrices
%
OmegaV = ones(1, 1, numHighPeriods);
OmegaV(1, 1, :) = double(stdScale).^2;

%
% Measurement (aggregation) matrix
%
[Z, observed, H, stdW] = hereSetupMeasurement( );
OmegaW = diag(stdW.^2);
numY = size(Z, 1);
numW = size(OmegaW, 1);

%
% Measurement innovation and intercept
%
d = zeros(numY, 1);

kalmanObj = LinearSystem([numXi, numXi, 1, numY, numW], numHighPeriods);
kalmanObj = steadySystem(kalmanObj, 'NotNeeded');
kalmanObj = timeVaryingSystem(kalmanObj, 1:numHighPeriods, {T, R, k, Z, H, d}, {OmegaV, OmegaW});

return

    function T = hereSetupTransitionMatrix( )
        T = diag(ones(1, numXi-1), 1);
        T = repmat(T, 1, 1, numHighPeriods);
        switch string(model)
            case "Rate"
                T(numXi, numXi, :) = hereSetupTransitionRate( );
            case "Level"
                % Level indicator, do nothing
            case "Diff"
                T(numXi, numXi, :) = 1;
            case "DiffDiff"
                T(numXi, numXi, :) = 2;
                T(numXi, numXi-1, :) = -1;
        end
    end%


    function g = hereSetupTransitionRate( )
        if isequal(opt.TransitionRate, @auto)
            g = series.genip.getTransitionRate(model, aggregation, lowLevel);
        else
            g = double(opt.TransitionRate);
        end
        if isscalar(g)
            g = repmat(g, 1, 1, numHighPeriods);
        else
            g = reshape(g, 1, 1, [ ]);
        end
    end%


    function k = hereSetupTransitionConstant( )
        switch string(model)
            case "Rate"
                k = 0;
            otherwise
                if isequal(opt.TransitionConstant, @auto)
                    k = series.genip.getTransitionConstant(model, aggregation, lowLevel);
                else
                    k = double(opt.TransitionConstant);
                end
        end
        if isscalar(k)
            k = repmat(k, 1, 1, numHighPeriods);
        else
            k = reshape(k, 1, 1, [ ]);
        end
        k = [zeros(numXi-1, 1, numHighPeriods); k];
    end%


    function [Z, observed, H, stdW] = hereSetupMeasurement( )
        Z = zeros(0, numXi);
        observed = zeros(0, numHighPeriods);
        H = double.empty(0);
        stdW = double.empty(0);


        %
        % High to low frequency aggregation
        %
        Z__ = aggregation;
        H__ = zeros(1, size(H, 2));
        observed__ = reshape([nan(numXi-1, numLowPeriods); reshape(lowLevel, 1, [ ])], 1, [ ]);

        Z = [Z; repmat(Z__, 1, 1, size(Z, 3))];
        H = [H; H__];
        observed = [observed; observed__];


        %
        % High frequency levels
        %
        if ~isempty(highLevel) && any(isfinite(highLevel))
            Z__ = [zeros(1, numXi-1), 1];
            H__ = zeros(1, size(H, 2));
            observed__ = reshape(highLevel, 1, [ ]);

            Z = [Z; repmat(Z__, 1, 1, size(Z, 3))];
            H = [H; H__];
            observed = [observed; observed__];
        end


        %
        % High frequency rates
        %
        inxFinite = isfinite(highRate);
        if ~isempty(highRate) && any(inxFinite)
            hereExpandZ( );
            [Z__, observed__] = localGetObservedRate(highRate, numXi);
            H__ = zeros(1, size(H, 2));

            Z = [Z; Z__];
            H = [H; H__];
            observed = [observed; observed__];
        end


        %
        % High frequency diff
        %
        if ~isempty(highDiff) && any(isfinite(highDiff))
            Z__ = [zeros(1, numXi-2), -1, 1];
            H__ = zeros(1, size(H, 2));
            observed__ = reshape(highDiff, 1, [ ]);

            Z = [Z; repmat(Z__, 1, 1, size(Z, 3))];
            H = [H; H__];
            observed = [observed; observed__];
        end


        %
        % Indicator
        %
        inxFinite = isfinite(indicatorTransformed);
        if ~isempty(indicatorTransformed) && any(inxFinite)
            switch string(model)
                case "Level"
                    Z__ = [zeros(1, numXi-1), 1];
                    observed__ = reshape(indicatorTransformed, 1, [ ]);
                case "Rate"
                    hereExpandZ( );
                    [Z__, observed__] = localGetObservedRate(indicatorTransformed, numXi);
                case "Diff"
                    Z__ = [zeros(1, numXi-2), -1, 1];
                    observed__ = reshape(indicatorTransformed, 1, [ ]);
                case "DiffDiff"
                    Z__ = [zeros(1, numXi-3), 1, -2, 1];
                    observed__ = reshape(indicatorTransformed, 1, [ ]);
            end
            H__ = 1;
            stdW__ = stdIndicator;

            Z = [Z; Z__];
            observed = [observed; observed__];
            H = blkdiag(H, H__);
            stdW = blkdiag(stdW, stdW__);
        end

        return

            function hereExpandZ( )
                if size(Z, 3)==1
                    Z = repmat(Z, 1, 1, numHighPeriods);
                end
            end%
    end%
end%


%
% Local Functions
%


function [Z, observed] = localGetObservedRate(x, numXi)
    numHighPeriods = numel(x);
    x = reshape(x, 1, [ ]);
    inxFinite = isfinite(x);
    Z = zeros(1, numXi, numHighPeriods);
    Z(1, numXi-1, :) = -1;
    Z(1, numXi-1, inxFinite) = -reshape(x(inxFinite), 1, 1, [ ]);
    Z(1, numXi, :) = 1;
    observed = nan(1, numHighPeriods);
    observed(1, inxFinite) = 0;
end%
