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

