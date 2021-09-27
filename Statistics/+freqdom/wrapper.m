function [SS, DD] = wrapper(~, systemProperty, ~)

ny = systemProperty.NumObserved;
nxi = systemProperty.NumStates;
nb = systemProperty.NumBackward;
ne = systemProperty.NumShocks;
inxOfUnitRoots = systemProperty.EigenStability==1;
numOfUnitRoots = systemProperty.NumUnitRoots;
[T, R, ~, Z, H, ~, U] = systemProperty.FirstOrderTriangular{:};
R = R(:, 1:ne);
Omega = systemProperty.CovShocks;

freq = systemProperty.CallerData.Frequencies;
isDensity = systemProperty.CallerData.IsDensity || length(systemProperty.Outputs)>=2;
isFilter = systemProperty.CallerData.IsFilter;
filter = systemProperty.CallerData.Filter;
applyFilterTo = systemProperty.CallerData.ApplyFilterTo;
numFreq = numel(freq);

% Preallocate output arguments
SS = nan(ny+nxi, ny+nxi, numFreq);
DD = double.empty(0);

% Solution not available, return immediately
if any(isnan(T(:)))
    if isDensity
        DD = nan(size(SS));
    end
    if systemProperty.NumOfOutputs>=1
        systemProperty.Outputs{1} = SS;
        if systemProperty.NumOfOutputs>=2
            systemProperty.Outputs{2} = DD;
        end
    end
    return
end

SS = freqdom.xsf( T, R, [ ], Z, H, [ ], U, Omega, numOfUnitRoots, ...
                  freq, filter, applyFilterTo );
SS = SS / (2*pi);

if isDensity
    maxOrder = 1;
    CC = covfun.acovf( T, R, [ ], Z, H, [ ], U, ...
                       Omega, inxOfUnitRoots(1:nb), maxOrder );
    DD = freqdom.psf2sdf(SS, CC);
end

if systemProperty.NumOfOutputs>=1
    systemProperty.Outputs{1} = SS;
    if systemProperty.NumOfOutputs>=2
        systemProperty.Outputs{2} = DD;
    end
end

end%

