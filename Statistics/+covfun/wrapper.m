function wrapper(this, systemProperty, ~)
% wrapper  Calculate ACF and wrap it in a system property object
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

ny = systemProperty.NumObserved;
nxi = systemProperty.NumStates;
nb = systemProperty.NumBackward;
ne = systemProperty.NumShocks;

[T, R, ~, Z, H, ~, U] = systemProperty.FirstOrderTriangular{:};
R = R(:, 1:ne);
Omega = systemProperty.CovShocks;

maxOrder = systemProperty.CallerData.MaxOrder;
isContributions = systemProperty.CallerData.IsContributions;
isCorrelations = isequal(systemProperty.CallerData.IsCorrelations, true) ...
                 || systemProperty.NumOfOutputs>=2;
isFilter = systemProperty.CallerData.IsFilter;
numContributions = systemProperty.CallerData.NumContributions;
if isFilter
    numUnitRoots = systemProperty.NumUnitRoots;
    filter = systemProperty.CallerData.Filter;
    applyFilterTo = systemProperty.CallerData.ApplyFilterTo;
    freq = systemProperty.CallerData.Frequencies;
end
inxOfUnitRoots = systemProperty.EigenStability==1;

% Preallocate CC, RR
[CC, RR] = herePreallocateOutputArrays( );

% Solution not available, return immediately
if any(isnan(T(:)))
    if systemProperty.NumOfOutputs>=1
        systemProperty.Outputs{1} = CC;
        if systemProperty.NumOfOutputs>=2
            RR = nan(size(CC));
            systemProperty.Outputs{2} = RR;
        end
    end
    return
end

for ithContribution = 1 : numContributions
    if isContributions
        inxOfShocks = false(1, ne);
        inxOfShocks(ithContribution) = true;
        ithOmega = Omega(inxOfShocks, inxOfShocks);
        if all(ithOmega(:))==0
            CC(:, :, :, ithContribution) = 0;
            continue
        end
        ithR = R(:, inxOfShocks);
        ithH = H(:, inxOfShocks);
    else
        ithOmega = Omega;
        ithR = R;
        ithH = H;
    end
    if isFilter
        S = freqdom.xsf( T, ithR, [ ], Z, ithH, [ ], U, ithOmega, ...
                         numUnitRoots, freq, filter, applyFilterTo );
        ithCC = freqdom.xsf2acf(S, freq, maxOrder);
    else
        ithCC = covfun.acovf( T, ithR, [ ], Z, ithH, [ ], U, ithOmega, ...
                              inxOfUnitRoots(1:nb), maxOrder );
    end

    if isContributions
        CC(:, :, :, ithContribution) = ithCC;
    else
        CC = ithCC;
    end
end

% Fix negative variances (in the contemporaneous matrices)
CC(:, :, 1, :, :) = timedom.fixcov(CC(:, :, 1, :, :), systemProperty.Tolerance.Mse);

if isCorrelations
    RR = covfun.cov2corr(CC);
end

if systemProperty.NumOfOutputs>=1
    systemProperty.Outputs{1} = CC;
    if  systemProperty.NumOfOutputs>=2
        systemProperty.Outputs{2} = RR;
    end
end

return


    function [CC, RR] = herePreallocateOutputArrays( )
        if isContributions
            CC = nan(ny+nxi, ny+nxi, maxOrder+1, numContributions);
        else
            CC = nan(ny+nxi, ny+nxi, maxOrder+1);
        end
        RR = double.empty(0);
    end%
end%

