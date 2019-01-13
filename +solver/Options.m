classdef (CaseInsensitiveProperties=true) Options
    properties
        Algorithm
        Display

        % Convergence Options
        FunctionNorm
        MaxIterations
        MaxFunctionEvaluations
        FunctionTolerance
        StepTolerance
        
        % TrimObjectiveFunction  Trim values of objective function smaller than tolerance to zero
        TrimObjectiveFunction

        % Step Improvement Options
        Lambda
        InflateStep
        DeflateStep

        % Jacobian Options
        SpecifyObjectiveGradient
        LargeScale
        JacobPattern 
        LastJacobUpdate
        FiniteDifferenceStepSize
        FiniteDifferenceType

        % QaD Options
        LastStepSizeOptim 
        InitStepSize
        StepSizeSwitch 
    end




    properties (Dependent)
        SolverName
    end




    properties %(Hidden)
        DEFAULT_DISPLAY = 'iter*'

        % Convergence Options
        DEFAULT_FUNCTION_NORM = 2
        DEFAULT_MAX_ITERATIONS = 5000
        DEFAULT_MAX_FUNCTION_EVALUATIONS = @(inp) 200*inp.NumberOfVariables
        DEFAULT_FUNCTION_TOLERANCE = model.DEFAULT_STEADY_TOLERANCE
        DEFAULT_STEP_TOLERANCE = model.DEFAULT_STEADY_TOLERANCE
        DEFAULT_TRIM_OBJECTIVE_FUNCTION = false

        % Step Improvement Options
        DEFAULT_LAMBDA = [0.1, 1, 10, 100]
        DEFAULT_INFLATE_STEP = 1.2
        DEFAULT_DEFLATE_STEP = 0.8

        % Jacobian Options
        DEFAULT_SPECIFY_OBJECTIVE_GRADIENT = false
        DEFAULT_LARGE_SCALE = false
        DEFAULT_JACOB_PATTERN = logical.empty(0)
        DEFAULT_LAST_JACOB_UPDATE = Inf
        DEFAULT_FINITE_DIFFERENCE_STEP_SIZE = eps( )^(1/3)
        DEFAULT_FINITE_DIFFERENCE_TYPE = 'forward'

        % QaD Options
        DEFAULT_INIT_STEP_SIZE = 1
        DEFAULT_LAST_STEP_SIZE_OPTIM = 0
        DEFAULT_STEP_SIZE_SWITCH = 0
    end




    methods
        function this = Options(solverName, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('solver.Options');
                parser.KeepUnmatched = true;
                parser.PartialMatching = false; % Possible conflict of Display and DisplayMode
                parser.addRequired('SolverName', @(x) (ischar(x) || (iscell(x) && ~isempty(x) && ischar(x{1})) || isa(x, 'string')) && validateIRISSolver(x));
                parser.addParameter('Context', '', @(x) isempty(x) || ischar(x) || isa(x, 'string'));
                parser.addParameter('DisplayMode', 'Verbose', @(x) any(strcmpi(x, {'Verbose', 'Silent'})));
            end

            if nargin==0
                return
            end

            parser.parse(solverName, varargin{:});
            varargin = parser.UnmatchedInCell;

            if validateSolver(solverName, {'IRIS-qad', 'qad'})
                % QaD
                this.Algorithm = 'QaD';
                this.DEFAULT_DISPLAY = 100;
                this.DEFAULT_FUNCTION_NORM = Inf;
                this.DEFAULT_FUNCTION_TOLERANCE = 1e-5;
                this.DEFAULT_TRIM_OBJECTIVE_FUNCTION = true;
                this.DEFAULT_MAX_ITERATIONS = 100;
                this.DEFAULT_STEP_TOLERANCE = Inf; 1e-5;
                this.DEFAULT_LAMBDA = double.empty(1, 0);
                this.DEFAULT_LAST_JACOB_UPDATE = -1;
                this.DEFAULT_LAST_STEP_SIZE_OPTIM = 1;
                this.DEFAULT_STEP_SIZE_SWITCH = 1;
                this.DEFAULT_INFLATE_STEP = false;
                this.DEFAULT_DEFLATE_STEP = false;
            elseif validateSolver(solverName, {'IRIS-newton'})
                % Newton (Lambda=0)
                this.Algorithm = 'Newton';
                this.DEFAULT_LAMBDA = double.empty(1, 0);
            else
                % Quasi Newton-steepest descend
                this.Algorithm = 'Qnsd';
                if strcmpi(parser.Results.Context, 'Steady')
                    this.DEFAULT_SPECIFY_OBJECTIVE_GRADIENT = true;
                end
            end

            optionsParser = getParser(this);
            parse(optionsParser, varargin{:});
            opt = optionsParser.Options;

            list = fieldnames(opt);
            for i = 1 : numel(list)
                this.( list{i} ) = opt.( list{i} );
            end

            % Legacy option name Lambda for InitStepSize in QaD solver
            if strcmpi(this.Algorithm, 'QaD')
                if ~any(strcmpi(optionsParser.UsingDefaults, 'Lambda'))
                    %##### Obsolete since Sep 2018
                    warning( 'IRIS:Obsolete', ...
                             [ 'The option name Lambda= is obsolete in the IRIS-QaD solver, ', ...
                               'and the use of the name will be disallowed in a future version. ', ...
                               'Use the option InitStepSize= instead.' ] );
                    this.InitStepSize = optionsParser.Results.Lambda;
                    this.Lambda = this.DEFAULT_LAMBDA;
                end
            end

            this.Display = resolveDisplayMode(this.Display, parser.Results.DisplayMode);
        end%
            



        function parser = getParser(this)
            parser = extend.InputParser('solver.Options.getParser');
            parser.KeepUnmatched = true;
            parser.addParameter('Display', this.DEFAULT_DISPLAY, @validateDisplay);
            parser.addParameter('JacobPattern', this.DEFAULT_JACOB_PATTERN, @(x) isempty(x) || (islogical(x) && issparse(x)) );
            parser.addParameter('Lambda', this.DEFAULT_LAMBDA, @(x) isequal(x, @default) || (isnumeric(x) && all(x>0) && all(isreal(x))));
            parser.addParameter('LastJacobUpdate', this.DEFAULT_LAST_JACOB_UPDATE, @(x) isnumeric(x) && isscalar(x));
            parser.addParameter('LargeScale', this.DEFAULT_LARGE_SCALE, @(x) isequal(x, @default) || isequal(x, true) || isequal(x, false));
            parser.addParameter({'MaxIterations', 'MaxIter'}, this.DEFAULT_MAX_ITERATIONS, @(x) isequal(x, @default) || (isnumericscalar(x) || round(x)==x || x>0));
            parser.addParameter({'MaxFunctionEvaluations', 'MaxFunEvals'}, this.DEFAULT_MAX_FUNCTION_EVALUATIONS, @(x) isequal(x, @default) || isa(x, 'function_handle') || (isnumericscalar(x) && round(x)==x && x>0));
            parser.addParameter('TrimObjectiveFunction', this.DEFAULT_TRIM_OBJECTIVE_FUNCTION, @(x) isequal(x, true) || isequal(x, false));
            parser.addParameter('FiniteDifferenceStepSize', this.DEFAULT_FINITE_DIFFERENCE_STEP_SIZE, @(x) isequal(x, @default) || (isnumericscalar(x) && x>0));
            parser.addParameter('FiniteDifferenceType', this.DEFAULT_FINITE_DIFFERENCE_TYPE, @(x) any(strcmpi(x, {'forward', 'central'})));
            parser.addParameter('FunctionNorm', this.DEFAULT_FUNCTION_NORM, @(x) isequal(x, @default) || isequal(x, 1) || isequal(x, 2) || isequal(x, Inf) || isa(x, 'function_handle'));
            parser.addParameter({'FunctionTolerance', 'TolFun', 'Tolerance'}, this.DEFAULT_FUNCTION_TOLERANCE, @(x) isnumeric(x) && isscalar(x) && x>0);
            parser.addParameter({'StepTolerance', 'TolX'}, this.DEFAULT_STEP_TOLERANCE, @(x) isnumeric(x) && isscalar(x) && x>0);
            parser.addParameter('SpecifyObjectiveGradient', this.DEFAULT_SPECIFY_OBJECTIVE_GRADIENT, @(x) isequal(x, true) || isequal(x, false));

            parser.addParameter({'DeflateStep', 'StepDown'}, this.DEFAULT_DEFLATE_STEP, @(x) isequal(x, @default) || isequal(x, false) || (isnumericscalar(x) && x>0 && x<1));
            parser.addParameter({'InflateStep', 'StepUp'}, this.DEFAULT_INFLATE_STEP, @(x) isequal(x, @default) || isequal(x, false) || (isnumericscalar(x) && x>1));

            parser.addParameter('LastStepSizeOptim', this.DEFAULT_LAST_STEP_SIZE_OPTIM, @(x) isnumeric(x) && isscalar(x) && x>=0);
            parser.addParameter('InitStepSize', this.DEFAULT_INIT_STEP_SIZE, @(x) isnumeric(x) && isscalar(x) && x>0 && x<=2);
            parser.addParameter('StepSizeSwitch', this.DEFAULT_STEP_SIZE_SWITCH, @(x) isequal(x, 0) || isequal(x, 1));
        end%




        function value = get.SolverName(this)
            value = sprintf('IRIS-%s', lower(this.Algorithm));
        end%
    end
    


    
    methods (Static)
        function [solverOpt, prepareGradient] = parseOptions( solverOpt, ...
                                                              context, ...
                                                              prepareGradient, ...
                                                              displayMode, ...
                                                              varargin )

            % Resolve solverOpt=@auto depending on context
            if isequal(solverOpt, @auto)
                solverOpt = resolveAutoSolver(solverOpt, context);
            end
            
            if isa(solverOpt, 'optim.options.SolverOptions') || ...
               isa(solverOpt, 'solver.Options')
                % Options object already prepared
                % Solver= optimoptions( )
                % Solver= solver.Options( )
                % Do nothing

            elseif validateSolver(solverOpt, {'lsqnonlin', 'fsolve'});
                % Optim Tbx
                solverOpt = parseOptimTbx(solverOpt, context, displayMode, varargin{:});                

            elseif validateIRISSolver(solverOpt)
                % IRIS Solver
                if iscell(solverOpt)
                    solverName = char(solverOpt{1});
                    userOpt = [varargin, solverOpt(2:end)];
                else
                    solverName = char(solverOpt);
                    userOpt = varargin;
                end
                solverOpt = solver.Options( solverName, ...
                                            'Context=', context, ...
                                            'DisplayMode=', displayMode, ...
                                            userOpt{:} );
                
            else
                % Solver= @userFunction
                % Do nothing
            end

            % Resolve prepareGradient=@auto
            prepareGradient = resolvePrepareGradient(prepareGradient, solverOpt);
        end%
    end
end
            

%
% Local functions
%


function solverOpt = resolveAutoSolver(solverOpt, context)
    if strcmpi(context, 'Steady')
        solverOpt = 'IRIS-qnsd';
    elseif strcmpi(context, 'Exact')
        solverOpt = 'IRIS-qnsd';
    elseif strcmpi(context, 'Stacked')
        solverOpt = 'IRIS-newton';
    elseif strcmpi(context, 'Selective')
        solverOpt = 'IRIS-qad';
    else
        solverOpt = 'IRIS-qnsd';
    end
end%




function solverOpt = parseOptimTbx(solverOpt, context, displayMode, varargin)
    persistent parser
    if isempty(parser)
        parser = extend.InputParser('solver.Options.parseOptimTbx');
        parser.addParameter('Algorithm', 'levenberg-marquardt', @ischar);
        parser.addParameter('Display', 'iter*', @validateDisplay);
        parser.addParameter('JacobPattern', logical.empty(0), @(x) isempty(x) || (islogical(x) && issparse(x)));
        parser.addParameter({'MaxIterations', 'MaxIter'}, @default, @(x) isequal(x, @default) || (isnumericscalar(x) || round(x)==x || x>0));
        parser.addParameter({'MaxFunctionEvaluations', 'MaxFunEvals'}, @default, @(x) isequal(x, @default) || isa(x, 'function_handle') || (isnumericscalar(x) && round(x)==x && x>0));
        parser.addParameter('FiniteDifferenceStepSize', @default, @(x) isequal(x, @default) || (isnumericscalar(x) && x>0));
        parser.addParameter('FiniteDifferenceType', 'forward', @(x) any(strcmpi(x, {'finite', 'central'})));
        parser.addParameter({'FunctionTolerance', 'TolFun', 'Tolerance'}, model.DEFAULT_STEADY_TOLERANCE, @(x) isnumericscalar(x) && x>0);
        parser.addParameter('SpecifyObjectiveGradient', @default, @(x) isequal(x, @default) || isequal(x, true) || isequal(x, false));
        parser.addParameter({'StepTolerance', 'TolX'}, model.DEFAULT_STEADY_TOLERANCE, @(x) isnumericscalar(x) && x>0);
    end
        
    if iscell(solverOpt)
        % Solver= {solverName, 'Name=', Value, ... }
        % where solverName is 'lsqnonlin' | 'fsolve'
        parse(parser, solverOpt{2:end});
        solverOpt = optimoptions(solverOpt{1});
    else
        % Solver= 'lsqnonlin' | 'fsolve'
        parse(parser, varargin{:});
        solverOpt = optimoptions(solverOpt);
    end

    userOpt = parser.Options;
    if isequal(userOpt.SpecifyObjectiveGradient, @default)
        if any(strcmpi(context, {'Selective', 'Stacked'}))
            userOpt.SpecifyObjectiveGradient = false;
        else
            userOpt.SpecifyObjectiveGradient = true;
        end
    end
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
        if isequal(userOpt.(name), @default)
            continue
        end
        try
            solverOpt = optimoptions(solverOpt, name, userOpt.(name));
        end
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




function prepareGradient = resolvePrepareGradient(prepareGradient, solverOpt)
    if isequal(prepareGradient, @auto)
        try
            prepareGradient = solverOpt.SpecifyObjectiveGradient;
        catch
            prepareGradient = false;
        end
    end
end%


%
% Validators
%


function flag = validateDisplay(x)
    flag = isequal(x, @auto) || isequal(x, @default) ...
           || isequal(x, true) || isequal(x, false) ...
           || (isnumeric(x) && isscalar(x) && x==round(x) && x>=0) ...
           || any(strcmpi(x, {'on', 'iter*', 'iter', 'final', 'none', 'notify', 'off'}));
end%




function flag = validateSolver(x, choice)
    checkFunc = @(x) (ischar(x) || isa(x, 'string') || isa(x, 'function_handle')) && any(strcmpi(char(x), choice));
    flag = checkFunc(x) || (iscell(x) && ~isempty(x) && checkFunc(x{1}) && iscellstr(x(2:2:end)));
end%




function flag = validateIRISSolver(x)
   flag = validateSolver(x, {'IRIS', 'IRIS-qnsd', 'IRIS-newton', 'IRIS-qad', 'qad'}); 
end%

