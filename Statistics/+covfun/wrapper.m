function [CC, RR] = wrapper(systemProperty)
% wrapper  Calculate ACF and wrap it in a system property object
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

ny = systemProperty.NumObserved;
nxi = systemProperty.NumStates;
nb = systemProperty.NumBackward;
ne = systemProperty.NumShocks;

[T, R, ~, Z, H, ~, U] = systemProperty.FirstOrderTriangular{:};
R = R(:, 1:ne);
Omega = systemProperty.CovShocks;

maxOrder = systemProperty.Specifics.MaxOrder;
isContributions = systemProperty.Specifics.IsContributions;
isCorrelations = isequal(systemProperty.Specifics.IsCorrelations, true) ...
    || systemProperty.NumOutputs>=2;
isFilter = systemProperty.Specifics.IsFilter;
numContributions = systemProperty.Specifics.NumContributions;
if isFilter
    numUnitRoots = systemProperty.NumUnitRoots;
    filter = systemProperty.Specifics.Filter;
    applyFilterTo = systemProperty.Specifics.ApplyFilterTo;
    freq = systemProperty.Specifics.Frequencies;
end
indexUnitRoots = systemProperty.EigenStability==TYPE(1);

% Preallocate CC, RR
[CC, RR] = preallocate( );

% Solution not available, return immediately
if any(isnan(T(:)))
    if systemProperty.NumOutputs>=1
        systemProperty.Outputs{1} = CC;
        if systemProperty.NumOutputs>=2
            RR = nan(size(CC));
            systemProperty.Outputs{2} = RR;
        end
    end
    return
end

for ithContribution = 1 : numContributions
    if isContributions
        indexShocks = false(1, ne);
        indexShocks(ithContribution) = true;
        ithOmega = Omega(indexShocks, indexShocks);
        if all(ithOmega(:))==0
            CC(:, :, :, ithContribution) = 0;
            continue
        end
        ithR = R(:, indexShocks);
        ithH = H(:, indexShocks);
    else
        ithOmega = Omega;
        ithR = R;
        ithH = H;
    end
    if isFilter
        S = freqdom.xsf( ...
            T, ithR, [ ], Z, ithH, [ ], U, ithOmega, ...
            numUnitRoots, freq, filter, applyFilterTo ...
        );
        ithCC = freqdom.xsf2acf(S, freq, maxOrder);
    else
        ithCC = covfun.acovf( ...
            T, ithR, [ ], Z, ithH, [ ], U, ithOmega, ...
            indexUnitRoots(1:nb), maxOrder ...
        );
    end

    if isContributions
        CC(:, :, :, ithContribution) = ithCC;
    else
        CC = ithCC;
    end
end

% Fix negative variances (in the contemporaneous matrices).
CC(:, :, 1, :, :) = timedom.fixcov(CC(:, :, 1, :, :));

if isCorrelations
    RR = covfun.cov2corr(CC);
end

if systemProperty.NumOutputs>=1
    systemProperty.Outputs{1} = CC;
    if systemProperty.NumOutputs>=2
        systemProperty.Outputs{2} = RR;
    end
end

return


    function [CC, RR] = preallocate( )
        if isContributions
            CC = nan(ny+nxi, ny+nxi, maxOrder+1, numContributions);
        else
            CC = nan(ny+nxi, ny+nxi, maxOrder+1);
        end
        RR = double.empty(0);
    end
end

