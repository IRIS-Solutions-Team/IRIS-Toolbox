% prepareSteady  Prepare steady solver
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

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
    % options.Growth (1, :) logical {mustBeScalarOrEmpty} = []
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
    parserLinear = extend.InputParser('Model/prepareSteady');
    parserLinear.addRequired('model', @(x) isa(x, 'model'));
    parserLinear.addParameter('Growth', [], @(x) isempty(x) || isequal(x, true) || isequal(x, false));
    parserLinear.addParameter('Solve', {"run", false});
    parserLinear.addParameter('Warning', true, @(x) isequal(x, true) || isequal(x, false)); 
    parserLinear.addParameter("Silent", false);
    parserLinear.addParameter("Run", true);

    % Nonlinear
    parserNonlinear = extend.InputParser('Model/prepareSteady');
    parserNonlinear.KeepUnmatched = true;
    parserNonlinear.addRequired('model', @(x) isa(x, 'model'));

    parserNonlinear.addParameter({'ChangeWithin', 'ChangeBounds', 'GrowthBounds', 'GrowthBnds'}, [ ], @(x) isempty(x) || isstruct(x));
    parserNonlinear.addParameter({'LevelWithin', 'LevelBounds', 'LevelBnds'}, [ ], @(x) isempty(x) || isstruct(x));
    parserNonlinear.addParameter('OptimSet', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x));
    parserNonlinear.addParameter({'NanInit', 'Init'}, 1, @(x) isnumeric(x) && isscalar(x) && isfinite(x));
    parserNonlinear.addParameter('ResetInit', [ ], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && isfinite(x)));
    parserNonlinear.addParameter('Reuse', false, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter({'SolverOptions', 'Solver'}, @auto, @(x) isequal(x, @auto) || isa(x, 'solver.Options') || isa(x, 'optim.options.SolverOptions') || isstring(x) || ischar(x) || isa(x, 'function_handle') || (iscell(x) && all(cellfun(@(y) isstring(y) ||  ischar(y), x(2:2:end))) && (isstring(x{1}) || ischar(x{1}) || isa(x{1}, 'function_handle'))));
    parserNonlinear.addParameter('Warning', true, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter('ZeroMultipliers', true, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter("Silent", false);
    parserNonlinear.addParameter("Run", true);


    % Blazer related options
    parserNonlinear.addParameter({'Blocks', 'Block'}, true, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter("SuccessOnly", false, @validate.logicalScalar);
    parserNonlinear.addParameter('Growth', [], @(x) isempty(x) || validate.logicalScalar(x));
    parserNonlinear.addParameter('Log', string.empty(1, 0), @(x) isequal(x, @all) || validate.list(x));
    parserNonlinear.addParameter('Unlog', string.empty(1, 0), @(x) isequal(x, @all) || validate.list(x));
    parserNonlinear.addParameter('SaveAs', [ ], @(x) isempty(x) || ischar(x) || (isstring(x) && isscalar(x)));
    parserNonlinear.addSwapFixOptions( );
end
%)

if this.IsLinear

    % __Linear steady state solver__

    parse(parserLinear, this, varargin{:});
    output = parserLinear.Options;
    
    if islogical(output.Solve)
        output.Solve = {"run", output.Solve};
    end
    output.Solve = prepareSolve(this, output.Solve{:});

else

    % __Nonlinear steady state solver__

    % Capture obsolete syntax with solver options directly passed among other
    % sstate options and not as suboptions through SolverOptions=; these are only used
    % if SolverOptions= is a string

    parse(parserNonlinear, this, varargin{:});

    options = parserNonlinear.Options;
    
    if ~options.Run
        output = options;
        return
    end
    
    if isempty(options.Growth)
        options.Growth = this.IsGrowth;
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

    blazer = locallyRunBlazer(this, options);
    blazer = locallyPrepareBounds(this, blazer, options);
    blazer.NanInit = options.NanInit;
    blazer.Reuse = options.Reuse;
    blazer.Warning = options.Warning;
    
    output = blazer;
end

end%

%
% Local Functions
%

function blazer = locallyRunBlazer(this, opt)
    TYPE = @int8;

    numQuants = numel(this.Quantity.Name);

    %
    % Look up shocks and parameters; steady change will be fixed for these
    % at zero no matter what
    %
    inxE = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
    inxP = this.Quantity.Type==TYPE(4);

    %
    % Prepare solver.blazer.Blazer for steady equations, process Exogenize=,
    % Endogenize=, Fix...= options
    %
    blazer = solver.blazer.Steady.forModel(this, opt);


    %
    % Split equations into sequential blocks, prepare blocks, and prepare
    % solver options within the blocks
    %
    run(blazer);
    prepareForSolver(blazer, opt.SolverOptions);


    %
    % Save block-recursive structure to a text file
    %
    if ~isempty(opt.SaveAs)
        saveAs(blazer, opt.SaveAs);
    end


    %
    % Prepare index of variables that will be always set to zero
    %
    inxZero = struct( );
    inxZero.Level = false(1, numQuants);
    inxZero.Level(inxE) = true;
    if opt.Growth
        inxZero.Change = false(1, numQuants);
        inxZero.Change(inxE | inxP) = true;
    else
        inxZero.Change = true(1, numQuants);
    end
    if opt.ZeroMultipliers
        inxZero.Level = inxZero.Level | this.Quantity.IxLagrange;
        inxZero.Change = inxZero.Change | this.Quantity.IxLagrange;
    end
    blazer.InxZero = inxZero;
end%




function blazer = locallyPrepareBounds(this, blazer, opt)
    numQuants = length(this.Quantity.Name);
    numBlocks = length(blazer.Blocks);
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

