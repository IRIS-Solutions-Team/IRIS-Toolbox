function varargout = prepareSteady(this, displayMode, varargin)
% prepareSteady  Prepare steady-state solver
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

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

persistent parserLinear parserNonlinear
if isempty(parserLinear) || isempty(parserNonlinear)
    %
    % Linear
    %
    parserLinear = extend.InputParser('Model/prepareSteady');
    parserLinear.addRequired('model', @(x) isa(x, 'model'));
    parserLinear.addParameter('Growth', true, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    parserLinear.addParameter('Solve', false, @model.validateSolve);
    parserLinear.addParameter('Warning', true, @(x) isequal(x, true) || isequal(x, false)); 

    %
    % Nonlinear
    %
    parserNonlinear = extend.InputParser('Model/prepareSteady');
    parserNonlinear.KeepUnmatched = true;
    parserNonlinear.addRequired('model', @(x) isa(x, 'model'));

    parserNonlinear.addParameter('SaveAs', '', @(x) isempty(x) || ischar(x) || (isa(x, 'string') && isscalar(x)));
    parserNonlinear.addParameter({'Blocks', 'Block'}, true, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter('ForceRediff', false, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter('Growth', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter({'ChangeBounds', 'GrowthBounds', 'GrowthBnds'}, [ ], @(x) isempty(x) || isstruct(x));
    parserNonlinear.addParameter({'LevelBounds', 'LevelBnds'}, [ ], @(x) isempty(x) || isstruct(x));
    parserNonlinear.addParameter('OptimSet', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x));
    parserNonlinear.addParameter({'NanInit', 'Init'}, 1, @(x) isnumeric(x) && isscalar(x) && isfinite(x));
    parserNonlinear.addParameter('ResetInit', [ ], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && isfinite(x)));
    parserNonlinear.addParameter('Reuse', false, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter('Solver', @auto, @(x) isequal(x, @auto) || ischar(x) || isa(x, 'function_handle') || (iscell(x) && iscellstr(x(2:2:end)) && (ischar(x{1}) || isa(x{1}, 'function_handle'))));
    parserNonlinear.addParameter('SteadyShift', 3, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>0);    
    parserNonlinear.addParameter('PrepareGradient', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter('Unlog', { }, @(x) isempty(x) || ischar(x) || iscellstr(x) || isequal(x, @all));
    parserNonlinear.addParameter('Log', { }, @(x) isempty(x) || ischar(x) || iscellstr(x) || isequal(x, @all));
    parserNonlinear.addParameter('Warning', true, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter('ZeroMultipliers', true, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addSwapFixOptions( );
end

%--------------------------------------------------------------------------

if this.IsLinear
    %
    % Linear Steady State Solver
    %
    parserLinear.parse(this, varargin{:});
    varargout{1} = parserLinear.Options;
else
    %
    % Nonlinear Steady State Solver
    %
    % Capture obsolete syntax with solver options directly passed among other
    % sstate options and not as suboptions through Solver=; these are only used
    % if Solver= is a char.
    %
    parserNonlinear.parse(this, varargin{:});
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
    [ opt.Solver, ...
      opt.PrepareGradient ] = solver.Options.parseOptions( opt.Solver, ...
                                                           defaultSolver, ...
                                                           opt.PrepareGradient, ...
                                                           displayMode, ...
                                                           'SpecifyObjectiveGradient=', true, ...
                                                           unmatchedSolverOptions{:} );
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
    % Run solver.blazer.Blazer on steady equations, process Exogenize=,
    % Endogenize=, Fix...= options
    %
    blazer = prepareBlazer(this, 'Steady', opt);

    % Analyze block-sequential structure and prepare block.Steady
    run(blazer, opt);
    if ~isempty(opt.SaveAs)
        saveAs(blazer, opt.SaveAs);
    end

    % Index of variables that will be always set to zero
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
    numBlocks = length(blazer.Block);
    inxValidLevels = true(1, numQuants);
    inxValidChanges = true(1, numQuants);
    for i = 1 : numBlocks
        blk = blazer.Block{i};
        if blk.Type~=solver.block.Type.SOLVE
            continue
        end
        
        % Steady level bounds
        [ptrLevel, ptrChange] = iris.utils.splitRealImag(blk.PtrQuantities);

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
        blk.Lower = [lbl, lbg];
        blk.Upper = [ubl, ubg];
        
        if isa(blk.Solver, 'optim.options.SolverOptions')
            % Make sure @lsqnonlin is used when there are some lower/upper bounds.
            isBnd = any(~isinf(blk.Lower)) || any(~isinf(blk.Upper));
            if isBnd
                if ~strcmp(blk.Solver.SolverName, 'lsqnonlin')
                    blk.Solver = blk.Solver('lsqnonlin', blk.Solver);
                end
            end
        end

        blazer.Block{i} = blk;
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

