function likOpt = prepareLoglik(this, range, domain, tune, varargin)
% prepareLoglik  Prepare likelihood function.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;

if strncmpi(domain, 't', 1)
    % Time domain opt.
    likOpt = passvalopt('model.kalmanFilter', varargin{:});
    likOpt.domain = 't';
    likOpt.minusLogLikFunc = @kalmanFilter;
elseif strncmpi(domain, 'f', 1)
    % Freq domain opt.
    likOpt = passvalopt('model.fdlik', varargin{:});
    likOpt.domain = 'f';
    likOpt.minusLogLikFunc = @myfdlik;
end

%--------------------------------------------------------------------------

[ny, ~, nb] = sizeOfSolution(this.Vector);
nz = nnz(this.Quantity.IxObserved);
numPeriods = length(range);

% Conditioning measurement variables.
if nz>0
    likOpt.condition = false(1, nz);
else
    if likOpt.domain=='t'
        [~, likOpt.condition] = userSelection2Index( ...
            this.Quantity, ...
            likOpt.condition, ...
            TYPE(1) ...
            );
    elseif likOpt.domain=='f'
        [~, likOpt.exclude] = userSelection2Index( ...
            this.Quantity, ...
            likOpt.exclude, ...
            TYPE(1) ...
            );
    end
end

% Out-of-lik parameters.
if isempty(likOpt.outoflik)
    likOpt.outoflik = [ ];
else
    if ischar(likOpt.outoflik)
        likOpt.outoflik = regexp(likOpt.outoflik, '\w+', 'match');
    end
    likOpt.outoflik = likOpt.outoflik(:)';
    ell = lookup(this.Quantity, likOpt.outoflik, TYPE(4));
    pos = ell.PosName;
    ixNan = isnan(pos);
    if any(ixNan)
        throw( exception.Base('Model:INVALID_NAME', 'error'), ...
               'parameter ', likOpt.outoflik{ixNan} ); %#ok<GTARG>
    end
    likOpt.outoflik = pos;
end
likOpt.outoflik = likOpt.outoflik(:).';
npout = length(likOpt.outoflik);
if npout>0 && ~likOpt.DTrends
    utils.error('model:prepareLoglik', ...
        ['Cannot estimate out-of-likelihood parameters ', ...
        'with the option DTrends=false.']);
end

% __Time Domain Options__

if likOpt.domain=='t'
    % Time-varying StdCorr vector 
    % * --clip means trailing NaNs will be removed
    % * --presample means one presample period will be added
    likOpt.StdCorr = varyStdCorr(this, range, tune, likOpt, '--clip', '--presample');
    
    % User-supplied tunes on the mean of shocks.
    if isfield(likOpt, 'vary')
        tune = likOpt.vary;
    end
    if ~isempty(tune) && isstruct(tune)
        % Request shock data.
        tune = datarequest('e', this, tune, range);
        if all(tune(:)==0)
            tune = [ ];
        end
    end
    likOpt.tune = tune;
end

% Objective function.
if likOpt.domain=='t'
    switch lower(likOpt.objfunc)
        case {'prederr'}
            % Weighted prediction errors.
            likOpt.objfunc = 2;
            if isempty(likOpt.weighting)
                likOpt.weighting = sparse(eye(ny));
            elseif numel(likOpt.weighting)==1
                likOpt.weighting = sparse(eye(ny)*likOpt.weighting);
            elseif any( size(likOpt.weighting)==1 )
                likOpt.weighting = sparse(diag(likOpt.weighting(:)));
            end
            if ndims(likOpt.weighting) > 2 ...
                    || any( size(likOpt.weighting)~=ny ) %#ok<ISMAT>
                utils.error('model:prepareLoglik', ...
                    ['Size of prediction error weighting matrix ', ...
                    'must match number of observables.']);
            end
        case {'loglik', 'mloglik', '-loglik'}
            % Minus log likelihood.
            likOpt.objfunc = 1;
        otherwise
            utils.error('model:prepareLoglik', ...
                'Unknown objective function: ''%s''.', ...
                likOpt.objfunc);
    end
end

% Range on which the objective function will be evaluated. The
% `'objrange='` option gives the range from which sample information will
% be used to calculate the objective function and estimate the out-of-lik
% parameters.
if likOpt.domain=='t'
    if isequal(likOpt.objrange, @all)
        likOpt.objrange = true(1, numPeriods);
    else
        start = max(1, round(likOpt.objrange(1) - range(1) + 1));
        End = min(numPeriods, round(likOpt.objrange(end) - range(1) + 1));
        likOpt.objrange = false(1, numPeriods);
        likOpt.objrange(start : End) = true;
    end
end

% Initialize Kalman filter.
if likOpt.domain=='t'
    if isstruct(likOpt.Init)
        [xbInitMean, lsNanInitMean, xbInitMse, lsNanInitMse] = ...
            datarequest('xbInit', this, likOpt.Init, range);
        if isempty(xbInitMse)
            nData = size(xbInitMean, 3);
            xbInitMse = zeros(nb, nb, nData);
        end
        chkNanInit( );
        likOpt.Init = {xbInitMean, xbInitMse};
    end
    % Initial mean for unit root elements of Alpha.
    if isstruct(likOpt.InitUnitRoot)
        [xbInitMean, lsNanInitMean] = ...
            datarequest('xbInit', this, likOpt.InitUnitRoot, range);
        lsNanInitMse = { };
        chkNanInit( );
        likOpt.InitUnitRoot = xbInitMean;
    end
end

% Last backward smoothing period. The option  lastsmooth will not be
% adjusted after we add one pre-sample init condition in `kalman`. This
% way, one extra period before user-requested lastsmooth will smoothed, 
% which can be then used in `simulate` or `jforecast`.
if likOpt.domain=='t'
    if isempty(likOpt.lastsmooth) || isequal(likOpt.lastsmooth, Inf)
        likOpt.lastsmooth = 1;
    else
        likOpt.lastsmooth = round(likOpt.lastsmooth - range(1)) + 1;
        if likOpt.lastsmooth>numPeriods
            likOpt.lastsmooth = numPeriods;
        elseif likOpt.lastsmooth<1
            likOpt.lastsmooth = 1;
        end
    end
end

likOpt.RollingColumns = [ ];
if ~isequal(likOpt.Rolling, false)
    likOpt.RollingColumns = rnglen(range(1), likOpt.Rolling);
    chkRollingColumns( );
end

return


    function chkNanInit( )
        if ~isempty(lsNanInitMean)
            utils.error('model:prepareLoglik', ...
                'This mean initial condition is not available: %s ', ...
                lsNanInitMean{:});
        end
        if ~isempty(lsNanInitMse)
            utils.error('model:prepareLoglik', ...
                'This MSE initial condition is not available: %s ', ...
                lsNanInitMse{:});
        end        
    end


    function chkRollingColumns( )
        x = likOpt.RollingColumns;
        assert( ...
            all(round(x)==x) && all(x>=1) && all(x<=numPeriods), ...
            'Model:Filter:IllegalRolling', ...
            'Illegal dates specified in option Rolling=.' ...
        );
    end
end
