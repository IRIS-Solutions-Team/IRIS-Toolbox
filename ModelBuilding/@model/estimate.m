function [summary, p, proposalCov, hessian, this, V, delta, PDelta, varargout] = estimate(this, inputDatabank, range, varargin)
% estimate  Estimate model parameters by optimizing selected objective function.
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [Summary, Poster, Table, Hess, MEst, V, Delta, PDelta] = ...
%               estimate(M, D, Range, EstimSpec, ~SystemPriors, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object with single parameterization.
%
% * `D` [ struct | cell ] - Input database or datapack from which the
% measurement variables will be taken.
%
% * `Range` [ struct | char ] - Date range on which the data likelihood
% will be evaluated.
%
% * `EstimSpec` [ struct ] - Struct with the list of paremeters that will be
% estimated, and the parameter prior specifications (see below).
%
% * `~SystemPriors` [ systempriors | *empty* ] - System priors object,
% [`systempriors`](systempriors/Contents); may be omitted.
%
%
% __Output Arguments__
%
% * `Summary` [ table ] - Table with summary information.
%
% * `Poster` [ poster ] - Posterior, [`poster`](poster/Contents), object;
% this object also gives you access to the value of the objective function
% at optimum or at any point in the parameter space, see the
% [`poster/eval`](poster/eval) function.
%
% * `Table` [ numeric ] - Summary table with a starting value, point
% estimate, std error estimate, and lower and upper bounds for each
% parameter. 
%
% * `Hess` [ cell ] - `Hess{1}` is the total hessian of the objective
% function; `Hess{2}` is the contributions of the priors to the hessian.
%
% * `MEst` [ model ] - Model object solved with the estimated parameters
% (including out-of-likelihood parameters and common variance factor).
%
% The remaining three output arguments, `V`, `delta`, `PDelta`, are the
% same as the [`model/loglik`](model/loglik) output arguments of the same
% names.
%
%
% __Options__
%
% * `'ChkSstate='` [ `true` | *`false`* | cell ] - Check steady state in
% each iteration; works only in non-linear models.
%
% * `'EvalFrfPriors='` [ *`true`* | `false` ] - In each iteration, evaluate
% frequency response function prior density, and include it to the overall
% objective function to be optimised.
%
% * `'EvalLik='` [ *`true`* | `false` ] - In each iteration, evaluate
% likelihood (or another data based criterion), and include it to the
% overall objective function to be optimised.
%
% * `'EvalPPriors='` [ *`true`* | `false` ] - In each iteration, evaluate
% parameter prior density, and include it to the overall objective function
% to be optimised.
%
% * `'EvalSPriors='` [ *`true`* | `false` ] - In each iteration, evaluate
% system prior density, and include it to the overall objective function to
% be optimised.
%
% * `'Filter='` [ cell | *empty* ] - Cell array of options that will be
% passed on to the Kalman filter including the type of objective function;
% see help on [`model/filter`](model/filter) for the options available.
%
% * `'InitVal='` [ `model` | *`struct`* | struct ] - If `struct` use the
% values in the input struct `est` to start the iteration; if `model` use
% the currently assigned parameter values in the input model, `m`.
%
% * `'MaxIter='` [ numeric | *`500`* ] - Maximum number of iterations
% allowed.
%
% * `'MaxFunEvals='` [ numeric | *`2000`* ] - Maximum number of objective
% function calls allowed.
%
% * `'NoSolution='` [ *`'error'`* | `'penalty'` | numeric ] - Specifies
% what happens if solution or steady state fails to solve in an iteration:
% `NoSolution='Error'` stops the execution with an error message,
% `NoSolution='Penalty'` returns an extreme value, `1e10`, back to the
% minimization routine; or a user-supplied penalty can be specified as a
% numeric scalar greater than `1e10`.
%
% * `'OptimSet='` [ cell | *empty* ] - Cell array used to create the
% Optimization Toolbox options structure; works only with the option
% `Solver='default'`.
%
% * `'Summary='` [ *`'table'`* | `'struct'` ] - Format of the `Summary`
% output argument.
%
% * `'Solve='` [ *`true`* | `false` | cellstr ] - Re-compute solution in
% each iteration; you can specify a cell array with options for the `solve`
% function.
%
% * `'Solver='` [ *`'default'`* | cell | function_handle ] - Minimization
% procedure.
%
%     * `'default'`: The Optimization Toolbox function `fminunc` or
%     `fmincon` will be called depending on the presence or absence of
%     lower and/or upper bounds.
% 
%     * function_handle or cell: Enter a function handle to your own
%     optimization procedure, or a cell array with a function handle and
%     additional input arguments (see below).
%
% * `'Sstate='` [ `true` | *`false`* | cell | function_handle ] -
% Re-compute steady state in each iteration; you can specify a cell array
% with options for the `sstate( )` function, or a function handle whose
% behaviour is described below.
%
% * `'TolFun='` [ numeric | *`1e-6`* ] - Termination tolerance on the
% objective function.
%
% * `'TolX='` [ numeric | *`1e-6`* ] - Termination tolerance on the
% estimated parameters.
%
%
% __Description__
%
% The parameters that are to be estimated are specified in the input
% parameter estimation database, `E` in which you can provide the following
% specifications for each parameter:
%
%     E.parameter_name = { start, lower, upper, logpriorFunc };
%
% where `start` is the value from which the numerical optimization will
% start, `lower` is the lower bound, `upper` is the upper bound, and
% `logpriorFunc` is a function handle expected to return the log of the
% prior density. You can use the [`logdist`](logdist/Contents) package to
% create function handles for some of the basic prior distributions.
%
% You can use `NaN` for `start` if you wish to use the value currently
% assigned in the model object. You can use `-Inf` and `Inf` for the
% bounds, or leave the bounds empty or not specify them at all. You can
% leave the prior distribution empty or not specify it at all.
%
%
% _Estimating Nonlinear Models_
%
% By default, only the first-order solution, but not the steady state is
% updated (recomputed) in each iteration before the likelihood is
% evaluated. This behavior is controled by two options, `Solve=` (`true`
% by default) and `Sstate=` (`false` by default). If some of the
% estimated parameters do affect the steady state of the model, the option
% `Sstate=` needs to be set to `true` or to a cell array with
% steady-state options, as in the function [`sstate`](model/sstate),
% otherwise the results will be groslly inaccurate or a valid first-order
% solution will be impossible to find.
%
% When steady state is recomputed in each iteration, you may also want to
% use the option `Chksstate=` to require that a steady-state check for
% all model equations be performed.
%
%
% _User-supplied Optimization (Minimization) Routine_
%
% You can supply a function handle to your own minimization routine through
% the option `Solver=`. This routine will be used instead of the Optim
% Tbx's `fminunc` or `fmincon` functions. The user-supplied function is
% expected to take at least five input arguments and return three output
% arguments:
%
%     [pEst, ObjEst, Hess] = yourminfunc(F, P0, PLow, PHigh, OptimSet)
%
% with the following input arguments:
%
% * `F` is a function handle to the function minimised;
% * `P0` is a 1-by-N vector of initial parameter values;
% * `PLow` is a 1-by-N vector of lower bounds (with `-Inf` indicating no
% lower bound);
% * `PHigh` is a 1-by-N vector of upper bounds (with `Inf` indicating no
% upper bounds);
% * `OptimSet` is a cell array with name-value pairs entered by the user
% through the option `'OptimSet='`. This option can be used to modify
% various settings related to the optimization routine, such as tolerance,
% number of iterations, etc. Of course, you may simply ignore it and leave
% this input argument unused;
%
% and the following output arguments:
%
% * `pEst` is a 1-by-N vector of estimated parameters;
% * `ObjEst` is the value of the objective function at optimum;
% * `Hess` is a N-by-N approximate Hessian matrix at optimum.
%
% If you need to use extra input arguments in your minimization function,
% enter a cell array instead of a plain function handle:
%
%     {@yourminfunc, Arg1, Arg2, ...}
%
% In that case, the solver will be called the following way:
%
%     [pEst, ObjEst, Hess] = yourminfunc(F, P0, PLow, PHigh, Opt, Arg1, Arg2, ...)
%
%
% _User-Supplied Steady-State Solver_
%
% You can supply a function handle to your own steady-state solver (i.e. a
% function that finds the steady state for given parameters) through the
% `Sstate=` option.
%
% The function is expected to take one input argument, the model object
% with newly assigned parameters, and return at least two output arguments,
% the model object with a new steady state (or balanced-growth path) and a
% success flag. The flag is `true` if the steady state has been successfully
% computed, and `false` if not:
%
%     [m, success] = mysstatesolver(m)
%
% It is your responsibility to add the growth characteristics if some of
% the model variables drift over time. In other words, you need to take
% care of the imaginary parts of the steady state values in the model
% object returned by the solver.
%
% Alternatively, you can also run the steady-state solver with extra input
% arguments (with the model object still being the first input argument).
% In that case, you need to set the option `Sstate='` to a cell array with
% the function handle in the first cell, and the other input arguments
% afterwards, e.g.
%
%     'Sstate=', {@mysstatesolver, 1, 'a', x}
%
% The actual function call will have the following form:
%
%     [m, success] = mysstatesolver(m, 1, 'a', x)
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;

persistent inputParser outsideOptimOptions
if isempty(inputParser)
    inputParser = extend.InputParser('model.estimate');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('Model', @(x) isa(x, 'model'));
    inputParser.addRequired('InputDatabank', @isstruct);
    inputParser.addRequired('Range', @DateWrapper.validateProperRangeInput);
    inputParser.addRequired('EstimationSpecs', @(x) isstruct(x) && ~isempty(fieldnames(x)));
    inputParser.addOptional('SystemPriors', [ ], @(x) isempty(x) || isa(x, 'systempriors') || isa(x, 'SystemPriorWrapper'));

    inputParser.addParameter('ChkSstate', true, @model.validateChksstate); 
    inputParser.addParameter('Domain', 'time', @(x) any(strncmpi(x, {'time', 'freq'}, 4)));
    inputParser.addParameter({'Filter', 'FilterOpt'}, { }, @model.validateFilter);
    inputParser.addParameter('NoSolution', 'error', @(x) (isnumeric(x) && isscalar(x) && x>=1e10) || any(strcmpi(x, {'error', 'penalty'})));
    inputParser.addParameter({'MatrixFormat', 'MatrixFmt'}, 'namedmat', @namedmat.validateMatrixFormat);
    inputParser.addParameter({'Solve', 'SolveOpt'}, true, @model.validateSolve);
    inputParser.addParameter({'Steady', 'Sstate', 'SstateOpt'}, false, @model.validateSstate);
    inputParser.addParameter('Zero', false, @(x) isequal(x, true) || isequal(x, false));

    inputParser.addParameter('OptimSet', { }, @(x) isempty(x) || isstruct(x) || iscellstr(x(1:2:end)) );

    inputParser.addParameter('EpsPower', 1/2, @(x) isnumeric(x) && isscalar(x) && x>=0);
    inputParser.addParameter('InitVal', 'struct', @(x) isempty(x) || isstruct(x) || isanystri(x, {'struct', 'model'}));
    inputParser.addParameter('Penalty', 0, @(x) isnumeric(x) && isscalar(x) && x>=0);
    inputParser.addParameter({'EvalLik', 'EvaluateData'}, true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'EvalPPrior', 'EvaluateParamPriors'}, true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'EvalSPrior', 'EvaluateSystemPriors'}, true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'Solver', 'Optimizer'}, 'fmin', @(x) isa(x, 'function_handle') || ischar(x) || isa(x, 'string') || (iscell(x) && iscellstr(x(2:2:end)) && (ischar(x{1}) || isa(x{1}, 'function_handle') || isa(x{1}, 'string'))));
    inputParser.addParameter('Summary', 'struct', @(x) any(strcmpi(x, {'struct', 'table'})));
    inputParser.addParameter('UpdateInit', [ ], @(x) isempty(x) || isstruct(x));
end
if isempty(outsideOptimOptions)
    outsideOptimOptions = extend.InputParser('model.estimate');
    outsideOptimOptions.addParameter('Algorithm', @default, @(x) isequal(x, @default) || ischar(x) || isa(x, 'string'));
    outsideOptimOptions.addParameter('Display', 'iter', @(x) any(strcmpi(x, {'iter', 'final', 'none', 'off'})) );
    outsideOptimOptions.addParameter('MaxFunEvals', 2000, @(x) isnumeric(x) && isscalar(x)  && x>0);
    outsideOptimOptions.addParameter('MaxIter', 500, @(x) isnumeric(x) && isscalar(x) && x>=0);
    outsideOptimOptions.addParameter('TolFun', 1e-6, @(x) isnumeric(x) && isscalar(x) && x>0);
    outsideOptimOptions.addParameter('TolX', 1e-6, @(x) isnumeric(x) && isscalar(x) && x>0);
end
inputParser.parse(this, inputDatabank, range, varargin{:});
systemPriors = inputParser.Results.SystemPriors;
estimationSpecs = inputParser.Results.EstimationSpecs;
opt = inputParser.Options;
outsideOptimOptions.parse(inputParser.UnmatchedInCell{:});

% Initialize and preprocess sstate, chksstate, solve options.
opt.Steady = prepareSteady(this, 'silent', opt.Steady);
opt.ChkSstate = prepareChkSteady(this, 'silent', opt.ChkSstate);
opt.Solve = prepareSolve(this, 'silent, fast', opt.Solve);

% Process likelihood function options and create a likstruct.
likOpt = prepareLoglik(this, range, opt.Domain, [ ], opt.Filter{:});
opt = rmfield(opt, 'Filter');

% Get first column of measurement and exogenous variables.
if opt.EvalLik
    % `Data` includes pre-sample.
    req = [likOpt.domain(1), 'yg*'];
    inputArray = datarequest(req, this, inputDatabank, range, 1);
else
    inputArray = [ ];
end

%--------------------------------------------------------------------------

% Warning if no measurement variables in the model
assert( ...
    any(this.Quantity.Type==TYPE(1)), ...
    exception.Base('Model:NoMeasurementVariables', 'warning') ...
);

% Retrieve names of parameters to be estimated, initial values, lower
% and upper bounds, penalties, and prior distributions.
if isa(systemPriors, 'SystemPriorWrapper')
    seal(systemPriors);
end

%{
itr = parseEstimStruct(this, estimationSpecs, systemPriors, opt.Penalty, opt.InitVal);
[this, pStar, objStar, propCov, hessian, validDiff, infoFromLik] =...
    estimate@shared.Estimation(this, inputArray, itr, opt, likOpt);
%}

% __Set Up Posterior and EstimationWrapper__
[this, posterior] = preparePosterior(this, estimationSpecs, opt.Penalty, opt.InitVal);
posterior.ObjectiveFunction = @(x) objfunc(x, this, inputArray, posterior, opt, likOpt);
posterior.SystemPriors = systemPriors;
posterior.EvaluateData = opt.EvalLik;
posterior.EvaluateParamPriors = opt.EvalPPrior;
posterior.EvaluateSystemPriors = opt.EvalSPrior;

estimationWrapper = EstimationWrapper( );
estimationWrapper.IsConstrained = posterior.IsConstrained;
chooseSolver(estimationWrapper, opt.Solver, outsideOptimOptions.Options);

% __Run Optimizer__
maximizePosteriorMode(posterior, estimationWrapper);

% Assign estimated parameters, refresh dynamic links, and re-compute steady
% state, solution, and expansion matrices.
variantRequested = 1;
opt.Solve.fast = false;
throwError = true;
this = update(this, posterior.Optimum, variantRequested, opt, throwError);

% __Set Up Posterior Object__
% Set up posterior object before we assign out-of-liks and scale std
% errors in the model object.
p = poster( );
populatePosterObj( );

% __Re-run Loglik for Out-of-lik Params__
% Re-run the Kalman filter or FD likelihood to get the estimates of V
% and out-of-lik parameters.
V = 1;
delta = [ ];
PDelta = [ ];
if opt.EvalLik && (nargout>=5 || likOpt.relative)
    [~, regOutp] = likOpt.minusLogLikFunc(this, inputArray, [ ], likOpt);
    % Post-process the regular output arguments, update the std parameter
    % in the model object, and refresh if needed.
    xRange = range(1)-1 : range(end);
    [~, ~, V, delta, PDelta, ~, this] ...
        = kalmanFilterRegOutp(this, regOutp, xRange, likOpt, opt);
end

% Database with point estimates.
if strcmpi(opt.Summary, 'struct')
    summary = cell2struct(num2cell(posterior.Optimum(:)'), posterior.ParameterNames, 2);
else
    summary = createSummaryTable( );
end
proposalCov = posterior.ProposalCov;

hessian = posterior.Hessian;

this.TaskSpecific = [ ];

if nargout>8
    % ##### Feb 2018 OBSOLETE and scheduled for removal.
    throw( exception.Base('Obsolete:Estimate8', 'warning') );
    varargout = {delta, PDelta};
end

return


    function summary = createSummaryTable( )
        posterStd = sqrt(diag(posterior.ProposalCov));
        posterStd(~posterior.IndexValidDiff) = NaN;
        numParameters = posterior.NumParameters;
        priorName = repmat({'Flat'}, 1, numParameters);
        priorMean = nan(1, numParameters);
        priorMode = nan(1, numParameters);
        priorStd = nan(1, numParameters);
        for i = find(posterior.IndexPriors)
            try
                priorName{i} = posterior.PriorDistributions{i}.Name;
                priorMean(i) = posterior.PriorDistributions{i}.Mean;
                priorMode(i) = posterior.PriorDistributions{i}.Mode;
                priorStd(i) =  posterior.PriorDistributions{i}.Std;
            end
        end
        variables = {
            posterior.ParameterNames(:), 'Name', 'Name'
            posterior.Optimum(:), 'Poster_Mode', 'Posterior Mode'
            posterStd(:), 'Poster_Std', 'Posterior Std Deviation'
            priorName(:), 'Prior_Distrib', 'Prior Distribution Type'
            priorMean(:), 'Prior_Mean', 'Prior Mean'
            priorMode(:), 'Prior_Mode', 'Prior Mode'
            priorStd(:), 'Prior_Std', 'Prior Std Deviation'
            posterior.LowerBounds(:), 'Lower_Bound', 'Lower Bound'
            posterior.UpperBounds(:), 'Upper_Bound', 'Upper Bound'
            posterior.PropOfLineInfoFromData(:), 'Info_from_Data', 'Proportion of Information from Data'
            posterior.Initial(:), 'Start', 'Starting Value'
        };
        summary = table( ...
            variables{:, 1}, ...
            'VariableNames', variables(:, 2)' ...
        );
        summary.Properties.VariableDescriptions = variables(:, 3)';
    end


    function populatePosterObj( )
        % Make sure that draws that fail to solve do not cause an error
        % and hence do not interupt the posterior simulator.
        opt.NoSolution = Inf;

        p.ParamList = posterior.ParameterNames;
        p.MinusLogPostFunc = @objfunc;
        p.MinusLogPostFuncArgs = {this, inputArray, posterior, opt, likOpt};
        p.InitLogPost = -posterior.ObjectiveAtOptimum;
        p.InitParam = posterior.Optimum;
        try
            p.InitProposalCov = posterior.ProposalCov;
        catch Error
            utils.warning('model:estimate', ...
                ['Posterior simulator object cannot be initialised.', ...
                '\nThe following error occurs:\n\n%s'], ...
                Error.message);
        end
        p.Lower = posterior.LowerBounds;
        p.Upper = posterior.UpperBounds;
    end
end
