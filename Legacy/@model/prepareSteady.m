% prepareSteady  Prepare steady solver
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function output = prepareSteady(this, varargin)
    % function output = prepareSteady(this, options)
    %
    % arguments
        % this
    %
        % options.Warning (1, 1) logical = true
        % options.Silent (1, 1) logical = false
        % options.Run (1, 1) logical = true
    %
        % options.Growth (1, :) logical {validate.mustBeScalarOrEmpty} = []
        % options.Solve (1, :) {validate.mustBeLogicalOrSuboptions} = {"run", false}
    %
        % options.LevelWithin (1, 1) struct = struct()
        % options.ChangeWithin (1, 1) struct = struct()
        %
    % end

    %( Input parser
    persistent parserLinear parserNonlinear
    if isempty(parserLinear) || isempty(parserNonlinear)

        % Linear
        parserLinear = extend.InputParser();
        addParameter(parserLinear, 'Growth', [], @(x) isempty(x) || isequal(x, true) || isequal(x, false));
        addParameter(parserLinear, 'Warning', true, @(x) isequal(x, true) || isequal(x, false));
        addParameter(parserLinear, "Silent", false);
        addParameter(parserLinear, "Run", true);
        addParameter(parserLinear, "UserFunc", []);
        addParameter(parserLinear, 'Solve', {"run", false});

        % Nonlinear
        parserNonlinear = extend.InputParser();
        parserNonlinear.KeepUnmatched = true;

        addParameter(parserNonlinear, {'ChangeWithin', 'ChangeBounds', 'GrowthBounds', 'GrowthBnds'}, [ ], @(x) isempty(x) || isstruct(x));
        addParameter(parserNonlinear, {'LevelWithin', 'LevelBounds', 'LevelBnds'}, [ ], @(x) isempty(x) || isstruct(x));
        addParameter(parserNonlinear, 'OptimSet', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x));
        addParameter(parserNonlinear, {'NanInit', 'Init'}, 1, @(x) isnumeric(x) && isscalar(x) && isfinite(x));
        addParameter(parserNonlinear, 'ResetInit', [ ], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && isfinite(x)));
        addParameter(parserNonlinear, {'PreviousVariant', 'Reuse'}, false, @(x) isequal(x, true) || isequal(x, false));
        addParameter(parserNonlinear, {'SolverOptions', 'Solver'}, @auto, @(x) isequal(x, @auto) || isa(x, 'solver.Options') || isa(x, 'optim.options.SolverOptions') || isstring(x) || ischar(x) || isa(x, 'function_handle') || (iscell(x) && all(cellfun(@(y) isstring(y) ||  ischar(y), x(2:2:end))) && (isstring(x{1}) || ischar(x{1}) || isa(x{1}, 'function_handle'))));
        addParameter(parserNonlinear, 'Warning', true, @(x) isequal(x, true) || isequal(x, false));
        addParameter(parserNonlinear, 'ZeroMultipliers', true, @(x) isequal(x, true) || isequal(x, false));
        addParameter(parserNonlinear, "Silent", false);
        addParameter(parserNonlinear, "Run", true);
        addParameter(parserNonlinear, "UserFunc", []);
        % addParameter(parserNonlinear, "CheckSteady", {"Run", false});

        % Blazer related options
        addParameter(parserNonlinear, {'Blocks', 'Block'}, @auto, @local_validateBlocks);
        addParameter(parserNonlinear, "SuccessOnly", false, @validate.logicalScalar);
        addParameter(parserNonlinear, 'Growth', [], @(x) isempty(x) || validate.logicalScalar(x));
        addParameter(parserNonlinear, 'Log', string.empty(1, 0), @(x) isequal(x, @all) || validate.list(x));
        addParameter(parserNonlinear, 'Unlog', string.empty(1, 0), @(x) isequal(x, @all) || validate.list(x));
        addParameter(parserNonlinear, 'SaveAs', "", @(x) isempty(x) || ischar(x) || (isstring(x) && isscalar(x)));
        addSwapFixOptions(parserNonlinear);
    end
    %)

    %
    % Parse options depending on linear/nonlinear
    %
    if this.LinearStatus
        parser = parserLinear;
    else
        parser = parserNonlinear;
    end
    options = parse(parser, varargin{:});

    output = struct();
    output.Run = options.Run;
    output.Func = [];
    output.Arguments = {};

    if ~options.Run
        return
    end


    if isa(options.UserFunc, 'function_handle')
        %
        % __User supplied steady solver__
        %
        output.Func = @steadyUser;
        output.Arguments = {options.UserFunc};
        return
    end


    if this.LinearStatus
        %
        % __Linear steady solver__
        %
        if islogical(options.Solve)
            output.Solve = {"run", options.Solve};
        end
        options.Solve = prepareSolve(this, options.Solve{:});

        output.Func = @steadyLinear;
        output.Arguments = {options};
        return

    else
        %
        % __Nonlinear steady solver__
        %
        % Capture obsolete syntax with solver options directly passed among other
        % sstate options and not as suboptions through SolverOptions=; these are only used
        % if SolverOptions= is a string
        %
        if isempty(options.Growth)
            options.Growth = this.GrowthStatus;
        end

        if ~options.Growth && isempty(options.Fix) && isempty(options.FixLevel) && isempty(options.FixChange)
            defaultSolver = 'IRIS-Newton';
        else
            defaultSolver = 'IRIS-Qnsd';
        end

        options.SolverOptions = solver.Options.parseOptions( ...
            options.SolverOptions, ...
            defaultSolver, ...
            options.Silent ...
        );

        blazer = local_runBlazer(this, options);
        blazer = local_prepareBounds(this, blazer, options);
        blazer.NanInit = options.NanInit;
        blazer.PreviousVariant = options.PreviousVariant;
        blazer.Warning = options.Warning;
        % blazer.CheckSteady = options.CheckSteady;

        output.Func = @steadyNonlinear;
        output.Arguments = {blazer};
        return

    end

end%

%
% Local Functions
%

function blazer = local_runBlazer(this, opt)
    numQuants = numel(this.Quantity.Name);

    %
    % Look up shocks and parameters; steady change will be fixed for these
    % at zero no matter what
    %
    inxE = this.Quantity.Type==31 | this.Quantity.Type==32;
    inxP = this.Quantity.Type==4;

    %
    % Prepare solver.blazer.Blazer for steady equations, process Exogenize=,
    % Endogenize=, Fix...= options
    %
    blazer = solver.blazer.Steady.forModel(this, opt);


    %
    % Split equations into sequential blocks, prepare blocks, save blazer
    % to file if requested, and prepare solver options within the blocks
    %
    run(blazer);
    prepareForSolver(blazer, opt.SolverOptions);


    %
    % Prepare the index of the quantities that will be always set to zero:
    % these always include shocks and parameters
    %
    inxZero = struct();
    inxZero.Level = false(1, numQuants);
    inxZero.Level(inxE) = true;
    if opt.Growth
        inxZero.Change = false(1, numQuants);
        inxZero.Change(inxE | inxP) = true;
    else
        inxZero.Change = true(1, numQuants);
    end

    %
    % Add Lagrange multipliers from optimal policy models and comodels; add
    % conditioning shocks from comodels
    %
    inxZero = prepareZeroSteady(this, inxZero);

    blazer.InxZero = inxZero;
end%




function blazer = local_prepareBounds(this, blazer, opt)
    numQuants = numel(this.Quantity.Name);
    numBlocks = numel(blazer.Blocks);
    inxValidLevels = true(1, numQuants);
    inxValidChanges = true(1, numQuants);
    for i = 1 : numBlocks
        block__ = blazer.Blocks{i};
        if block__.Type~=solver.block.Type.SOLVE
            continue
        end

        % Steady level bounds
        [ptrLevel, ptrChange] = iris.utils.splitRealImag(block__.PtrQuantities);

        listLevel = this.Quantity.Name(ptrLevel);
        [lbl, ubl, inxValidLevels] = hereSetBounds( ...
            listLevel, ptrLevel, opt.LevelWithin, inxValidLevels ...
        );

        % Steady change bounds
        listChange = this.Quantity.Name(ptrChange);
        [lbg, ubg, inxValidChanges] = hereSetBounds( ...
            listChange, ptrChange, opt.ChangeWithin, inxValidChanges ...
        );

        % Combine level and growth bounds
        block__.Lower = [lbl, lbg];
        block__.Upper = [ubl, ubg];

        if isa(block__.SolverOptions, 'optim.options.SolverOptions')
            % Make sure @lsqnonlin is used when there are some lower/upper bounds.
            isBnd = any(~isinf(block__.Lower)) || any(~isinf(block__.Upper));
            if isBnd
                if ~strcmp(block__.SolverOptions.SolverName, 'lsqnonlin')
                    block__.SolverOptions = block__.SolverOptions('lsqnonlin', block__.SolverOptions);
                end
            end
        end

        blazer.Blocks{i} = block__;
    end

    if any(~inxValidLevels)
        throw(  ...
            exception.Base('Steady:WRONG_SIGN_LEVEL_BOUNDS', 'error'), ...
            this.Quantity.Name{~inxValidLevels} ...
        );
    end
    if any(~inxValidChanges)
        throw( ...
            exception.Base('Steady:WRONG_SIGN_GROWTH_BOUNDS', 'error'), ...
            this.Quantity.Name{~inxValidChanges} ...
        );
    end

    return


        function [lowerBounds, upperBounds, inxValid] = hereSetBounds(list, nameId, bounds, inxValid)
            %(
            numList = numel(list);
            lowerBounds = -inf(1, numList);
            upperBounds = inf(1, numList);
            for jj = 1 : numList
                name = list{jj};
                isLog = blazer.Model.Quantity.InxLog( nameId(jj) );
                try
                    lowerBound__ = double(bounds.(name)(1));
                catch
                    if isLog
                        lowerBound__ = 0;
                    else
                        lowerBound__ = -Inf;
                    end
                end
                try
                    upperBound__ = double(bounds.(name)(2));
                catch
                    upperBound__ = Inf;
                end
                if isLog
                    lowerBound__ = log(lowerBound__);
                    upperBound__ = log(upperBound__);
                end
                if imag(lowerBound__)==0 && imag(upperBound__)==0
                    % Assign only if both lower and upper bound is ok
                    lowerBounds(jj) = lowerBound__;
                    upperBounds(jj) = upperBound__;
                else
                    % Report problem for this variables
                    inxValid( nameId(jj) ) = false;
                end
            end
            %)
        end%
end%

%
% Local validators
%

function local_validateBlocks(x)
    %(
    if isequal(x, true) || isequal(x, false) || isequal(x, @auto)
        return
    end
    error("Input value must be true, false, or @auto.");
    %)
end%

