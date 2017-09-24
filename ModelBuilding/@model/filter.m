function [this, outp, V, Delta, Pe, SCov] = filter(varargin)
% filter  Kalman smoother and estimator of out-of-likelihood parameters.
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [M, Outp, V, Delta, PE, SCov] = filter(M, Inp, Range, ~J, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Solved model object.
%
% * `Inp` [ struct | cell ] - Input database from which observations for
% measurement variables will be taken.
%
% * `Range` [ numeric | char ] - Date range on which the Kalman filter will
% be run.
%
% * `~J` [ struct | *empty* ] - Database with user-supplied time-varying
% paths for std deviation, corr coefficients, or medians for shocks; `~J`
% is equivalent to using the option `'vary='`, and may be omitted.
%
%
% __Output Arguments__
%
% * `M` [ model ] - Model object with updates of std devs (if `'relative='`
% is true) and/or updates of out-of-likelihood parameters (if `'outoflik='`
% is non-empty).
%
% * `Outp` [ struct | cell ] - Output struct with smoother or prediction
% data.
%
% * `V` [ numeric ] - Estimated variance scale factor if the `'relative='`
% options is true; otherwise `V` is 1.
%
% * `Delta` [ struct ] - Database with estimates of out-of-likelihood
% parameters.
%
% * `PE` [ struct ] - Database with prediction errors for measurement
% variables.
%
% * `SCov` [ numeric ] - Sample covariance matrix of smoothed shocks;
% the covariance matrix is computed using shock estimates in periods that
% are included in the option `'objrange='` and, at the same time, contain
% at least one observation of measurement variables.
%
%
% __Options__
%
% * `'Ahead='` [ numeric | *`1`* ] - Predictions will be computed this number
% of period ahead.
%
% * `'ChkFmse='` [ `true` | *`false`* ] - Check the condition number of the
% forecast MSE matrix in each step of the Kalman filter, and return
% immediately if the matrix is ill-conditioned; see also the option
% `'FmseCondTol='`.
%
% * `'Condition='` [ char | cellstr | *empty* ] - List of conditioning
% measurement variables. Condition time t|t-1 prediction errors (that enter
% the likelihood function) on time t observations of these measurement
% variables.
%
% * `'Deviation='` [ `true` | *`false`* ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `'Dtrends='` [ *`@auto`* | `true` | `false` ] - Measurement data
% contain deterministic trends.
%
% * `'Output='` [ `'predict'` | `'filter'` | *`'smooth'`* ] - Return
% smoother data or filtered data or prediction data or any combination of
% them.
%
% * `'FmseCondTol='` [ *`eps( )`* | numeric ] - Tolerance for the FMSE
% condition number test; not used unless `'ChkFmse=' true`.
%
% * `'InitCond='` [ `'fixed'` | `'optimal'` | *`'stochastic'`* | struct ] -
% Method or data to initialise the Kalman filter; user-supplied initial
% condition must be a mean database or a struct containing `.mean` and
% `.mse` fields.
%
% * `'InitUnit='` [ `'ApproxDiffuse'` | *`'FixedUknown'`* ] - Method of
% initializing unit root variables.
%
% * `'LastSmooth='` [ numeric | *`Inf`* ] - Last date up to which to smooth
% data backward from the end of the range; if `Inf` smoother will run on the
% entire range.
%
% * `'MeanOnly='` [ `true` | *`false`* ] - Return a plain database with
% mean data only; this option overrides the `'return*='` options, i.e.
% `'returnCont='`, `'returnMse='`, `'returnStd='`.
%
% * `'OutOfLik='` [ cellstr | empty ] - List of parameters in deterministic
% trends that will be estimated by concentrating them out of the likelihood
% function.
%
% * `'ObjFunc='` [ *`'-loglik'`* | `'prederr'` ] - Objective function
% computed; can be either minus the log likelihood function or weighted sum
% of prediction errors.
%
% * `'ObjRange='` [ numeric | *`Inf`* ] - The objective function will be
% computed on the specified range only; `Inf` means the entire filter
% range.
%
% * `'Precision='` [ *`'double'`* | `'single'` ] - Numeric precision to which
% output data will be stored; all calculations themselves always run to
% double precision.
%
% * `'Relative='` [ *`true`* | `false` ] - Std devs of shocks assigned in the
% model object will be treated as relative std devs, and a common variance
% scale factor will be estimated.
%
% * `'ReturnCont='` [ `true` | *`false`* ] - Return contributions of
% prediction errors in measurement variables to the estimates of all
% variables and shocks.
%
% * `'ReturnMse='` [ *`true`* | `false` ] - Return MSE matrices for
% predetermined state variables; these can be used for settin up initial
% condition in subsequent call to another `filter` or `jforecast`.
%
% * `'ReturnStd='` [ *`true`* | `false` ] - Return database with std devs
% of model variables.
%
% * `'Weighting='` [ numeric | *empty* ] - Weighting vector or matrix for
% prediction errors when `'objective=' 'prederr'`; empty means prediction
% errors are weighted equally.
%
%
% __Options for Models with Nonlinear Equations Simulated in Prediction Step__
%
% * `'Simulate='` [ *`false`* | cell ] - Use the backend algorithms from
% the [`simulate`](model/simulate) function to run nonlinear simulation for
% each prediction step; specify options that will be passed into `simulate`
% when running a prediction step.
%
%
% __Description__
%
% The option `'Ahead='` cannot be combined with one another, or with
% multiple data sets, or with multiple parameterisations.
%
%
% _Initial Conditions in Time Domain_
%
% By default (with `'InitCond=' 'stochastic'`), the Kalman filter starts
% from the model-implied asymptotic distribution. You can change this
% behaviour by setting the option `'InitCond='` to one of the following
% four different values:
%
% * `'fixed'` -- the filter starts from the model-implied asymptotic mean
% (steady state) but with no initial uncertainty. The initial condition is
% treated as a vector of fixed, non-stochastic, numbers.
%
% * `'optimal'` -- the filter starts from a vector of fixed numbers that
% is estimated optimally (likelihood maximising).
%
% * database (i.e. struct with fields for individual model variables) -- a
% database through which you supply the mean for all the required initial
% conditions, see help on [`model/get`](model/get) for how to view the list
% of required initial conditions.
%
% * mean-mse struct (i.e. struct with fields `.mean` and `.mse`) -- a struct
% through which you supply the mean and MSE for all the required initial
% conditions.
%
%
% _Contributions of Measurement Variables to Estimates of All Variables_
%
% Use the option `'ReturnCont=' true` to request the decomposition of
% measurement variables, transition variables, and shocks into the
% contributions of each individual measurement variable. The resulting
% output database will include one extra subdatabase called `.cont`. In
% the `.cont` subdatabase, each time series will have Ny columns where Ny
% is the number of measurement variables in the model. The k-th column will
% be the contribution of the observations on the k-th measurement variable.
%
% The contributions are additive for linearised variables, and
% multiplicative for log-linearised variables (log variables). The
% difference between the actual path for a particular variable and the sum
% of the contributions (or their product in the case of log varibles) is
% due to the effect of constant terms and deterministic trends.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

[this, inp, range, j, varargin] = irisinp.parser.parse('model.filter', varargin{:});
[opt, varargin] = passvalopt('model.filter', varargin{:});
likOpt = prepareLoglik(this, range, 't', j, varargin{:});
isOutpData = nargout>1;

% Get measurement and exogenous variables.
inp = datarequest('yg*', this, inp, range);
nData = size(inp, 3);
nAlt = length(this);

% Check option conflicts.
chkConflicts( );

%--------------------------------------------------------------------------

[ny, ~, nb] = sizeOfSolution(this.Vector);
nz = nnz(this.Quantity.IxObserved);
xRange = range(1)-1 : range(end);
nXPer = length(xRange);

% Throw a warning if some of the data sets have no observations.
ixNanData = all( all(isnan(inp), 1), 2 );
assert( ...
    ~any(ixNanData), ...
    exception.Base('Model:NoMeasurementData', 'warning'), ...
    exception.Base.alt2str(ixNanData, 'Data Variant(s) ') ...
); %#ok<GTARG>

% Pre-allocated requested hdata output arguments.
hData = struct( );
preallocHData( );

% Run the Kalman filter.
[obj, regOutp, hData] = kalmanFilter(this, inp, hData, likOpt); %#ok<ASGLU>

% If needed, expand the number of model parameterizations to include
% estimated variance factors and/or out-of=lik parameters.
if nAlt<regOutp.NLoop && (likOpt.relative || ~isempty(regOutp.Delta))
    this = alter(this, regOutp.NLoop);
end

% Postprocess regular (non-hdata) output arguments; update the std
% parameters in the model object if `'relative=' true`.
[~, Pe, V, Delta, ~, SCov, this] = kalmanFilterRegOutp(this, regOutp, xRange, likOpt, opt);

% Post-process hdata output arguments.
outp = hdataobj.hdatafinal(hData);

return




    function chkConflicts( )
        if likOpt.ahead>1 && (nData>1 || nAlt>1)
            utils.error('model:filter', ...
                ['Cannot combine the option ''ahead='' greater than 1 ', ...
                'with multiple data sets or parameterisations.']);
        end
        if likOpt.returncont && any(likOpt.condition)
            utils.error('model:filter', ...
                ['Cannot combine the option ''returnCont=true'' with ', ...
                'a non-empty option ''condition=''.']);
        end
    end 



    
    function preallocHData( )
        lowerOutput = lower(opt.data);
        isPred = ~isempty(strfind(lowerOutput, 'pred'));
        isFilter = ~isempty(strfind(lowerOutput, 'filter'));
        isSmooth = ~isempty(strfind(lowerOutput, 'smooth'));
        nLoop = max(nData, nAlt);
        nPred = max(nLoop, likOpt.ahead);
        nCont = max(ny, nz);
        if isOutpData
            
            % Prediction step
            %-----------------
            if isPred
                hData.M0 = hdataobj(this, xRange, nPred, ...
                    'IncludeLag=', false, ...
                    'Precision=', likOpt.precision);
                if ~likOpt.meanonly
                    if likOpt.returnstd
                        hData.S0 = hdataobj(this, xRange, nLoop, ...
                            'IncludeLag=', false, ...
                            'IsVar2Std=', true, ...
                            'Precision=', likOpt.precision);
                    end
                    if likOpt.returnmse
                        hData.Mse0 = hdataobj( );
                        hData.Mse0.Data = nan(nb, nb, nXPer, nLoop, ...
                            likOpt.precision);
                        hData.Mse0.Range = xRange;
                    end
                    if likOpt.returncont
                        hData.predcont = hdataobj(this, xRange, nCont, ....
                            'IncludeLag=', false, ...
                            'Contributions=', @measurement, ...
                            'Precision', likOpt.precision);
                    end
                end
            end
            
            % Filter step
            %-------------
            if isFilter
                hData.M1 = hdataobj(this, xRange, nLoop, ...
                    'IncludeLag=', false, ...
                    'Precision=', likOpt.precision);
                if ~likOpt.meanonly
                    if likOpt.returnstd
                        hData.S1 = hdataobj(this, xRange, nLoop, ...
                            'IncludeLag=', false, ...
                            'IsVar2Std=', true, ...
                            'Precision', likOpt.precision);
                    end
                    if likOpt.returnmse
                        hData.Mse1 = hdataobj( );
                        hData.Mse1.Data = nan(nb, nb, nXPer, nLoop, ...
                            likOpt.precision);
                        hData.Mse1.Range = xRange;
                    end
                    if likOpt.returncont
                        hData.filtercont = hdataobj(this, xRange, nCont, ...
                            'IncludeLag=', false, ...
                            'Contributions=', @measurement, ...
                            'Precision=', likOpt.precision);
                    end
                end
            end
            
            % Smoother
            %----------
            if isSmooth
                hData.M2 = hdataobj(this, xRange, nLoop, ...
                    'Precision=', likOpt.precision);
                if ~likOpt.meanonly
                    if likOpt.returnstd
                        hData.S2 = hdataobj(this, xRange, nLoop, ...
                            'IsVar2Std=', true, ...
                            'Precision=', likOpt.precision);
                    end
                    if likOpt.returnmse
                        hData.Mse2 = hdataobj( );
                        hData.Mse2.Data = nan(nb, nb, nXPer, nLoop, ...
                            likOpt.precision);
                        hData.Mse2.Range = xRange;
                    end
                    if likOpt.returncont
                        hData.C2 = hdataobj(this, xRange, nCont, ...
                            'Contributions=', @measurement, ...
                            'Precision=', likOpt.precision);
                    end
                end
            end
        end
    end
end
