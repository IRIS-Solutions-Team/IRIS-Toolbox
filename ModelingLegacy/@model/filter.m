function [this, outp, V, Delta, Pe, SCov, init, F] = filter(this, inputDb, filterRange, varargin)
% filter  Kalman smoother and estimator of out-of-likelihood parameters
%{
%
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%
%     [outputModel, outputData, V, Delta, PE, SCov, init] = filter(inputModel, inputData, filterRange, ...)
%
%
% ## Input Arguments ##
%
%
% __`inputModel`__ [ Model ]
% >
% A solved Model object whose state-space representation will be used to
% run a linear Kalman filter on the `inputData` observations.
%
%
% __`inputData`__ [ struct | Dictionary ] 
% >
% Input databank from which the observations for measurement variables on
% the `filterRange` will be taken.
%
%
% __`filterRange`__ [ numeric | char ]
% >
% The range on which the Kalman filter will be run.
%
%
% ## Output Arguments ##
%
%
% __`outputModel`__ [ Model ]
% >
% Model object with the std deviation of shocks updated (if
% `Relative=true`) and/or the out-of-likelihood parameters updated (if
% `OutOfLik=` is non-empty).
%
%
% __`outputData`__ [ struct | Dictionary ]
% >
% Output databank (possibly a nested databank) with the requested data; the
% type of output data are requested through the option `Output=`.
%
%
% __`V`__ [ numeric ] 
% >
% Estimated variance scale factor if the `Relative=`
% options is true; otherwise `V` is 1.
%
%
% __`Delta`__ [ struct ]
% >
% Databank with estimates of out-of-likelihood
% parameters.
%
%
% __`PE`__ [ struct ]
% >
% Databank with prediction errors for measurement
% variables.
%
%
% __`SCov`__ [ numeric ]
% >
% Sample covariance matrix of smoothed shocks;
% the covariance matrix is computed using shock estimates in periods that
% are included in the option `ObjRange=` and, at the same time, contain
% at least one observation of measurement variables.
%
%
% __`init`__ [ cell ]
% >
% Initial conditions used in the Kalman filter; `init{1}` is the initial
% mean of the vector of transformed state variables, `init{2}` is the MSE
% matrix.
%
%
% ## Options ##
%
%
% __`Ahead=1`__ [ numeric ]
% >
% Calculate predictions up to `Ahead` periods
% ahead.
%
%
% __`ChkFmse=false`__ [ `true` | `false` ]
% >
% Check the condition number of
% the forecast MSE matrix in each step of the Kalman filter, and return
% immediately if the matrix is ill-conditioned; see also the option
% `FmseCondTol=`.
%
%
% __`Condition={ }`__ [ char | cellstr | empty ]
% >
% List of conditioning measurement variables. Condition time t|t-1
% prediction errors (that enter the likelihood function) on time t
% observations of these measurement variables.
%
%
% __`Deviation=false`__ [ `true` | `false` ]
% >
% Treat input and output data as
% deviations from balanced-growth path.
%
%
% __`Dtrends=@auto`__ [ `@auto` | `true` | `false` ]
% >
% Measurement data contain deterministic trends; `@auto` means `DTrends=`
% will be set consistently with `Deviation=`.
%
%
% __`Output='Smooth'`__ [ `'Predict'` | `'Filter'` | `'Smooth'` ]
% >
% Return smoother data or filtered data or prediction data or any
% combination of them.
%
%
% __`FmseCondTol=eps( )`__ [ numeric ]
% Tolerance for the FMSE condition number test; not used unless
% `ChkFmse=true`.
%
%
% __`InitCond='Stochastic'`__ [ `'fixed'` | `'optimal'` | `'stochastic'` | struct ]
% >
% The method or data that will be used initialise the Kalman filter;
% user-supplied initial condition must be a databank with the mean values
% (in which case the MSE of the initial condition will be set to zero) or a
% nested databank containing sub-databanks named `.mean` and `.mse`.
%
%
% __`InitUnit='FixedUnknown'`__ [ `'ApproxDiffuse'` | `'FixedUknown'` ]
% >
% Method of initializing unit root variables; see Description.
%
%
% __`LastSmooth=Inf`__ [ numeric ]
% >
% Last date up to which to smooth data backward from the end of the
% filterRange; `Inf` means the smoother will run on the entire filterRange.
%
%
% __`MeanOnly=false`__ [ `true` | `false` ]
% > 
% Return a plain databank with mean data only; this option overrides
% options `ReturnCont=`, `ReturnMse=`, `ReturnStd=`.
%
%
% __`OutOfLik={ }`__ [ cellstr | empty ]
% >
% List of parameters in deterministic trends that will be estimated by
% concentrating them out of the likelihood function.
%
%
% __`ObjFunc='-LogLik'`__ [ `'-LogLik'` | `'PredErr'` ]
% >
% Objective function computed; can be either minus the log likelihood
% function or weighted sum of prediction errors.
%
%
% __`ObjRange=Inf`__ [ DateWrapper | `Inf` ]
% >
% The objective function will be
% computed on the specified filterRange only; `Inf` means the entire filter
% filterRange.
%
%
% __`Relative=true`__ [ `true` | `false` ]
% >
% Std devs of shocks assigned in the model object will be treated as
% relative std devs, and a common variance scale factor will be estimated.
%
%
% __`ReturnCont=false`__ [ `true` | `false` ]
% >
% Return contributions of prediction errors in measurement variables to the
% estimates of all variables and shocks.
%
%
% __`ReturnMse=true`__ [ `true` | `false` ]
% >
% Return MSE matrices for predetermined state variables; these can be used
% for settin up initial condition in subsequent call to another `filter( )`
% or `jforecast( )`.
%
%
% __`ReturnStd=true`__ [ `true` | `false` ]
% >
% Return databank with std devs of model variables.
%
%
% __`Weighting=[ ]`__ [ numeric | empty ]
% >
% Weighting vector or matrix for prediction errors when
% `ObjFunc='PredErr'`; empty means prediction errors are weighted equally.
%
%
% ## Options for Time-Varying Std Deviations, Correlations and Means of Shocks ##
%
%
% __`Multiply=[ ]`__ [ struct | empty ]
% >
% Databank with time series of
% possibly time-varying multipliers for std deviations of shocks; the
% numbers supplied will be multiplied by the std deviations assigned in
% the model object to calculate the std deviations used in the filter. See
% Description.
% 
%
% __`Override=[ ]`__ [ struct | empty ]
% >
% Databank with time series for
% possibly time-varying paths for std deviations, correlations
% coefficients, or medians of shocks; these paths will override the values
% assigned in the model object. See Description.
%
%
% ## Options for Models with Nonlinear Equations Simulated in Prediction Step ##
%
%
% __`Simulate=false`__ [ `false` | cell ]
% >
% Use the backend algorithms from the [`simulate`](model/simulate) function
% to run nonlinear simulation for each prediction step; specify options
% that will be passed into `simulate` when running a prediction step.
%
%
% ## Description ##
%
% Run a Kalman filter based on the `inputModel`
% The option `Ahead=` cannot be combined with one another, or with multiple
% data sets, or with multiple parameterisations.
%
%
% ### Initial Conditions in Time Domain ###
%
% By default (with `InitCond='Stochastic'`), the Kalman filter starts
% from the model-implied asymptotic distribution. You can change this
% behaviour by setting the option `InitCond=` to one of the following
% four different values:
%
% __`'Fixed'`__ -- the filter starts from the model-implied asymptotic mean
% (steady state) but with no initial uncertainty. The initial condition is
% treated as a vector of fixed, non-stochastic, numbers.
%
% __`'Optimal'`__ -- the filter starts from a vector of fixed numbers that
% is estimated optimally (likelihood maximising).
%
% * databank (i.e. struct with fields for individual model variables) -- a
% databank through which you supply the mean for all the required initial
% conditions, see help on [`model/get`](model/get) for how to view the list
% of required initial conditions.
%
% * mean-mse struct (i.e. struct with fields `.mean` and `.mse`) -- a struct
% through which you supply the mean and MSE for all the required initial
% conditions.
%
%
% ### Initialization of Unit Root (Nonstationary, Diffuse) Processes ###
%
% Two methods are available to initialize unit-root (nonstationary,
% diffuse) elements in the state vector. In either case, the Kalman filter
% works with a system where the state vector is transformed so that its
% transition matrix is upper diagonal, with unit roots concentrated in the
% top left corner.
%
% * Fixed unknown quantities. This is the default method (for backward
% compatibility reasons), and corresponds to setting
% `InitUnit='FixedUnknown'`.  The initial conditions for unit-root
% processes are treated as fixed unknown elements, and uses a Rosenberg
% (1973) algorithm to compute the optimal estimates of these. The algorithm
% is completely described in section 3.4.4. of Harvey (1990) "Forecasting,
% Structural Time Series Models and the Kalman Filter", Cambridge
% University Press.
%
% * Approximate diffuse. The other method is used when
% `InitUnit='ApproxDiffuse'`.  This alternative method treats the initial
% conditions for unit-root processes as a diffuse distribution (with
% infinitely large variances) approximating the true diffuse distribution
% by scaling up the appropriate elements of the initial covariance matrix
% (by a sufficiently large factor in proportion to the remaining parts of
% the matrix). This method is described e.g. in Harvey & Phillips (1979)
% "Maximum Likelihood Estimation of Regression Models with Autoregressive-
% Moving Average Disturbances" Biometrika 66(1).
%
%
% ### Contributions of Measurement Variables to Estimates of All Variables ###
%
% Use the option `ReturnCont=true` to request the decomposition of
% measurement variables, transition variables, and shocks into the
% contributions of each individual measurement variable. The resulting
% output databank will include one extra subdatabank called `.cont`. In
% the `.cont` subdatabank, each time series will have Ny columns where Ny
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
% _Time Variation in Std Deviations, Correlations and Means of Shocks_
%
% The options `Multiply=` and `Override=` modify the std deviations,
% correlation coefficients or medians of shocks within the filter range,
% allowing them also to vary over time. Create a time series and specify
% observations for each std deviation, correlation coefficient, or median
% (mean) that you want to deviate from the values currently assigned in the
% model object. The time series supplied do not need to stretch over the
% entire filter range: in the periods not specified, the values currently
% assigned in the model object will be assumed. 
%
% The option `Override=` simply overrides the std deviations, correlations
% or medians (means) of the shocks whenever specified. 
% 
% The option `Mutliply=` can be used to supply multipliers for std
% deviations. The numbers entered will be multiplied by the std deviations
% to obtain the final std deviations used in the filter.
% 
% To alter the median (mean) of a shock, supply a time series named after
% the shock itself. To alter the std deviation of a shock, use the name of
% that std deviation, i.e. `std_xxx` where `xxx` is the name of the shock.
% To alter the correlation coefficient between two shocks, use the name of
% that correlation coefficient, i.e. `corr_xxx__yyy` where `xxx` and `yyy`
% are the names of the shocks (mind the double underscore between `xxx` and
% `yyy`).
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('model.filter');
    pp.KeepUnmatched = true;

    addRequired(pp, 'solvedModel', @(x) isa(x, 'model') && ~isempty(x) && all(beenSolved(x)));
    addRequired(pp, 'inputDb', @(x) isempty(x) || validate.databank(x));
    addRequired(pp, 'filterRange', @DateWrapper.validateProperRangeInput);

    addParameter(pp, 'MatrixFormat', 'namedmat', @namedmat.validateMatrixFormat);
    addParameter(pp, {'Data', 'Output'}, 'smooth', @ischar);
    addParameter(pp, 'Rename', cell.empty(1, 0), @(x) iscellstr(x) || ischar(x) || isa(x, 'string'));
end
parse(pp, this, inputDb, filterRange, varargin{:});
opt = pp.Options;

filterRange = double(filterRange);
numBasePeriods = round(filterRange(end) - filterRange(1) + 1);
needsOutputData = nargout>1;
nv = countVariants(this);
[ny, ~, nb, ~, ~, ng] = sizeOfSolution(this.Vector);

%--------------------------------------------------------------------------

%
% Resolve Kalman filter options and create a time-varying LinearSystem if
% necessary
%
[kalmanOpt, timeVarying] = prepareKalmanOptions(this, filterRange, pp.UnmatchedInCell{:});


%
% Temporarily rename quantities
%
if ~isempty(opt.Rename)
    if ~iscellstr(opt.Rename)
        opt.Rename = cellstr(opt.Rename);
    end
    this.Quantity = rename(this.Quantity, opt.Rename{:});
end

%
% Get measurement and exogenous variables
%
if ~isempty(inputDb)
    inputArray = datarequest('yg*', this, inputDb, filterRange);
else
    inputArray = nan(ny+ng, numBasePeriods);
end
numPages = size(inputArray, 3);

% Check option conflicts
hereCheckConflicts( );

% Set up data sets for Rolling=
if ~isequal(kalmanOpt.Rolling, false)
    hereSetupRolling( );
end

nz = nnz(this.Quantity.IxObserved);
extendedStart = dater.plus(filterRange(1), -1);
extendedEnd = filterRange(end);
extRange = dater.colon(extendedStart, extendedEnd);
numExtPeriods = numel(extRange);

% Throw a warning if some of the data sets have no observations.
inxNaNData = all( all(isnan(inputArray), 1), 2 );
if any(inxNaNData)
    throw( exception.Base('Model:NoMeasurementData', 'warning'), ...
           exception.Base.alt2str(inxNaNData, 'Data Set(s) ') ); 
end

%
% Pre-allocate requested output data
%
outputData = struct( );
herePreallocOutputData( );


% /////////////////////////////////////////////////////////////////////////
%
% Call the Kalman filter
%
argin = struct( ...
    'InputData', inputArray, ...
    'OutputData', outputData, ...
    'OutputDataAssignFunc', @hdataassign, ...
    'Options', kalmanOpt ...
);
if isempty(timeVarying)
    [obj, regOutp, outputData] = kalmanFilter(this, argin); %#ok<ASGLU>
else
    [obj, regOutp, outputData] = kalmanFilter(timeVarying, argin); %#ok<ASGLU>
end
% /////////////////////////////////////////////////////////////////////////


% If needed, expand the number of model parameterizations to include
% estimated variance factors and/or out-of=lik parameters.
if nv<regOutp.NLoop && (kalmanOpt.Relative || ~isempty(regOutp.Delta))
    this = alter(this, regOutp.NLoop);
end

%
% Postprocess regular (non-hdata) output arguments; update the std
% parameters in the model object if `Relative=' true`
%
[F, Pe, V, Delta, ~, SCov, this] = kalmanFilterRegOutp(this, regOutp, extRange, kalmanOpt, opt);
init = regOutp.Init;

%
% Post-process hdata output arguments
%
outp = hdataobj.hdatafinal(outputData);

if ~isempty(opt.Rename)
    this.Quantity = resetNames(this.Quantity);
end

return


    function [kalmanOpt, timeVarying] = hereResolveOverride( )
    end%




    function hereCheckConflicts( )
        multiple = numPages>1 || nv>1;
        if kalmanOpt.Ahead>1 && multiple
            error( ...
                'Model:Filter:IllegalAhead', ...
                'Cannot use option Ahead= with multiple data sets or parameter variants.' ...
            );
        end
        if ~isequal(kalmanOpt.Rolling, false) && multiple
            error( ...
                'Model:Filter:IllegalRolling', ...
                'Cannot use option Rolling= with multiple data sets or parameter variants.' ...
            );
        end
        if kalmanOpt.ReturnCont && any(kalmanOpt.Condition)
            error( ...
                'Model:Filter:IllegalCondition', ...
                'Cannot combine options ReturnCont= and Condition=.' ...
            );
        end
    end% 




    function hereSetupRolling( )
        % No multiple data sets or parameter variants guaranteed here.
        numRolling = numel(kalmanOpt.RollingColumns);
        inputArray = repmat(inputArray, 1, 1, numRolling);
        for i = 1 : numRolling
            inputArray(:, kalmanOpt.RollingColumns(i)+1:end, i) = NaN;
        end
        numPages = size(inputArray, 3);
    end%



    
    function herePreallocOutputData( )
        % TODO Make .Output the primary option, allow for cellstr or string
        % inputs
        isPred = contains(opt.Data, 'Pred', 'IgnoreCase', true);
        isFilter = contains(opt.Data, 'Filter', 'IgnoreCase', true);
        isSmooth = contains(opt.Data, 'Smooth', 'IgnoreCase', true);
        numRuns = max(numPages, nv);
        numPredictions = max(numRuns, kalmanOpt.Ahead);
        numContributions = max(ny, nz);
        if needsOutputData
            
            % 
            % Prediction
            %
            if isPred
                outputData.M0 = hdataobj( this, extRange, numPredictions, ...
                                     'IncludeLag=', false );
                if ~kalmanOpt.MeanOnly
                    if kalmanOpt.ReturnStd
                        outputData.S0 = hdataobj( this, extRange, numRuns, ...
                                             'IncludeLag=', false, ...
                                             'IsVar2Std=', true );
                    end
                    if kalmanOpt.ReturnMSE
                        outputData.Mse0 = hdataobj( );
                        outputData.Mse0.Data = nan(nb, nb, numExtPeriods, numRuns);
                        outputData.Mse0.Range = extRange;
                    end
                    if kalmanOpt.ReturnCont
                        outputData.predcont = hdataobj( this, extRange, numContributions, ....
                                                   'IncludeLag=', false, ...
                                                   'Contributions=', @measurement );
                    end
                end
            end
            
            % 
            % Filter
            %
            if isFilter
                outputData.M1 = hdataobj( this, extRange, numRuns, ...
                                     'IncludeLag=', false );
                if ~kalmanOpt.MeanOnly
                    if kalmanOpt.ReturnStd
                        outputData.S1 = hdataobj( this, extRange, numRuns, ...
                                             'IncludeLag=', false, ...
                                             'IsVar2Std=', true);
                    end
                    if kalmanOpt.ReturnMSE
                        outputData.Mse1 = hdataobj( );
                        outputData.Mse1.Data = nan(nb, nb, numExtPeriods, numRuns);
                        outputData.Mse1.Range = extRange;
                    end
                    if kalmanOpt.ReturnCont
                        outputData.filtercont = hdataobj( this, extRange, numContributions, ...
                                                     'IncludeLag=', false, ...
                                                     'Contributions=', @measurement );
                    end
                end
            end
            
            %
            % Smoother
            %
            if isSmooth
                outputData.M2 = hdataobj(this, extRange, numRuns);
                if ~kalmanOpt.MeanOnly
                    if kalmanOpt.ReturnStd
                        outputData.S2 = hdataobj( ...
                            this, extRange, numRuns ...
                            , 'IsVar2Std=', true ...
                        );
                    end
                    if kalmanOpt.ReturnMSE
                        outputData.Mse2 = hdataobj( );
                        outputData.Mse2.Data = nan(nb, nb, numExtPeriods, numRuns);
                        outputData.Mse2.Range = extRange;
                    end
                    if kalmanOpt.ReturnCont
                        outputData.C2 = hdataobj( ...
                            this, extRange, numContributions ...
                            , 'Contributions=', @measurement ...
                        );
                    end
                end
            end
        end
    end%
end%
