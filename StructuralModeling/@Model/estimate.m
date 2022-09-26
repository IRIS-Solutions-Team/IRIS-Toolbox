%{
% 
% # `estimate` ^^(Model)^^
% 
% {== Estimate model parameters by maximizing posterior-based objective function ==}
% 
% 
% ## Syntax
% 
% Input arguments marked with a `~` sign may be omitted.
% 
%     [summary, poster, proposalCov, hess, mEst] ...
%         = estimate(m, inputDb, range, estimSpecs, ~SystemPriors, ...)
% 
% 
% ## Input arguments
% 
% __`m`__ [ model ]
% >
% > Model object with single parameterization.
% > 
% 
% 
% __`inputDb`__ [ struct ]
% >
% > Input database from which the measurement variables will be
% > taken.
% > 
% 
% 
% __`range`__ [ struct ]
% >
% > Date range on which the data likelihood
% > will be evaluated.
% > 
% 
% 
% __`estimSpecs`__ [ struct ]
% >
% > Struct with the list of paremeters that will be
% > estimated, and the parameter prior specifications (see below).
% > 
% 
% 
% __`SystemPriors=[]`__ [ SystemPriorWrapper | empty ]
% >
% > System priors, [`SystemPriorWrapper`](systempriors/Contents).
% > 
% 
% 
% ## Output arguments
% 
% 
% __`summary`__ [ table ]
% >
% > Table with summary information.
% > 
% 
% 
% __`poster`__ [ Posterior ]
% >
% > Posterior, [`poster`](poster/Contents), object;
% > this object also gives you access to the value of the objective function
% > at optimum or at any point in the parameter space, see the
% > [`Posterior/eval`](../@Posterior/eval) function.
% > 
% 
% 
% __`proposalCov`__ [ numeric ]
% >
% > Proposal covariance matrix based on the final Hessian, and adjusted for
% > lower/upper bound hits.
% > 
% 
% 
% __`hess`__ [ cell ]
% >
% > `Hess{1}` is the total hessian of the objective
% > function; `Hess{2}` is the contributions of the priors to the hessian.
% > 
% 
% 
% __`mEst`__ [ Model ]
% >
% > Model object solved with the estimated parameters (including
% > out-of-likelihood parameters and common variance factor).
% > 
% 
% 
% ## Options
% 
% __`CheckSteady=false`__ [ `true` | `false` | cell ]
% >
% > Check steady state in each iteration; works only in non-linear models.
% > 
% 
% 
% __`EvalLikelihood=true`__ [ `true` | `false` ]
% >
% > In each iteration, evaluate likelihood (or another data based criterion),
% > and include it to the overall objective function to be optimised.
% > 
% 
% 
% __`EvalParameterPriors=true`__ [ `true` | `false` ]
% >
% > In each iteration, evaluate parameter prior density, and include it to
% > the overall objective function to be optimised.
% > 
% 
% 
% __`EvalSystemPriors=true`__ [ `true` | `false` ]
% >
% > In each iteration, evaluate system prior density, and include it to the
% > overall objective function to be optimised.
% > 
% 
% 
% __`Filter={}`__ [ cell ]
% >
% > Cell array of options that will be passed on to the Kalman filter
% > including the type of objective function; see help on
% > [`kalmanFilter`](kalmanFilter.md) for the options available.
% >  
% 
% __`StartIterations="struct"`__ [ `"Model"` | `"Struct"` | struct ]
% > 
% > If `InitVal="struct"` use the values in the input struct `est` to start
% > the iteration; if `Model` use the currently assigned parameter values in
% > the input model, `m`.
% >  
% 
% 
% __`MaxIter=500`__ [ numeric ]
% >
% > Maximum number of iterations allowed.
% > 
% 
% 
% __`MaxFunEvals=2000`__ [ numeric ]
% >
% > Maximum number of objective function calls allowed.
% > 
% 
% 
% __`NoSolution='Error'`__ [ `'Error'` | `'Penalty'` | numeric ]
% >
% > > Specifies
% > what happens if solution or steady state fails to solve in an iteration:
% > `NoSolution='Error'` stops the execution with an error message,
% > `NoSolution='Penalty'` returns an extreme value, `1e10`, back to the
% > minimization routine; or a user-supplied penalty can be specified as a
% > numeric scalar greater than `1e10`.
% > 
% 
% 
% __`OptimSet={}`__ [ cell ]
% >
% > Cell array used to create the Optimization
% > Toolbox options structure; works only with the option `Solver='Default'`.
% > 
% 
% 
% __`Summary='Table'`__ [ `'Table'` | `'Struct'` ]
% >
% > Format of the `Summary` output argument.
% > 
% 
% 
% __`Solve=true`__ [ `true` | `false` | cellstr ]
% > 
% > Re-compute solution in
% > each iteration; you can specify a cell array with options for the `solve`
% > function.
% > 
% 
% __`Steady=false`__ [ `true` | `false` | cell | function_handle ]
% >
% > Re-compute steady state in each iteration; you can specify a cell array
% > with options for the `sstate( )` function, or a function handle whose
% > behaviour is described below.
% > 
% 
% __`TolFun=1e-6`__ [ numeric ]
% >
% > Termination tolerance on the objective
% > function.
% > 
% 
% __`TolX=1e-6`__ [ numeric ]
% >
% > Termination tolerance on the estimated
% > parameters.
% > 
% 
% 
% ## Description
% 
% The parameters that are to be estimated are specified in the input
% parameter estimation specification struct, `estimSpecs` in which you can provide the following
% specifications for each parameter:
% 
%     estimSpecs.parameterName = { start, lower, upper, prior };
% 
% where `start` is the value from which the numerical optimization will
% start, `lower` is the lower bound, `upper` is the upper bound, and `prior`
% is a 
% [distribution function object](../../ShrinkageEstimation/+distribution/index.md)
% specifying the prior density for the parameter.
% 
% You can use `NaN` for `start` if you wish to use the value currently
% assigned in the model object. You can use `-Inf` and `Inf` for the
% bounds, or leave the bounds empty or not specify them at all. You can
% leave the prior distribution empty.
% 
% 
% _Estimating nonlinear models_
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
% ## Examples
% 
% 
% 
%}
% --8<--


% Type `web Model/estimate.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function ...
    [summary, p, proposalCov, hessian, this, V, delta, PDelta] ...
    = estimate(this, inputDb, range, estimSpecs, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    ip.KeepUnmatched = true;
    addOptional(ip, 'SystemPriors', [], @(x) isempty(x) || isa(x, "SystemPriorWrapper"));
    addParameter(ip, 'CheckSteady', true, @model.validateChksstate); 
    addParameter(ip, 'Domain', 'time', @(x) any(strncmpi(x, {'time', 'freq'}, 4)));
    addParameter(ip, 'Filter', cell.empty(1, 0), @validate.nestedOptions);
        addParameter(ip, 'FilterOpt__Filter', []);
    addParameter(ip, 'NoSolution', 'Error', @(x) validate.numericScalar(x, 1e10, Inf) || validate.anyString(x, 'Error', 'Penalty'));
    addParameter(ip, 'MatrixFormat', 'namedmat', @validate.matrixFormat);
    addParameter(ip, 'Solve', true, @model.validateSolve);
    addParameter(ip, 'Steady', false, @model.validateSteady);
        addParameter(ip, 'Sstate__Steady', []);
        addParameter(ip, 'SstateOpt__Steady', []);
    addParameter(ip, 'Zero', false, @(x) isequal(x, true) || isequal(x, false));

    addParameter(ip, 'OptimSet', {}, @(x) isempty(x) || isstruct(x) || iscellstr(x(1:2:end)) );

    addParameter(ip, 'EpsPower', 1/2, @(x) validate.numericScalar(x, 0, Inf));
    addParameter(ip, 'StartIterations', 'struct', @(x) isempty(x) || isstruct(x) || validate.anyString(x, "struct", "model"));
        addParameter(ip, 'InitVal__StartIterations', []);
    addParameter(ip, 'Penalty', 0, @(x) isnumeric(x) && isscalar(x) && x>=0);
    addParameter(ip, 'HonorBounds', true, @validate.logicalScalar);
    addParameter(ip, 'EvalDataLik', true, @local_validateEval);
    addParameter(ip, 'EvalIndiePriors', true, @local_validateEval);
    addParameter(ip, 'EvalSystemPriors', true, @local_validateEval);
    addParameter(ip, 'Solver', 'fmin', @(x) isa(x, 'function_handle') || ischar(x) || isa(x, 'string') || (iscell(x) && iscellstr(x(2:2:end)) && (ischar(x{1}) || isa(x{1}, 'function_handle') || isa(x{1}, 'string'))));
    addParameter(ip, 'Summary', 'table', @(x) any(strcmpi(x, {'struct', 'table'})));
    addParameter(ip, 'UpdateInit', [ ], @(x) isempty(x) || isstruct(x));

    addParameter(ip, 'Algorithm', @auto, @(x) isequal(x, @auto) || ischar(x) || isstring(x));
    addParameter(ip, 'Display', 'iter', @(x) validate.anyString(x, 'iter', 'final', 'none', 'off'));
    addParameter(ip, 'MaxFunEvals', 2000, @(x) validate.numericScalar(x, 0, Inf));
    addParameter(ip, 'MaxIter', 500, @(x) validate.numericScalar(x, 0, Inf));
    addParameter(ip, 'TolFun', 1e-6, @(x) validate.numericScalar(x, 0, Inf));
    addParameter(ip, 'TolX', 1e-6, @(x) validate.numericScalar(x, 0, Inf));
end
parse(ip, varargin{:});
systemPriors = ip.Results.SystemPriors;
opt = rmfield(ip.Results, "SystemPriors");


opt = iris.utils.resolveOptionAliases(opt, [], true);


outsideOptimOptions = struct();
for n = ["Algorithm", "Display", "MaxFunEvals", "MaxIter", "TolFun", "TolX"]
    outsideOptimOptions.(n) = opt.(n);
    opt = rmfield(opt, n);
end


if isempty(inputDb) || isempty(fieldnames(inputDb))
    opt.EvalDataLik = 0;
end


%
% Process likelihood function options if needed
%
likOpt = struct();
inputArray = [];
if opt.EvalDataLik>0
    if startsWith(opt.Domain, "t", "ignoreCase", true)
        likOpt = prepareKalmanOptions2(this, range, opt.Filter{:});
        inputArray = prepareKalmanData(this, inputDb, range, likOpt.WhenMissing);
        likOpt.minusLogLikFunc = @implementKalmanFilter;
    else
        exception.error(["Model", "Frequency domain estimation not implemented at the moment"]);
        % likOpt = prepareFreqlOptions(this, range, opt.Filter{:});
        % inputArray = ...
        % likOpt.minusLogLikFunc = @freckle;
    end
end
opt = rmfield(opt, 'Filter');


% Warning if there are no measurement variables in the model and data
% likelihood is to be evaluated
if opt.EvalDataLik>0 && ~any(this.Quantity.Type==1);
    throw( exception.Base('Model:NoMeasurementVariables', 'warning') );
end

%
% Prepare Posterior object, model.Update, and EstimationWrapper
%
[this, posterior] = preparePosteriorAndUpdate(this, estimSpecs, opt);
posterior.ObjectiveFunction = @(x) objfunc(x, this, inputArray, posterior, opt, likOpt);
posterior.SystemPriors = systemPriors;
posterior.HonorBounds = opt.HonorBounds;
posterior.EvalDataLik = opt.EvalDataLik;
posterior.EvalIndiePriors = opt.EvalIndiePriors;
posterior.EvalSystemPriors = opt.EvalSystemPriors;
if isa(posterior.SystemPriors, 'SystemPriorWrapper')
    seal(posterior.SystemPriors);
end

estimationWrapper = EstimationWrapper( );
estimationWrapper.IsConstrained = posterior.IsConstrained;
chooseSolver(estimationWrapper, opt.Solver, outsideOptimOptions);


%==========================================================================
%
% Run optimizer
%
maximizePosteriorMode(posterior, estimationWrapper);
%==========================================================================


% Assign estimated parameters, refresh dynamic links, and re-compute steady
% state, solution, and expansion matrices.
variantRequested = 1;
this = update(this, posterior.Optimum, variantRequested);

%
% Set Up Posterior Object
%
% Set up posterior object before we assign out-of-liks and scale std
% errors in the model object
p = here_createLegacyPoster( );

%
% Re-run likelihood function for outlik params
%
% Re-run the Kalman filter or FD likelihood to get the estimates of V
% and out-of-lik parameters.
V = 1;
delta = [ ];
PDelta = [ ];
if opt.EvalDataLik>0 && (nargout>=5 || likOpt.Relative)
    argin = struct( ...
        'FilterRange', double(range), ...
        'InputData', inputArray, ...
        'OutputData', [ ], ...
        'InternalAssignFunc', [ ], ...
        'Options', likOpt ...
    );
    [~, regOutp] = likOpt.minusLogLikFunc(this, argin);
    % Post-process the regular output arguments, update the std parameter
    % in the model object, and refresh if needed.
    xRange = range(1)-1 : range(end);
    [~, ~, V, delta, PDelta, ~, this] = kalmanFilterRegOutp(this, regOutp, xRange, likOpt, opt);
end

% Database with point estimates
if strcmpi(opt.Summary, 'struct')
    summary = cell2struct(reshape(num2cell(posterior.Optimum), 1, []), reshape(cellstr(posterior.ParameterNames), 1, []), 2);
else
    summary = table(posterior);
end
proposalCov = posterior.ProposalCov;

hessian = posterior.Hessian;

this.Update = this.EMPTY_UPDATE;

return

    function p = here_createLegacyPoster()

        p = poster();

        % Make sure that draws that fail to solve do not cause an error
        % and hence do not interupt the posterior simulator
        this.Update.NoSolution = Inf;

        p.ParameterNames = posterior.ParameterNames;
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
    end%
end%

%
% Local validators
%

function local_validateEval(x)
    try
        x = double(x);
    end
    if isnumeric(x) && isscalar(x) && x>=0
        return
    end
    error("Input value must be a non-negative scalar.");
end%

