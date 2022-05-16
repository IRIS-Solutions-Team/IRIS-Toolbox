% Type `web Model/estimate.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function ...
    [summary, p, proposalCov, hessian, this, V, delta, PDelta] ...
    = estimate(this, inputDatabank, range, varargin)

persistent pp outsideOptimOptions
if isempty(pp)
    pp = extend.InputParser('model.estimate');
    pp.KeepUnmatched = true;
    pp.addRequired('Model', @(x) isa(x, 'model'));
    pp.addRequired('InputDatabank', @(x) isempty(x) || validate.databank(x));
    pp.addRequired('Range', @(x) isempty(x) || validate.properRange(x));
    pp.addRequired('EstimationSpecs', @(x) isstruct(x) && ~isempty(fieldnames(x)));
    pp.addOptional('SystemPriors', [ ], @(x) isempty(x) || isa(x, 'SystemPriorWrapper'));

    pp.addParameter('CheckSteady', true, @model.validateChksstate); 
    pp.addParameter('Domain', 'time', @(x) any(strncmpi(x, {'time', 'freq'}, 4)));
    pp.addParameter({'Filter', 'FilterOpt'}, cell.empty(1, 0), @validate.nestedOptions);
    pp.addParameter('NoSolution', 'Error', @(x) validate.numericScalar(x, 1e10, Inf) || validate.anyString(x, 'Error', 'Penalty'));
    pp.addParameter({'MatrixFormat', 'MatrixFmt'}, 'namedmat', @validate.matrixFormat);
    pp.addParameter({'Solve', 'SolveOpt'}, true, @model.validateSolve);
    pp.addParameter({'Steady', 'Sstate', 'SstateOpt'}, false, @model.validateSteady);
    pp.addParameter('Zero', false, @(x) isequal(x, true) || isequal(x, false));

    pp.addParameter('OptimSet', { }, @(x) isempty(x) || isstruct(x) || iscellstr(x(1:2:end)) );

    pp.addParameter('EpsPower', 1/2, @(x) validate.numericScalar(x, 0, Inf));
    pp.addParameter('InitVal', 'struct', @(x) isempty(x) || isstruct(x) || isanystri(x, {'struct', 'model'}));
    pp.addParameter('Penalty', 0, @(x) isnumeric(x) && isscalar(x) && x>=0);
    pp.addParameter('HonorBounds', true, @validate.logicalScalar);
    pp.addParameter({'EvalDataLik', 'EvaluateData', 'EvalLikelihood', 'EvalLik'}, true, @locallyValidateEval);
    pp.addParameter({'EvalIndiePriors', 'EvaluateParamPriors', 'EvalPPrior'}, true, @locallyValidateEval);
    pp.addParameter({'EvalSystemPriors', 'EvaluateSystemPriors', 'EvalSPrior'}, true, @locallyValidateEval);
    pp.addParameter({'Solver', 'Optimizer'}, 'fmin', @(x) isa(x, 'function_handle') || ischar(x) || isa(x, 'string') || (iscell(x) && iscellstr(x(2:2:end)) && (ischar(x{1}) || isa(x{1}, 'function_handle') || isa(x{1}, 'string'))));
    pp.addParameter('Summary', 'table', @(x) any(strcmpi(x, {'struct', 'table'})));
    pp.addParameter('UpdateInit', [ ], @(x) isempty(x) || isstruct(x));
end

if isempty(outsideOptimOptions)
    outsideOptimOptions = extend.InputParser('model.estimate');
    outsideOptimOptions.addParameter('Algorithm', @default, @(x) isequal(x, @default) || ischar(x) || isa(x, 'string'));
    outsideOptimOptions.addParameter('Display', 'Iter', @(x) validate.anyString(x, 'Iter', 'Final', 'None', 'Off'));
    outsideOptimOptions.addParameter('MaxFunEvals', 2000, @(x) validate.numericScalar(x, 0, Inf));
    outsideOptimOptions.addParameter('MaxIter', 500, @(x) validate.numericScalar(x, 0, Inf));
    outsideOptimOptions.addParameter('TolFun', 1e-6, @(x) validate.numericScalar(x, 0, Inf));
    outsideOptimOptions.addParameter('TolX', 1e-6, @(x) validate.numericScalar(x, 0, Inf));
end
pp.parse(this, inputDatabank, range, varargin{:});
estimationSpecs = pp.Results.EstimationSpecs;
opt = pp.Options;
outsideOptimOptions.parse(pp.UnmatchedInCell{:});

if isempty(inputDatabank) || isempty(fieldnames(inputDatabank))
    opt.EvalDataLik = 0;
end

% Process likelihood function options and create a likstruct.
if opt.EvalDataLik>0
    if strncmpi(opt.Domain, 't', 1)
        likOpt = prepareKalmanOptions2(this, range, opt.Filter{:});
        likOpt.minusLogLikFunc = @implementKalmanFilter;
    else
        likOpt = prepareFreqlOptions(this, range, opt.Filter{:});
        likOpt.minusLogLikFunc = @freql;
    end
else
    likOpt = struct();
end
opt = rmfield(opt, 'Filter');

% Get first column of measurement and exogenous variables.
if opt.EvalDataLik>0
    % `Data` includes pre-sample.
    req = [opt.Domain(1), 'yg*'];
    inputArray = datarequest(req, this, inputDatabank, range, 1);
else
    inputArray = [ ];
end

%--------------------------------------------------------------------------

% Warning if there are no measurement variables in the model and data
% likelihood is to be evaluated
if opt.EvalDataLik>0 && ~any(this.Quantity.Type==1);
    throw( exception.Base('Model:NoMeasurementVariables', 'warning') );
end

%
% Prepare Posterior object, model.Update, and EstimationWrapper
%
[this, posterior] = preparePosteriorAndUpdate(this, estimationSpecs, opt);
posterior.ObjectiveFunction = @(x) objfunc(x, this, inputArray, posterior, opt, likOpt);
posterior.SystemPriors = pp.Results.SystemPriors;
posterior.HonorBounds = opt.HonorBounds;
posterior.EvalDataLik = opt.EvalDataLik;
posterior.EvalIndiePriors = opt.EvalIndiePriors;
posterior.EvalSystemPriors = opt.EvalSystemPriors;
if isa(posterior.SystemPriors, 'SystemPriorWrapper')
    seal(SystemPriorWrapper);
end
estimationWrapper = EstimationWrapper( );
estimationWrapper.IsConstrained = posterior.IsConstrained;
chooseSolver(estimationWrapper, opt.Solver, outsideOptimOptions.Options);


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
p = hereCreateLegacyPoster( );

%
% Re-run Loglik for Out-of-lik Params
%
% Re-run the Kalman filter or FD likelihood to get the estimates of V
% and out-of-lik parameters.
V = 1;
delta = [ ];
PDelta = [ ];
if opt.EvalDataLik>0 && (nargout>=5 || likOpt.Relative)
    argin = struct( ...
        'InputData', inputArray, ...
        'OutputData', [ ], ...
        'OutputDataAssignFunc', [ ], ...
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
    summary = cell2struct(num2cell(posterior.Optimum(:)'), posterior.ParameterNames, 2);
else
    summary = table(posterior);
end
proposalCov = posterior.ProposalCov;

hessian = posterior.Hessian;

this.Update = this.EMPTY_UPDATE;

return

    function p = hereCreateLegacyPoster( )

        p = poster( );

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

function locallyValidateEval(x)
    try
        x = double(x);
    end
    if isnumeric(x) && isscalar(x) && x>=0
        return
    end
    error("Input value must be a non-negative scalar.");
end%

