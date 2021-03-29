% prepareSteady  Prepare steady-state solver
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function varargout = prepareSteady(this, displayMode, varargin)

% Run user-supplied steady-state solver:
% sstate = @func
if numel(varargin)==1 && isa(varargin{1}, 'function_handle')
    varargout{1} = varargin{1};
    return
end

% Run user-supplied steady-state solver with extra arguments:
% sstate = { @func, arg2, arg3,...}
if numel(varargin)==1 && iscell(varargin{1}) ...
        && ~isempty(varargin{1}) ...
        && isa(varargin{1}{1}, 'function_handle')
    varargout{1} = varargin{1};
    return
end

% Do not run steady-state solver:
% sstate = false
if numel(varargin)==1 && isequal(varargin{1}, false)
    varargout{1} = false;
    return
end

% Do run steady-state solve with default options:
% sstate = true
if numel(varargin)==1 && isequal(varargin{1}, true)
    varargin(1) = [ ];
end

% Unfold options entered as one cell array
if numel(varargin)==1 && iscell(varargin{1})
    varargin = { varargin{1}{:} };
end

%( Input parser
persistent parserLinear parserNonlinear
if isempty(parserLinear) || isempty(parserNonlinear)
    %
    % Linear
    %
    parserLinear = extend.InputParser('Model/prepareSteady');
    parserLinear.addRequired('model', @(x) isa(x, 'model'));
    parserLinear.addParameter('Growth', true, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    parserLinear.addParameter('Solve', {"run", false});
    parserLinear.addParameter('Warning', true, @(x) isequal(x, true) || isequal(x, false)); 

    %
    % Nonlinear
    %
    parserNonlinear = extend.InputParser('Model/prepareSteady');
    parserNonlinear.KeepUnmatched = true;
    parserNonlinear.addRequired('model', @(x) isa(x, 'model'));

    parserNonlinear.addParameter({'ChangeBounds', 'GrowthBounds', 'GrowthBnds'}, [ ], @(x) isempty(x) || isstruct(x));
    parserNonlinear.addParameter({'LevelBounds', 'LevelBnds'}, [ ], @(x) isempty(x) || isstruct(x));
    parserNonlinear.addParameter('OptimSet', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x));
    parserNonlinear.addParameter({'NanInit', 'Init'}, 1, @(x) isnumeric(x) && isscalar(x) && isfinite(x));
    parserNonlinear.addParameter('ResetInit', [ ], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && isfinite(x)));
    parserNonlinear.addParameter('Reuse', false, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter({'SolverOptions', 'Solver'}, @auto, @(x) isequal(x, @auto) || isa(x, 'solver.Options') || isa(x, 'optim.options.SolverOptions') || isstring(x) || ischar(x) || isa(x, 'function_handle') || (iscell(x) && all(cellfun(@(y) isstring(y) ||  ischar(y), x(2:2:end))) && (isstring(x{1}) || ischar(x{1}) || isa(x{1}, 'function_handle'))));
    parserNonlinear.addParameter('Warning', true, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter('ZeroMultipliers', true, @(x) isequal(x, true) || isequal(x, false));

    % Blazer related options

    parserNonlinear.addParameter({'Blocks', 'Block'}, true, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter("SuccessOnly", false, @validate.logicalScalar);
    parserNonlinear.addParameter('Growth', @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
    parserNonlinear.addParameter('Log', string.empty(1, 0), @(x) isequal(x, @all) || validate.list(x));
    parserNonlinear.addParameter('Unlog', string.empty(1, 0), @(x) isequal(x, @all) || validate.list(x));
    parserNonlinear.addParameter('SaveAs', [ ], @(x) isempty(x) || ischar(x) || (isstring(x) && isscalar(x)));
    parserNonlinear.addSwapFixOptions( );
end
%)

%--------------------------------------------------------------------------

if this.IsLinear

    % __Linear steady state solver__

    parse(parserLinear, this, varargin{:});
    varargout{1} = parserLinear.Options;
    if islogical(varargout{1}.Solve)
        varargout{1}.Solve = {"run", varargout{1}.Solve};
    end
    varargout{1}.Solve = prepareSolve(this, varargout{1}.Solve{:});

else

    % __Nonlinear steady state solver__

    % Capture obsolete syntax with solver options directly passed among other
    % sstate options and not as suboptions through SolverOptions=; these are only used
    % if SolverOptions= is a string

    parse(parserNonlinear, this, varargin{:});
    opt = parserNonlinear.Options;
    unmatchedSolverOptions = parserNonlinear.UnmatchedInCell;
    if isequal(opt.Growth, @auto)
        opt.Growth = this.IsGrowth;
    end

    if ~opt.Growth && isempty(opt.Fix) && isempty(opt.FixLevel) && isempty(opt.FixChange)
        defaultSolver = 'IRIS-Newton';
    else
        defaultSolver = 'IRIS-Qnsd';
    end

    opt.SolverOptions = solver.Options.parseOptions( ...
        opt.SolverOptions, ...
        defaultSolver, ...
        displayMode, ...
        unmatchedSolverOptions{:} ...
    );

    blazer = locallyRunBlazer(this, opt);
    blazer = locallyPrepareBounds(this, blazer, opt);
    blazer.NanInit = opt.NanInit;
    blazer.Reuse = opt.Reuse;
    blazer.Warning = opt.Warning;
    varargout{1} = blazer;
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
            listLevel, ptrLevel, opt.LevelBounds, inxValidLevels ...
        );
        
        % Steady change bounds
        listChange = this.Quantity.Name(ptrChange);
        [lbg, ubg, inxValidChanges] = hereSetBounds( ...
            listChange, ptrChange, opt.ChangeBounds, inxValidChanges ...
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


        function [vecLb, vecUb, inxValid] = hereSetBounds(list, nameId, bnd, inxValid)
            numList = numel(list);
            vecLb = -inf(1, numList);
            vecUb = inf(1, numList);
            for jj = 1 : numList
                name = list{jj};
                %{
                % isLogPlus = opt.IxLogPlus( nameId(jj) );
                % isLogMinus = opt.IxLogMinus( nameId(jj) );
                %}
                isLog = blazer.Model.Quantity.IxLog( nameId(jj) );
                %{
                try
                    lb = bnd.(name)(1);
                catch
                    if isLogPlus
                        lb = 0;
                    else
                        lb = -Inf;
                    end
                end
                try
                    ub = bnd.(name)(2);
                catch
                    if isLogMinus
                        ub = 0;
                    else
                        ub = Inf;
                    end
                end
                %}
                try
                    lb = bnd.(name)(1);
                catch
                    if isLog
                        lb = 0;
                    else
                        lb = -Inf;
                    end
                end
                try
                    ub = bnd.(name)(2);
                catch
                    ub = Inf;
                end
                %{
                if isLogPlus
                    lb = log(lb);
                    ub = log(ub);
                elseif isLogMinus
                    % Swap lower and upper bounds for log-minus variables.
                    ub = log(-lb);
                    lb = log(-ub);
                end
                %}
                if isLog
                    lb = log(lb);
                    ub = log(ub);
                end
                if imag(lb)==0 && imag(ub)==0
                    % Assign only if both lower and upper bound is ok.
                    vecLb(jj) = lb;
                    vecUb(jj) = ub;
                else
                    % Report problem for this variables.
                    inxValid( nameId(jj) ) = false;
                end
            end
        end%
end%

