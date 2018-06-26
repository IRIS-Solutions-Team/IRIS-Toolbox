function varargout = prepareSteady(this, displayMode, varargin)
% prepareSteady  Prepare steady-state solver
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

% Run user-supplied steady-state solver:
% sstate = @func
if length(varargin)==1 && isa(varargin{1}, 'function_handle')
    varargout{1} = varargin{1};
    return
end

% Run user-supplied steady-state solver with extra arguments:
% sstate = { @func, arg2, arg3,...}
if length(varargin)==1 && iscell(varargin{1}) ...
        && ~isempty(varargin{1}) ...
        && isa(varargin{1}{1}, 'function_handle')
    varargout{1} = varargin{1};
    return
end

% Do not run steady-state solver:
% sstate = false
if length(varargin)==1 && isequal(varargin{1}, false)
    varargout{1} = false;
    return
end

% Do run steady-state solve with default options:
% sstate = true
if length(varargin)==1 && isequal(varargin{1}, true)
    varargin(1) = [ ];
end

persistent inputParserLinear inputParserNonlinear

if isempty(inputParserLinear)
    inputParserLinear = extend.InputParser('model.prepareSteady');
    inputParserLinear.addRequired('Model', @(x) isa(x, 'model'));
    inputParserLinear.addParameter('Growth', true, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    inputParserLinear.addParameter('Solve', false, @model.validateSolve);
    inputParserLinear.addParameter('Warning', true, @(x) isequal(x, true) || isequal(x, false)); 
end

if isempty(inputParserNonlinear)
    inputParserNonlinear = extend.InputParser('model.prepareSteady');
    inputParserNonlinear.addRequired('Model', @(x) isa(x, 'model'));
    inputParserNonlinear.KeepUnmatched = true;
    inputParserNonlinear.addParameter({'Blocks', 'Block'}, true, @(x) isequal(x, true) || isequal(x, false));
    inputParserNonlinear.addParameter('Fix', { }, @(x) isempty(x) || iscellstr(x) || ischar(x));
    inputParserNonlinear.addParameter('FixAllBut', { }, @(x) isempty(x) || iscellstr(x) || ischar(x));
    inputParserNonlinear.addParameter('FixLevel', { }, @(x) isempty(x) || iscellstr(x) || ischar(x));
    inputParserNonlinear.addParameter('FixLevelAllBut', { }, @(x) isempty(x) || iscellstr(x) || ischar(x));
    inputParserNonlinear.addParameter('FixGrowth', { }, @(x) isempty(x) || iscellstr(x) || ischar(x));
    inputParserNonlinear.addParameter('FixGrowthAllBut', { }, @(x) isempty(x) || iscellstr(x) || ischar(x));
    inputParserNonlinear.addParameter('ForceRediff', false, @(x) isequal(x, true) || isequal(x, false));
    inputParserNonlinear.addParameter('Growth', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    inputParserNonlinear.addParameter({'GrowthBounds', 'GrowthBnds'}, [ ], @(x) isempty(x) || isstruct(x));
    inputParserNonlinear.addParameter({'LevelBounds', 'LevelBnds'}, [ ], @(x) isempty(x) || isstruct(x));
    inputParserNonlinear.addParameter('OptimSet', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x));
    inputParserNonlinear.addParameter({'NanInit', 'Init'}, 1, @(x) isnumeric(x) && isscalar(x) && isfinite(x));
    inputParserNonlinear.addParameter('ResetInit', [ ], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && isfinite(x)));
    inputParserNonlinear.addParameter('Reuse', false, @(x) isequal(x, true) || isequal(x, false));
    inputParserNonlinear.addParameter('Solver', 'IRIS', @(x) ischar(x) || isa(x, 'function_handle') || (iscell(x) && iscellstr(x(2:2:end)) && (ischar(x{1}) || isa(x{1}, 'function_handle'))));
    inputParserNonlinear.addParameter('PrepareGradient', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    inputParserNonlinear.addParameter('Unlog', { }, @(x) isempty(x) || ischar(x) || iscellstr(x) || isequal(x, @all));
    inputParserNonlinear.addParameter('Warning', true, @(x) isequal(x, true) || isequal(x, false));
    inputParserNonlinear.addParameter('ZeroMultipliers', true, @(x) isequal(x, true) || isequal(x, false));
    inputParserNonlinear.addSwapOptions( );
end

%--------------------------------------------------------------------------

if this.IsLinear
    % __Linear Steady State Solver__
    inputParserLinear.parse(this, varargin{:});
    varargout{1} = inputParserLinear.Options;
else
    % __Nonlinear Steady State Solver__
    % Capture obsolete syntax with solver options directly passed among other
    % sstate options and not as suboptions through Solver=; these are only used
    % if Solver= is a char.
    inputParserNonlinear.parse(this, varargin{:});
    opt = inputParserNonlinear.Options;
    obsoleteSolverOpt = inputParserNonlinear.UnmatchedInCell;
    if isequal(opt.Growth, @auto)
        opt.Growth = this.IsGrowth;
    end
    [ opt.Solver, ...
      opt.PrepareGradient] = solver.Options.processOptions( opt.Solver, ...
                                                            'Steady', ...
                                                            opt.PrepareGradient, ...
                                                            displayMode, ...
                                                            obsoleteSolverOpt );
    blz = createBlocks(this, opt);
    blz = prepareBounds(this, blz, opt);
    blz.NanInit = opt.NanInit;
    blz.Reuse = opt.Reuse;
    blz.Warning = opt.Warning;
    varargout{1} = blz;
end

end%


function processFixOpt(this, blz, opt)
    % Process the fix, fixallbut, fixlevel, fixlevelallbut, fixgrowth,
    % and fixgrowthallbut options. All the user-supply information is
    % combined into fixlevel and fixgrowth.
    TYPE = @int8;
    PTR = @int16;

    nQty = length(this.Quantity.Name);
    ixy = this.Quantity.Type==TYPE(1);
    ixx = this.Quantity.Type==TYPE(2);
    ixp = this.Quantity.Type==TYPE(4);
    ixCanBeFixed =  ixy | ixx | ixp;
    list = {'Fix', 'FixLevel', 'FixGrowth'};
    for i = 1 : length(list)
        fix = list{i};
        fixAllBut = [fix, 'AllBut'];
        
        % Convert charlist to cellstr.
        if ischar(opt.(fix)) && ~isempty(opt.(fix))
            opt.(fix) = regexp(opt.(fix), '\w+', 'match');
        end
        if ischar(opt.(fixAllBut)) && ~isempty(opt.(fixAllBut))
            opt.(fixAllBut) = ...
                regexp(opt.(fixAllBut), '\w+', 'match');
        end
        
        % Convert fixAllBut to fix.
        if ~isempty(opt.(fixAllBut))
            lsNameCanBeFixed = this.Quantity.Name(ixCanBeFixed);
            opt.(fix) = setdiff(lsNameCanBeFixed, opt.(fixAllBut));
        end
        
        if ~isempty(opt.(fix))
            ell = lookup(this.Quantity, opt.(fix), ...
                TYPE(1), ...
                TYPE(2), ...
                TYPE(4));
            positionsFix  = ell.PosName;
            ixValid = ~isnan(positionsFix);
            if any(~ixValid)
                throw( exception.Base('Steady:CANNOT_FIX', 'error'), opt.(fix){~ixValid} );
            end
            opt.(fix) = positionsFix;
        else
            opt.(fix) = [ ];
        end
    end

    fixL = false(1, nQty);
    fixL(opt.Fix) = true;
    fixL(opt.FixLevel) = true;
    fixG = false(1, nQty);
    % Fix growth of endogenized parameters to zero.
    fixG(ixp) = true;
    if opt.Growth
        fixG(opt.Fix) = true;
        fixG(opt.FixGrowth) = true;
    else
        fixG(:) = true;
    end

    % Fix optimal policy multipliers. The level and growth of
    % multipliers will be set to zero in the main loop.
    if opt.ZeroMultipliers
        fixL = fixL | this.Quantity.IxLagrange;
        fixG = fixG | this.Quantity.IxLagrange;
    end

    blz.IdToFix.Level = PTR( find(fixL) ); %#ok<FNDSB>
    blz.IdToFix.Growth = PTR( find(fixG) ); %#ok<FNDSB>

    % Remove quantities fixed by user and LHS quantities from dynamic links.
    temp = getActiveLhsPtr(this.Link);
    blz.IdToExclude.Level = [blz.IdToFix.Level, temp];
    blz.IdToExclude.Growth = [blz.IdToFix.Growth, temp];
end%


function blz = createBlocks(this, opt)
    TYPE = @int8;

    nQty = length(this.Quantity.Name);
    ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
    ixp = this.Quantity.Type==TYPE(4);

    % Run solver.blazer.Blazer on steady equations.
    numPeriods = 1;
    blz = prepareBlazer(this, 'Steady', numPeriods, opt);

    % Analyze block-sequential structure.
    run(blz);

    % Populate IdToFix and IdToExclude.
    processFixOpt(this, blz, opt);

    % Prepare solver.block.Blocks for evaluation.
    prepareBlocks(blz, opt);

    if blz.IsSingular
        throw( exception.Base('Steady:StructuralSingularity', 'warning') );
    end

    % Index of variables that will be always set to zero.
    ixZero = struct( );
    ixZero.Level = false(1, nQty);
    ixZero.Level(ixe) = true;
    if opt.Growth
        ixZero.Growth = false(1, nQty);
        ixZero.Growth(ixe | ixp) = true;
    else
        ixZero.Growth = true(1, nQty);
    end
    if opt.ZeroMultipliers
        ixZero.Level = ixZero.Level | this.Quantity.IxLagrange;
        ixZero.Growth = ixZero.Growth | this.Quantity.IxLagrange;
    end
    blz.IxZero = ixZero;
end%


function blz = prepareBounds(this, blz, opt)
    nQty = length(this.Quantity.Name);
    nBlk = length(blz.Block);
    ixValidLevel = true(1, nQty);
    ixValidGrowth = true(1, nQty);
    for iBlk = 1 : nBlk
        blk = blz.Block{iBlk};
        if blk.Type~=solver.block.Type.SOLVE
            continue
        end
        
        % Level bounds.
        lsLevel = this.Quantity.Name(blk.PosQty.Level);
        [lbl, ubl, ixValidLevel] = ...
            boundsHere(lsLevel, blk.PosQty.Level, opt.LevelBounds, ixValidLevel);
        
        % Growth bounds.
        lsGrowth = this.Quantity.Name(blk.PosQty.Growth);
        [lbg, ubg, ixValidGrowth] = ...
            boundsHere(lsGrowth, blk.PosQty.Growth, opt.GrowthBounds, ixValidGrowth);
        
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
        
        blz.Block{iBlk} = blk;
    end

    if any(~ixValidLevel)
        throw( exception.Base('Steady:WRONG_SIGN_LEVEL_BOUNDS', 'error'), ...
            this.Quantity.Name{~ixValidLevel} );
    end
    if any(~ixValidGrowth)
        throw( exception.Base('Steady:WRONG_SIGN_GROWTH_BOUNDS', 'error'), ...
            this.Quantity.Name{~ixValidGrowth} );
    end

    return


    function [vecLb, vecUb, ixValid] = boundsHere(list, nameId, bnd, ixValid)
        nList = length(list);
        vecLb = -inf(1, nList);
        vecUb = inf(1, nList);
        for jj = 1 : nList
            name = list{jj};
            %{
            isLogPlus = opt.IxLogPlus( nameId(jj) );
            isLogMinus = opt.IxLogMinus( nameId(jj) );
            %}
            isLog = blz.IxLog( nameId(jj) );
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
                ixValid( nameId(jj) ) = false;
            end
        end
    end
end%

