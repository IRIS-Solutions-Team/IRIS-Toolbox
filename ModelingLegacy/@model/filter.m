function [this, outp, V, Delta, Pe, SCov] = filter(this, inputDatabank, filterRange, varargin)
% filter  Kalman smoother and estimator of out-of-likelihood parameters
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted
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
% * `Range` [ numeric | char ] - Date filterRange on which the Kalman filter will
% be run.
%
% * `~J=[ ]` [ struct | empty ] - For backward compatibility: Database with
% user-supplied time-varying paths for std deviation, corr coefficients, or
% medians for shocks; `~J` is equivalent to using the option `Override=`,
% and should be omitted.
%
%
% __Output Arguments__
%
% * `M` [ model ] - Model object with updates of std devs (if `Relative=`
% is true) and/or updates of out-of-likelihood parameters (if `OutOfLik=`
% is non-empty).
%
% * `Outp` [ struct | cell ] - Output struct with smoother or prediction
% data.
%
% * `V` [ numeric ] - Estimated variance scale factor if the `Relative=`
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
% are included in the option `ObjRange=` and, at the same time, contain
% at least one observation of measurement variables.
%
%
% __Options__
%
% * `Ahead=1` [ numeric ] - Calculate predictions up to `Ahead` periods
% ahead.
%
% * `ChkFmse=false` [ `true` | `false` ] - Check the condition number of
% the forecast MSE matrix in each step of the Kalman filter, and return
% immediately if the matrix is ill-conditioned; see also the option
% `FmseCondTol=`.
%
% * `Condition={ }` [ char | cellstr | empty ] - List of conditioning
% measurement variables. Condition time t|t-1 prediction errors (that enter
% the likelihood function) on time t observations of these measurement
% variables.
%
% * `Deviation=false` [ `true` | `false` ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `Dtrends=@auto` [ `@auto` | `true` | `false` ] - Measurement data
% contain deterministic trends; `@auto` means `DTrends=` will be set
% consistently with `Deviation=`.
%
% * `Output='Smooth'` [ `'Predict'` | `'Filter'` | `'Smooth'` ] - Return
% smoother data or filtered data or prediction data or any combination of
% them.
%
% * `FmseCondTol=eps( )` [ numeric ] - Tolerance for the FMSE condition
% number test; not used unless `ChkFmse=true`.
%
% * `InitCond='Stochastic'` [ `'fixed'` | `'optimal'` | `'stochastic'` |
% struct ] - Method or data to initialise the Kalman filter; user-supplied
% initial condition must be a mean database or a struct containing `.mean`
% and `.mse` fields.
%
% * `InitUnit='FixedUnknown'` [ `'ApproxDiffuse'` | `'FixedUknown'` ] -
% Method of initializing unit root variables.
%
% * `LastSmooth=Inf` [ numeric ] - Last date up to which to smooth data
% backward from the end of the filterRange; `Inf` means the smoother will run on
% the entire filterRange.
%
% * `MeanOnly=false` [ `true` | `false` ] - Return a plain database with
% mean data only; this option overrides options `ReturnCont=`,
% `ReturnMse=`, `ReturnStd=`.
%
% * `OutOfLik={ }` [ cellstr | empty ] - List of parameters in
% deterministic trends that will be estimated by concentrating them out of
% the likelihood function.
%
% * `ObjFunc='-LogLik'` [ `'-LogLik'` | `'PredErr'` ] - Objective function
% computed; can be either minus the log likelihood function or weighted sum
% of prediction errors.
%
% * `ObjRange=Inf` [ DateWrapper | `Inf` ] - The objective function will be
% computed on the specified filterRange only; `Inf` means the entire filter
% filterRange.
%
% * `Relative=true` [ `true` | `false` ] - Std devs of shocks assigned in
% the model object will be treated as relative std devs, and a common
% variance scale factor will be estimated.
%
% * `ReturnCont=false` [ `true` | `false` ] - Return contributions of
%  prediction errors in measurement variables to the estimates of all
%  variables and shocks.
%
% * `ReturnMse=true` [ `true` | `false` ] - Return MSE matrices for
%  predetermined state variables; these can be used for settin up initial
%  condition in subsequent call to another `filter( )` or `jforecast( )`.
%
% * `ReturnStd=true` [ `true` | `false` ] - Return database with std devs
% of model variables.
%
% * `Weighting=[ ]` [ numeric | empty ] - Weighting vector or matrix for
% prediction errors when `Objective='PredErr'`; empty means prediction
% errors are weighted equally.
%
%
% __Options for Time Variation in Std Deviation, Correlations and Means of Shocks__
%
% * `Multiply=[ ]` [ struct | empty ] - Database with time series of
% possibly time-varying multipliers for std deviations of shocks; the
% numbers supplied will be multiplied by the std deviations assigned in
% the model object to calculate the std deviations used in the filter. See
% Description.
% 
% * `Override=[ ]` [ struct | empty ] - Database with time series for
% possibly time-varying paths for std deviations, correlations
% coefficients, or medians of shocks; these paths will override the values
% assigned in the model object. See Description.
%
%
% __Options for Models with Nonlinear Equations Simulated in Prediction Step__
%
% * `Simulate=false` [ `false` | cell ] - Use the backend algorithms from
% the [`simulate`](model/simulate) function to run nonlinear simulation for
% each prediction step; specify options that will be passed into `simulate`
% when running a prediction step.
%
%
% __Description__
%
% The option `Ahead=` cannot be combined with one another, or with multiple
% data sets, or with multiple parameterisations.
%
%
% _Initial Conditions in Time Domain_
%
% By default (with `InitCond='Stochastic'`), the Kalman filter starts
% from the model-implied asymptotic distribution. You can change this
% behaviour by setting the option `InitCond=` to one of the following
% four different values:
%
% * `'Fixed'` -- the filter starts from the model-implied asymptotic mean
% (steady state) but with no initial uncertainty. The initial condition is
% treated as a vector of fixed, non-stochastic, numbers.
%
% * `'Optimal'` -- the filter starts from a vector of fixed numbers that
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
% Use the option `ReturnCont=true` to request the decomposition of
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
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.filter');
    parser.KeepUnmatched = true;
    parser.addRequired('SolvedModel', @(x) isa(x, 'model') && ~isempty(x) && all(issolved(x)));
    parser.addRequired('InputDatabank', @isstruct);
    parser.addRequired('FilterRange', @DateWrapper.validateProperRangeInput);
    parser.addOptional('TuneDatabank', [ ], @(x) isempty(x) || isstruct(x));
    parser.addParameter('MatrixFormat', 'namedmat', @namedmat.validateMatrixFormat);
    parser.addParameter({'Data', 'Output'}, 'smooth', @ischar);
    parser.addParameter('Rename', cell.empty(1, 0), @(x) iscellstr(x) || ischar(x) || isa(x, 'string'));
end
parser.parse(this, inputDatabank, filterRange, varargin{:});
j = parser.Results.TuneDatabank;
opt = parser.Options;
unmatched = parser.UnmatchedInCell;

likOpt = prepareLoglik(this, filterRange, 't', j, unmatched{:});
isOutputData = nargout>1;

% Temporarily rename quantities.
if ~isempty(opt.Rename)
    if ~iscellstr(opt.Rename)
        opt.Rename = cellstr(opt.Rename);
    end
    this.Quantity = rename(this.Quantity, opt.Rename{:});
end

% Get measurement and exogenous variables.
inputArray = datarequest('yg*', this, inputDatabank, filterRange);
numOfDataSets = size(inputArray, 3);
nv = length(this);

% Check option conflicts.
checkConflicts( );

% Set up data sets for Rolling=.
if ~isequal(likOpt.Rolling, false)
    setupRolling( );
end

%--------------------------------------------------------------------------

[ny, ~, nb] = sizeOfSolution(this.Vector);
nz = nnz(this.Quantity.IxObserved);
extendedRange = filterRange(1)-1 : filterRange(end);
numExtendedPeriods = length(extendedRange);

% Throw a warning if some of the data sets have no observations.
indexOfNaNData = all( all(isnan(inputArray), 1), 2 );
if any(indexOfNaNData)
    throw( exception.Base('Model:NoMeasurementData', 'warning'), ...
           exception.Base.alt2str(indexOfNaNData, 'Data Set(s) ') ); 
end

% Pre-allocated requested hdata output arguments.
hData = struct( );
preallocHData( );

% Run the Kalman filter.
[obj, regOutp, hData] = kalmanFilter(this, inputArray, hData, likOpt); %#ok<ASGLU>

% If needed, expand the number of model parameterizations to include
% estimated variance factors and/or out-of=lik parameters.
if nv<regOutp.NLoop && (likOpt.Relative || ~isempty(regOutp.Delta))
    this = alter(this, regOutp.NLoop);
end

% Postprocess regular (non-hdata) output arguments; update the std
% parameters in the model object if `Relative=' true`.
[~, Pe, V, Delta, ~, SCov, this] = kalmanFilterRegOutp(this, regOutp, extendedRange, likOpt, opt);

% Post-process hdata output arguments.
outp = hdataobj.hdatafinal(hData);

if ~isempty(opt.Rename)
    this.Quantity = resetNames(this.Quantity);
end

return


    function checkConflicts( )
        multiple = numOfDataSets>1 || nv>1;
        if likOpt.Ahead>1 && multiple
            error( ...
                'Model:Filter:IllegalAhead', ...
                'Cannot use option Ahead= with multiple data sets or parameter variants.' ...
            );
        end
        if ~isequal(likOpt.Rolling, false) && multiple
            error( ...
                'Model:Filter:IllegalRolling', ...
                'Cannot use option Rolling= with multiple data sets or parameter variants.' ...
            );
        end
        if likOpt.ReturnCont && any(likOpt.condition)
            error( ...
                'Model:Filter:IllegalCondition', ...
                'Cannot combine options ReturnCont= and Condition=.' ...
            );
        end
    end% 


    function setupRolling( )
        % No multiple data sets or parameter variants guaranteed here.
        numRolling = numel(likOpt.RollingColumns);
        inputArray = repmat(inputArray, 1, 1, numRolling);
        for i = 1 : numRolling
            inputArray(:, likOpt.RollingColumns(i)+1:end, i) = NaN;
        end
        numOfDataSets = size(inputArray, 3);
    end%

    
    function preallocHData( )
        % TODO Make .Output the primary option, allow for cellstr or string
        % inputs
        lowerOutput = lower(opt.Data);
        isPred = ~isempty(strfind(lowerOutput, 'pred'));
        isFilter = ~isempty(strfind(lowerOutput, 'filter'));
        isSmooth = ~isempty(strfind(lowerOutput, 'smooth'));
        numOfRuns = max(numOfDataSets, nv);
        nPred = max(numOfRuns, likOpt.Ahead);
        nCont = max(ny, nz);
        if isOutputData
            
            % __Prediction Step__
            if isPred
                hData.M0 = hdataobj( this, extendedRange, nPred, ...
                                     'IncludeLag=', false );
                if ~likOpt.MeanOnly
                    if likOpt.ReturnStd
                        hData.S0 = hdataobj( this, extendedRange, numOfRuns, ...
                                             'IncludeLag=', false, ...
                                             'IsVar2Std=', true );
                    end
                    if likOpt.ReturnMSE
                        hData.Mse0 = hdataobj( );
                        hData.Mse0.Data = nan(nb, nb, numExtendedPeriods, numOfRuns);
                        hData.Mse0.Range = extendedRange;
                    end
                    if likOpt.ReturnCont
                        hData.predcont = hdataobj( this, extendedRange, nCont, ....
                                                   'IncludeLag=', false, ...
                                                   'Contributions=', @measurement );
                    end
                end
            end
            
            % __Filter Step__
            if isFilter
                hData.M1 = hdataobj( this, extendedRange, numOfRuns, ...
                                     'IncludeLag=', false );
                if ~likOpt.MeanOnly
                    if likOpt.ReturnStd
                        hData.S1 = hdataobj( this, extendedRange, numOfRuns, ...
                                             'IncludeLag=', false, ...
                                             'IsVar2Std=', true);
                    end
                    if likOpt.ReturnMSE
                        hData.Mse1 = hdataobj( );
                        hData.Mse1.Data = nan(nb, nb, numExtendedPeriods, numOfRuns);
                        hData.Mse1.Range = extendedRange;
                    end
                    if likOpt.ReturnCont
                        hData.filtercont = hdataobj( this, extendedRange, nCont, ...
                                                     'IncludeLag=', false, ...
                                                     'Contributions=', @measurement );
                    end
                end
            end
            
            % __Smoother__
            if isSmooth
                hData.M2 = hdataobj(this, extendedRange, numOfRuns);
                if ~likOpt.MeanOnly
                    if likOpt.ReturnStd
                        hData.S2 = hdataobj( this, extendedRange, numOfRuns, ...
                                             'IsVar2Std=', true );
                    end
                    if likOpt.ReturnMSE
                        hData.Mse2 = hdataobj( );
                        hData.Mse2.Data = nan(nb, nb, numExtendedPeriods, numOfRuns);
                        hData.Mse2.Range = extendedRange;
                    end
                    if likOpt.ReturnCont
                        hData.C2 = hdataobj( this, extendedRange, nCont, ...
                                             'Contributions=', @measurement );
                    end
                end
            end
        end
    end%
end%
