function [SS, DD] = wrapper(systemProperty)

TYPE = @int8;

%--------------------------------------------------------------------------

ny = systemProperty.NumObserved;
nxi = systemProperty.NumStates;
nb = systemProperty.NumBackward;
ne = systemProperty.NumShocks;
indexUnitRoots = systemProperty.EigenStability==TYPE(1);
numUnitRoots = systemProperty.NumUnitRoots;
[T, R, ~, Z, H, ~, U] = systemProperty.FirstOrderTriangular{:};
R = R(:, 1:ne);
Omega = systemProperty.CovShocks;

freq = systemProperty.Specifics.Frequencies;
isDensity = systemProperty.Specifics.IsDensity || length(systemProperty.Outputs)>=2;
isFilter = systemProperty.Specifics.IsFilter;
filter = systemProperty.Specifics.Filter;
applyFilterTo = systemProperty.Specifics.ApplyFilterTo;
numFreq = numel(freq);

% Preallocate output arguments
SS = nan(ny+nxi, ny+nxi, numFreq);
DD = double.empty(0);

% Solution not available, return immediately
if any(isnan(T(:)))
    if isDensity
        DD = nan(size(SS));
    end
    if systemProperty.NumOutputs>=1
        systemProperty.Outputs{1} = SS;
        if systemProperty.NumOutputs>=2
            systemProperty.Outputs{2} = DD;
        end
    end
    return
end

SS = freqdom.xsf( ...
    T, R, [ ], Z, H, [ ], U, Omega, numUnitRoots, ...
    freq, filter, applyFilterTo ...
);
SS = SS / (2*pi);

if isDensity
    maxOrder = 1;
    CC = covfun.acovf( ...
        T, R, [ ], Z, H, [ ], U, ...
        Omega, indexUnitRoots(1:nb), maxOrder ...
    );
    DD = freqdom.psf2sdf(SS, CC);
end

if systemProperty.NumOutputs>=1
    systemProperty.Outputs{1} = SS;
    if systemProperty.NumOutputs>=2
        systemProperty.Outputs{2} = DD;
    end
end

end
