classdef (CaseInsensitiveProperties=true) Options
    properties
        Algorithm
        Display
        DisplayLevel = solver.DisplayLevel.empty(0)

        Reset


        % __Convergence options__

        FunctionNorm
        MaxIterations (1, 1) double
        MaxFunctionEvaluations (1, 1)
        FunctionTolerance (1, 1)
        StepTolerance (1, 1)

        % TrimObjectiveFunction  Trim values of objective function smaller than tolerance to zero
        TrimObjectiveFunction


        % __Jacobian and step improvement options__

        MinLambda (1, 1) double
        MaxLambda (1, 1) double
        LambdaMultiplier (1, 1) double

        % IncludeNewton  Include lambda=0 (pure Newton) in QNSD
        IncludeNewton (1, 1) logical = true

        InflateStep (1, 1)
        DeflateStep (1, 1)


        % __Bounds__

        Bounds double = [ ]


        % __Jacobian options__

        JacobPattern (:, :) logical = logical.empty(0)
        JacobCalculation (1, 1) string
        LastJacobUpdate (1, 1) double = Inf
        SkipJacobUpdate (1, 1) double { mustBeNonnegative } = 0
        FiniteDifferenceStepSize (1, 1) double
        FiniteDifferenceType
        PseudoinvWhenSingular
        ForceJacobUpdateWhenReversing
        LastBroydenUpdate


        % __Legacy QaD options__

        LastStepSizeOptim
        InitStepSize
        StepSizeSwitch
    end


    properties (Dependent)
        SolverName
    end


    properties (Hidden)
        DEFAULT_DISPLAY = 'iter*'
        DEFAULT_RESET = true

        % Convergence options
        DEFAULT_FUNCTION_NORM = 2
        DEFAULT_MAX_ITERATIONS = 5000
        DEFAULT_MAX_FUNCTION_EVALUATIONS = @(inp) 200*inp.NumUnknowns
        DEFAULT_FUNCTION_TOLERANCE = iris.mixin.Tolerance.DEFAULT_STEADY
        DEFAULT_STEP_TOLERANCE = iris.mixin.Tolerance.DEFAULT_STEADY
        DEFAULT_TRIM_OBJECTIVE_FUNCTION = false

        % Hybrid step lambda
        DEFAULT_MIN_LAMBDA = 1 % 1e-2
        DEFAULT_MAX_LAMBDA = 1e6
        DEFAULT_LAMBDA_MULTIPLIER = 100
        DEFAULT_INCLUDE_NEWTON = true

        % Step improvement options
        DEFAULT_INFLATE_STEP = 1.2
        DEFAULT_DEFLATE_STEP = 0.8

        % Jacobian options
        DEFAULT_JACOB_CALCULATION = "Analytical"
        DEFAULT_SPECIFY_OBJECTIVE_GRADIENT = false
        DEFAULT_LAST_JACOB_UPDATE = Inf
        DEFAULT_SKIP_JACOB_UPDATE = 0
        DEFAULT_FINITE_DIFFERENCE_STEP_SIZE = eps( )^(1/3)
        DEFAULT_FINITE_DIFFERENCE_TYPE = 'forward'
        DEFAULT_FORCE_JACOB_UPDATE_WHEN_REVERSING = true
        DEFAULT_LAST_BROYDEN_UPDATE = -1
        DEFAULT_PSEUDOINV_WHEN_SINGULAR = false

        % Step size options
        DEFAULT_INIT_STEP_SIZE = 1
        DEFAULT_LAST_STEP_SIZE_OPTIM = 0
        DEFAULT_STEP_SIZE_SWITCH = 0
    end




    methods
        function this = Options(solverName, varargin)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('solver.Options');
                pp.KeepUnmatched = true;
                pp.PartialMatching = false; % Possible conflict of Display and DisplayMode
                pp.addRequired('SolverName', @(x) (ischar(x) || (iscell(x) && ~isempty(x) && ischar(x{1})) || isa(x, 'string')) && locallyValidateIrisSolver(x));
                addParameter(pp, 'DisplayMode', 'Verbose', @(x) any(strcmpi(x, {'Verbose', 'Silent'})));
            end

            if nargin==0
                return
            end

            pp.parse(solverName, varargin{:});
            varargin = pp.UnmatchedInCell;

            if locallyValidateSolver(solverName, {'IRIS-QaD', 'QaD'})
                % Legacy QaD
                this.Algorithm = 'QaD';
                this.DEFAULT_DISPLAY = 100;
                this.DEFAULT_FUNCTION_NORM = Inf;
                this.DEFAULT_FUNCTION_TOLERANCE = 1e-5;
                this.DEFAULT_TRIM_OBJECTIVE_FUNCTION = true;
                this.DEFAULT_MAX_ITERATIONS = 500;
                this.DEFAULT_STEP_TOLERANCE = Inf;
                this.DEFAULT_MAX_LAMBDA = 0;
                this.DEFAULT_LAST_JACOB_UPDATE = -1;
                this.DEFAULT_PSEUDOINV_WHEN_SINGULAR = true;
                this.DEFAULT_LAST_STEP_SIZE_OPTIM = 1;
                this.DEFAULT_STEP_SIZE_SWITCH = 1;
                this.DEFAULT_INFLATE_STEP = false;
                this.DEFAULT_DEFLATE_STEP = false;
                this.DEFAULT_FORCE_JACOB_UPDATE_WHEN_REVERSING = false;
            elseif locallyValidateSolver(solverName, {'Iris-Qnsdx', 'Qnsdx'})
                this.DEFAULT_INCLUDE_NEWTON = false;
            elseif locallyValidateSolver(solverName, {'Iris-QuickNewton', 'QuickNewton'})
                % Newton (Lambda=0, higher tolerance, Inf norm)
                this.Algorithm = 'Newton';
                this.DEFAULT_FUNCTION_NORM = Inf;
                this.DEFAULT_MAX_LAMBDA = 0;
                this.DEFAULT_FUNCTION_TOLERANCE = 1e-5;
                this.DEFAULT_STEP_TOLERANCE = Inf;
                this.DEFAULT_SKIP_JACOB_UPDATE = 2;
            elseif locallyValidateSolver(solverName, {'IRIS-Newton', 'Newton'})
                % Newton (Lambda=0)
                this.Algorithm = 'Newton';
                this.DEFAULT_MAX_LAMBDA = 0;
            else
                % Quasi Newton-steepest descent
                this.Algorithm = 'Qnsd';
                this.DEFAULT_PSEUDOINV_WHEN_SINGULAR = true;
            end

            optionsParser = getParser(this);
            opt = parse(optionsParser, varargin{:});

            list = fieldnames(opt);
            for n = textual.stringify(list)
                this.(n) = opt.(n);
            end

            this.Display = resolveDisplayMode(this.Display, pp.Results.DisplayMode);
        end%


        function pp = getParser(this)
            %(
            isnumericscalar = @(x) isnumeric(x) && isscalar(x);
            pp = extend.InputParser('solver.Options.getParser');
            pp.KeepUnmatched = true;
            addParameter(pp, 'Display', this.DEFAULT_DISPLAY, @validateDisplay);
            addParameter(pp, 'Reset', this.DEFAULT_RESET, @(x) isequal(x, true) || isequal(x, false));
            addParameter(pp, 'MinLambda', this.DEFAULT_MIN_LAMBDA);
            addParameter(pp, 'MaxLambda', this.DEFAULT_MAX_LAMBDA);
            addParameter(pp, 'LambdaMultiplier', this.DEFAULT_LAMBDA_MULTIPLIER);
            addParameter(pp, 'IncludeNewton', this.DEFAULT_INCLUDE_NEWTON);
            addParameter(pp, 'JacobPattern', logical.empty(0), @islogical);
            addParameter(pp, 'JacobCalculation', this.DEFAULT_JACOB_CALCULATION, @(x) startsWith(x, ["Analytical", "ForwardDiff"], "ignoreCase", true));
            addParameter(pp, 'LastJacobUpdate', this.DEFAULT_LAST_JACOB_UPDATE);
            addParameter(pp, "SkipJacobUpdate", this.DEFAULT_SKIP_JACOB_UPDATE);
            addParameter(pp, {'MaxIterations', 'MaxIter'}, this.DEFAULT_MAX_ITERATIONS, @(x) isequal(x, @auto) || (isnumericscalar(x) || round(x)==x || x>0));
            addParameter(pp, {'MaxFunctionEvaluations', 'MaxFunEvals'}, this.DEFAULT_MAX_FUNCTION_EVALUATIONS, @(x) isequal(x, @auto) || isa(x, 'function_handle') || (isnumericscalar(x) && round(x)==x && x>0));
            addParameter(pp, 'TrimObjectiveFunction', this.DEFAULT_TRIM_OBJECTIVE_FUNCTION, @(x) isequal(x, true) || isequal(x, false));
            addParameter(pp, 'FiniteDifferenceStepSize', this.DEFAULT_FINITE_DIFFERENCE_STEP_SIZE, @(x) isequal(x, @auto) || (isnumericscalar(x) && x>0));
            addParameter(pp, 'FiniteDifferenceType', this.DEFAULT_FINITE_DIFFERENCE_TYPE, @(x) any(strcmpi(x, {'forward', 'central'})));
            addParameter(pp, 'PseudoinvWhenSingular', this.DEFAULT_PSEUDOINV_WHEN_SINGULAR, @validate.logicalScalar);
            addParameter(pp, 'ForceJacobUpdateWhenReversing', this.DEFAULT_FORCE_JACOB_UPDATE_WHEN_REVERSING, @validate.logicalScalar);
            addParameter(pp, 'LastBroydenUpdate', this.DEFAULT_LAST_BROYDEN_UPDATE, @validate.numericScalar);
            addParameter(pp, 'FunctionNorm', this.DEFAULT_FUNCTION_NORM, @(x) isequal(x, @auto) || validate.numericScalar(x, 0, Inf) || isa(x, 'function_handle'));
            addParameter(pp, {'FunctionTolerance', 'TolFun', 'Tolerance'}, this.DEFAULT_FUNCTION_TOLERANCE, @(x) isnumeric(x) && isscalar(x) && x>0);
            addParameter(pp, {'StepTolerance', 'TolX'}, this.DEFAULT_STEP_TOLERANCE, @(x) isnumeric(x) && isscalar(x) && x>0);

            addParameter(pp, {'DeflateStep', 'StepDown'}, this.DEFAULT_DEFLATE_STEP, @(x) isequal(x, @auto) || isequal(x, false) || (isnumericscalar(x) && x>0 && x<1));
            addParameter(pp, {'InflateStep', 'StepUp'}, this.DEFAULT_INFLATE_STEP, @(x) isequal(x, @auto) || isequal(x, false) || (isnumericscalar(x) && x>1));

            addParameter(pp, 'LastStepSizeOptim', this.DEFAULT_LAST_STEP_SIZE_OPTIM, @(x) isnumeric(x) && isscalar(x) && x>=0);
            addParameter(pp, 'InitStepSize', this.DEFAULT_INIT_STEP_SIZE, @(x) isnumeric(x) && isscalar(x) && x>0 && x<=2);
            addParameter(pp, 'StepSizeSwitch', this.DEFAULT_STEP_SIZE_SWITCH, @(x) isequal(x, 0) || isequal(x, 1));
            %)
        end%


        function value = get.SolverName(this)
            value = sprintf('IRIS-%s', lower(this.Algorithm));
        end%
    end


    methods (Static)
        function solverOpt = parseOptions(solverOpt, defaultSolver, silent, varargin)

            if silent
                displayMode = "silent";
            else
                displayMode = "verbose";
            end

            % Resolve solverOpt=@auto or solverOpt = { @auto, ... }
            solverOpt = resolveAutoSolverOption(solverOpt, defaultSolver);

            if isa(solverOpt, 'optim.options.SolverOptions') || ...
               isa(solverOpt, 'solver.Options')
                % Options object already prepared
                % Solver= optimoptions( )
                % Solver= solver.Options( )
                % Do nothing

            elseif locallyValidateSolver(solverOpt, {'lsqnonlin', 'fsolve'})
                % Optim Tbx
                solverOpt = parseOptimTbx(solverOpt, displayMode, varargin{:});

            elseif locallyValidateIrisSolver(solverOpt)
                % IrisT Solver
                if iscell(solverOpt)
                    solverName = char(solverOpt{1});
                    userOpt = [varargin, solverOpt(2:end)];
                else
                    solverName = char(solverOpt);
                    userOpt = varargin;
                end
                solverOpt = solver.Options( ...
                    solverName, ...
                    "displayMode", displayMode, ...
                    userOpt{:} ...
                );

            else
                % Solver= @userFunction
                % Do nothing
            end

            %
            % Create DisplayLevel object setting the various levels of
            % display to true or false
            %
            if isa(solverOpt, 'solver.Options')
                solverOpt.DisplayLevel = solver.DisplayLevel(solverOpt.Display);
            end
        end%
    end
end


%
% Local functions
%


function solverOpt = parseOptimTbx(solverOpt, displayMode, varargin)
    isnumericscalar = @(x) isnumeric(x) && isscalar(x);
    persistent pp
    if isempty(pp)
        pp = extend.InputParser('solver.Options.parseOptimTbx');
        addParameter(pp, 'Algorithm', 'levenberg-marquardt', @ischar);
        addParameter(pp, 'Display', 'iter*', @validateDisplay);
        addParameter(pp, {'MaxIterations', 'MaxIter'}, @auto, @(x) isequal(x, @auto) || (isnumericscalar(x) || round(x)==x || x>0));
        addParameter(pp, {'MaxFunctionEvaluations', 'MaxFunEvals'}, @auto, @(x) isequal(x, @auto) || isa(x, 'function_handle') || (isnumericscalar(x) && round(x)==x && x>0));
        addParameter(pp, 'FiniteDifferenceStepSize', @auto, @(x) isequal(x, @auto) || (isnumericscalar(x) && x>0));
        addParameter(pp, 'FiniteDifferenceType', 'forward', @(x) any(strcmpi(x, {'finite', 'central'})));
        addParameter(pp, {'FunctionTolerance', 'TolFun', 'Tolerance'}, iris.mixin.Tolerance.DEFAULT_STEADY, @(x) isnumericscalar(x) && x>0);
        addParameter(pp, {'StepTolerance', 'TolX'}, iris.mixin.Tolerance.DEFAULT_STEADY, @(x) isnumericscalar(x) && x>0);
    end

    if iscell(solverOpt)
        % Solver= {solverName, 'Name', Value, ... }
        % where solverName is 'lsqnonlin' | 'fsolve'
        parse(pp, solverOpt{2:end});
        solverOpt = optimoptions(solverOpt{1});
    else
        % Solver= 'lsqnonlin' | 'fsolve'
        parse(pp, varargin{:});
        solverOpt = optimoptions(solverOpt);
    end

    userOpt = pp.Options;
    if isequal(userOpt.Display, @auto)
        userOpt.Display = 'iter*';
    elseif isequal(userOpt.Display, true)
        userOpt.Display = 'iter';
    elseif isequal(userOpt.Display, false)
        userOpt.Display = 'off';
    end
    userOpt.Display = resolveDisplayMode(userOpt.Display, displayMode);

    list = fieldnames(userOpt);
    for i = 1 : numel(list)
        name = list{i};
        if isequal(userOpt.(name), @auto)
            continue
        end
        try
            solverOpt = optimoptions(solverOpt, name, userOpt.(name));
        end
    end
end%




function solverOpt = resolveAutoSolverOption(solverOpt, defaultSolver)
    if isequal(solverOpt, @auto)
        solverOpt = { defaultSolver };
    elseif iscell(solverOpt) && ~isempty(solverOpt) && isequal(solverOpt{1}, @auto)
        solverOpt(1) = { defaultSolver };
    end
end%


function display = resolveDisplayMode(display, displayMode)
    if strcmpi(display, 'iter*')
        if strcmpi(displayMode, 'Silent')
            display = 'off';
        else
            display = 'iter';
        end
    end
end%

%
% Local Validators
%

function flag = validateDisplay(x)
    flag = isequal(x, @auto) ...
           || isequal(x, true) || isequal(x, false) ...
           || (isnumeric(x) && isscalar(x) && x==round(x) && x>=0) ...
           || any(strcmpi(x, {'on', 'iter*', 'iter', 'final', 'none', 'notify', 'off'}));
end%


function flag = locallyValidateSolver(x, choice)
    checkFunc = @(x) (ischar(x) || isstring(x) || isa(x, 'function_handle')) && any(strcmpi(char(x), choice));
    flag = checkFunc(x) || (iscell(x) && ~isempty(x) && checkFunc(x{1}) && validate.nestedOptions(x(2:2:end)));
end%


function flag = locallyValidateIrisSolver(x)
   flag = locallyValidateSolver(x, {'Iris', 'Iris-Qnsd', 'Iris-Qnsdx', 'Iris-Newton', 'Iris-QuickNewton', 'Iris-QaD', 'QaD', 'Newton', 'QuickNewton', 'Qnsd', 'Qnsdx'});
end%

