function [summary, p, propCov, hessian, this, V, delta, PDelta] = estimate(this, inp, range, varargin)
% estimate  Estimate model parameters by optimizing selected objective function.
%
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
% `'Error='` stops the execution with an error message, `'Penalty='`
% returns an extreme value, `1e10`, back into the minimization routine; or
% a user-supplied penalty can be specified as a numeric scalar greater than
% `1e10`.
%
% * `'OptimSet='` [ cell | *empty* ] - Cell array used to create the
% Optimization Toolbox options structure; works only with the option
% `'Optimiser='` `'default'`.
%
% * `'Summary='` [ *`'table'`* | `'struct'` ] - Format of the `Summary`
% output argument.
%
% * `'Solve='` [ *`true`* | `false` | cellstr ] - Re-compute solution in
% each iteration; you can specify a cell array with options for the `solve`
% function.
%
% * `'Optimiser='` [ *`'default'`* | `'pso'` | cell | function_handle ] -
% Minimiz ation procedure.
%
%     * `'default'`: The Optimization Toolbox function `fminunc` or
%     `fmincon` will be called depending on the presence or absence of
%     lower and/or upper bounds.
% 
%     * `'alps'`: The age layer population structure evolutionary algorithm
%     will be used. See irisoptim.alps help for more information. 
%
%     * `'pso'`: The particle swarm optimizer will be called. See the
%     irisoptim.pso help for more information. 
%
%     * function_handle or cell: Enter a function handle to your own
%     optimization procedure, or a cell array with a function handle and
%     additional input arguments (see below).
%
% * `'Sstate='` [ `true` | *`false`* | cell | function_handle ] -
% Re-compute steady state in each iteration; you can specify a cell array
% with options for the `sstate` function, or a function handle whose
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
% _Estimating Nonlinear Models__
%
% By default, only the first-order solution, but not the steady state is
% updated (recomputed) in each iteration before the likelihood is
% evaluated. This behavior is controled by two options, `'Solve='` (`true`
% by default) and `'Sstate='` (`false` by default). If some of the
% estimated parameters do affect the steady state of the model, the option
% '`sstate='` needs to be set to `true` or to a cell array with
% steady-state options, as in the function [`sstate`](model/sstate),
% otherwise the results will be groslly inaccurate or a valid first-order
% solution will be impossible to find.
%
% When steady state is recomputed in each iteration, you may also want to
% use the option `'Chksstate='` to require that a steady-state check for
% all model equations be performed.
%
%
% __User-supplied Optimization (Minimization) Routine__
%
% You can supply a function handle to your own minimization routine through
% the option `'Optimiser='`. This routine will be used instead of the Optim
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
% In that case, the optimiser will be called the following way:
%
%     [pEst, ObjEst, Hess] = yourminfunc(F, P0, PLow, PHigh, Opt, Arg1, Arg2, ...)
%
%
% _User-Supplied Steady-State Solver__
%
% You can supply a function handle to your own steady-state solver (i.e. a
% function that finds the steady state for given parameters) through the
% `'Sstate='` option.
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
% In that case, you need to set the option `'Sstate='` to a cell array with
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model/estimate');
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model'));
    INPUT_PARSER.addRequired('InputDatabank', @isstruct);
    INPUT_PARSER.addRequired('Range', @DateWrapper.validateProperRangeInput);
    INPUT_PARSER.addRequired('EstimationSpecs', @(x) isstruct(x) && ~isempty(fieldnames(x)));
    INPUT_PARSER.addOptional('SystemPriors', [ ], @(x) isempty(x) || isa(x, 'systempriors'));

    INPUT_PARSER.addParameter('ChkSstate', true, @model.validateChksstate); 
    INPUT_PARSER.addParameter('Domain', 'time', @(x) any(strncmpi(x, {'time', 'freq'}, 4)));
    INPUT_PARSER.addParameter({'Filter', 'FilterOpt'}, { }, @model.validateFilter);
    INPUT_PARSER.addParameter('NoSolution', 'error', @(x) (isnumeric(x) && numel(x)==1 && x>=1e10) || any(strcmpi(x, {'error', 'penalty'})));
    INPUT_PARSER.addParameter({'MatrixFormat', 'MatrixFmt'}, 'namedmat', @namedmat.validateMatrixFormat);
    INPUT_PARSER.addParameter({'Solve', 'SolveOpt'}, true, @model.validateSolve);
    INPUT_PARSER.addParameter({'Steady', 'Sstate', 'SstateOpt'}, false, @model.validateSstate);
    INPUT_PARSER.addParameter('Zero', false, @(x) isequal(x, true) || isequal(x, false));

    INPUT_PARSER.addParameter('Display', 'iter', @(x) isanystri(x, {'iter', 'final', 'none', 'off'}));
    INPUT_PARSER.addParameter('EpsPower', 1/2, @(x) isnumeric(x) && numel(x)==1 && x>=0);
    INPUT_PARSER.addParameter('InitVal', 'struct', @(x) isempty(x) || isstruct(x) || isanystri(x, {'struct', 'model'}));
    INPUT_PARSER.addParameter('MaxIter', 500, @(x) isnumeric(x) && numel(x)==1 && x>=0);
    INPUT_PARSER.addParameter('MaxFunEvals', 2000, @(x) isnumeric(x) && numel(x)==1 && x>0);
    INPUT_PARSER.addParameter('OptimSet', { }, @(x) isempty(x) || isstruct(x) || (iscell(x) && iscellstr(x(1:2:end))));
    INPUT_PARSER.addParameter('Penalty', 0, @(x) isnumericscalar(x) && x>=0);
    INPUT_PARSER.addParameter('EvalLik', true, @(x) isequal(x, true) || isequal(x, false));
    INPUT_PARSER.addParameter('EvalPPrior', true, @(x) isequal(x, true) || isequal(x, false));
    INPUT_PARSER.addParameter('EvalSPrior', true, @(x) isequal(x, true) || isequal(x, false));
    INPUT_PARSER.addParameter('Solver', 'fmin', @(x) (ischar(x) && any(strcmpi(x, {'fmin', 'lsqnonlin', 'pso', 'alps'}))) || iscell(x) || isfunc(x));
    INPUT_PARSER.addParameter('Summary', 'struct', @(x) any(strcmpi(x, {'struct', 'table'})));
    INPUT_PARSER.addParameter('TolFun', 1e-6, @(x) isnumeric(x) && numel(x)==1 && x>0);
    INPUT_PARSER.addParameter('TolX', 1e-6, @(x) isnumeric(x) && numel(x)==1 && x>0);
    INPUT_PARSER.addParameter('UpdateInit', [ ], @(x) isempty(x) || isstruct(x));
end
INPUT_PARSER.parse(this, inp, range, varargin{:});
systemPriors = INPUT_PARSER.Results.SystemPriors;
estSpec = INPUT_PARSER.Results.EstimationSpecs;
estOpt = rmfield( ...
    INPUT_PARSER.Results, ...
    {'Model', 'InputDatabank', 'Range', 'EstimationSpecs', 'SystemPriors'} ...
);

% Initialize and preprocess sstate, chksstate, solve options.
estOpt.Steady = prepareSteady(this, 'silent', estOpt.Steady);
estOpt.ChkSstate = prepareChkSteady(this, 'silent', estOpt.ChkSstate);
estOpt.Solve = prepareSolve(this, 'silent, fast', estOpt.Solve);

% Process likelihood function options and create a likstruct.
likOpt = prepareLoglik(this, range, estOpt.Domain, [ ], estOpt.Filter{:});
estOpt = rmfield(estOpt, 'Filter');

% Get first column of measurement and exogenous variables.
if estOpt.EvalLik
    % `Data` includes pre-sample.
    req = [likOpt.domain(1), 'yg*'];
    inp = datarequest(req, this, inp, range, 1);
else
    inp = [ ];
end

%--------------------------------------------------------------------------

ixy = this.Quantity.Type==TYPE(1);

% Check prior consistency.
callChkPriors( );

assert( ...
    any(ixy), ...
    exception.Base('Model:NoMeasurementVariables', 'warning') ...
);

% Retrieve names of parameters to be estimated, initial values, lower
% and upper bounds, penalties, and prior distributions.
itr = parseEstimStruct(this, estSpec, systemPriors, estOpt.Penalty, estOpt.InitVal);

% _Run Estimation from Backend Class__
[this, pStar, objStar, propCov, hessian, validDiff, infoFromLik] = estimate@shared.Estimation(this, inp, itr, estOpt, likOpt);

% Assign estimated parameters, refresh dynamic links, and re-compute steady
% state, solution, and expansion matrices.
throwError = true;
estOpt.Solve.fast = false;
this = update(this, pStar, itr, 1, estOpt, throwError);

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
if estOpt.EvalLik && (nargout>=5 || likOpt.relative)
    [~, regOutp] = likOpt.minusLogLikFunc(this, inp, [ ], likOpt);
    % Post-process the regular output arguments, update the std parameter
    % in the model object, and refresh if needed.
    xRange = range(1)-1 : range(end);
    [~, ~, V, delta, PDelta, ~, this] ...
        = kalmanFilterRegOutp(this, regOutp, xRange, likOpt, estOpt);
end

% Database with point estimates.
if strcmpi(estOpt.Summary, 'struct')
    summary = cell2struct(num2cell(pStar(:)'), itr.LsParam, 2);
else
    summary = createSummaryTable( );
end

return


    function callChkPriors( )
        [flag, invalidBounds, invalidPrior] = chkpriors(this, estSpec);
        if ~flag
            if ~isempty(invalidBounds)
                utils.error('model:estimate', ...
                    ['Initial condition is inconsistent with ', ...
                    'lower/upper bounds: ''%s''.'], ...
                    invalidBounds{:});
            end
            if ~isempty(invalidPrior)
                utils.error('model:estimate', ...
                    ['Initial condition is inconsistent with ', ...
                    'prior distribution: ''%s''.'], ...
                    invalidPrior{:});
            end
        end
    end 


    function summary = createSummaryTable( )
        posterStd = sqrt(diag(propCov));
        posterStd(~validDiff) = NaN;
        numParameters = numel(itr.LsParam);
        priorName = repmat({''}, 1, numParameters);
        priorMean = nan(1, numParameters);
        priorMode = nan(1, numParameters);
        priorStd = nan(1, numParameters);
        for i = find(itr.IxPrior)
            try
                priorName{i} = itr.FnPrior{i}.Name;
                priorMean(i) = itr.FnPrior{i}.Mean;
                priorMode(i) = itr.FnPrior{i}.Mode;
                priorStd(i) = itr.FnPrior{i}.Std;
            end
        end
        summary = table( ...
            pStar(:), posterStd(:), priorName(:), priorMean(:), priorMode(:), priorStd(:), infoFromLik(:), itr.Init(:), itr.Lower(:), itr.Upper(:), ...
            'VariableNames', {'Poster_Mode', 'Poster_Std', 'Prior_Distrib', 'Prior_Mean', 'Prior_Mode', 'Prior_Std', 'Info_from_Lik', 'Start', 'Lower_Bound', 'Upper_Bound'}, ...
            'RowNames', itr.LsParam(:) ...
        );
    end


    function populatePosterObj( )
        % Make sure that draws that fail to solve do not cause an error
        % and hence do not interupt the posterior simulator.
        estOpt.NoSolution = Inf;

        p.ParamList = itr.LsParam;
        p.MinusLogPostFunc = @objfunc;
        p.MinusLogPostFuncArgs = {this, inp, itr, estOpt, likOpt};
        p.InitLogPost = -objStar;
        p.InitParam = pStar;
        try
            p.InitProposalCov = propCov;
        catch Error
            utils.warning('model:estimate', ...
                ['Posterior simulator object cannot be initialised.', ...
                '\nThe following error occurs:\n\n%s'], ...
                Error.message);
        end
        p.Lower = itr.Lower;
        p.Upper = itr.Upper;
    end
end
