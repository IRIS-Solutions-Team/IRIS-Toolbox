function varargout = prepareSteady(this, displayMode, varargin)
% prepareSteady  Prepare steady-state solver
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

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
if isempty(parserLinear)
    parserLinear = extend.InputParser('model.prepareSteady');
    parserLinear.addRequired('Model', @(x) isa(x, 'model'));
    parserLinear.addParameter('Growth', true, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    parserLinear.addParameter('Solve', false, @model.validateSolve);
    parserLinear.addParameter('Warning', true, @(x) isequal(x, true) || isequal(x, false)); 
end

if isempty(parserNonlinear)
    parserNonlinear = extend.InputParser('model.prepareSteady');
    parserNonlinear.KeepUnmatched = true;
    parserNonlinear.addRequired('Model', @(x) isa(x, 'model'));
    parserNonlinear.addParameter({'Blocks', 'Block'}, true, @(x) isequal(x, true) || isequal(x, false));
    parserNonlinear.addParameter('Fix', { }, @(x) isempty(x) || isa(x, 'Except') || iscellstr(x) || ischar(x));
    parserNonlinear.addParameter('FixLevel', { }, @(x) isempty(x) || isa(x, 'Except') || iscellstr(x) || ischar(x));
    parserNonlinear.addParameter({'FixChange', 'FixGrowth'}, { }, @(x) isempty(x) || isa(x, 'Except') || iscellstr(x) || ischar(x));
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
    parserNonlinear.addSwapOptions( );
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
    blazer = hereRunBlazer(this, opt);
    blazer = herePrepareBounds(this, blazer, opt);
    blazer.NanInit = opt.NanInit;
    blazer.Reuse = opt.Reuse;
    blazer.Warning = opt.Warning;
    varargout{1} = blazer;
end

end%


function hereProcessFixOptions(this, blazer, opt)
    % Process the fix, fixallbut, fixlevel, fixlevelallbut, fixgrowth,
    % and fixgrowthallbut options. All the user-supply information is
    % combined into fixlevel and fixgrowth.
    TYPE = @int8;
    PTR = @int16;

    numQuants = length(this.Quantity.Name);
    ixy = this.Quantity.Type==TYPE(1);
    ixx = this.Quantity.Type==TYPE(2);
    ixp = this.Quantity.Type==TYPE(4);
    inxCanBeFixed =  ixy | ixx;
    namesCanBeFixed = this.Quantity.Name(inxCanBeFixed);
    list = {'Fix', 'FixLevel', 'FixChange'};
    for i = 1 : numel(list)
        fix = list{i};
        temp = opt.(fix);

        if isempty(temp)
            opt.(fix) = double.empty(1, 0);
            continue
        end

        if isa(temp, 'Except')
            temp = resolve(temp, namesCanBeFixed);
        end

        if (ischar(temp) && ~isempty(temp)) ...
           || (isa(temp, 'string') && isscalar(string) && strlength(sting)>0)
            temp = regexp(temp, '\w+', 'match');
            temp = cellstr(temp);
        end
        
        if isempty(temp)
            opt.(fix) = double.empty(1, 0);
            continue
        end

        ell = lookup( this.Quantity, temp, ...
                      TYPE(1), TYPE(2), TYPE(4) );
        posToFix = ell.PosName;
        inxValid = ~isnan(posToFix);
        if any(~inxValid)
            throw( exception.Base('Steady:CANNOT_FIX', 'error'), ...
                   temp{~inxValid} );
        end
        opt.(fix) = posToFix;
    end

    fixL = false(1, numQuants);
    fixL(opt.Fix) = true;
    fixL(opt.FixLevel) = true;
    fixG = false(1, numQuants);

    % Fix steady change of all endogenized parameters to zero
    fixG(ixp) = true;
    if opt.Growth
        fixG(opt.Fix) = true;
        fixG(opt.FixChange) = true;
    else
        fixG(:) = true;
    end

    % Fix optimal policy multipliers; the level and change of
    % multipliers will be set to zero in the main loop
    if opt.ZeroMultipliers
        fixL = fixL | this.Quantity.IxLagrange;
        fixG = fixG | this.Quantity.IxLagrange;
    end

    blazer.IdToFix.Level = PTR( find(fixL) ); %#ok<FNDSB>
    blazer.IdToFix.Growth = PTR( find(fixG) ); %#ok<FNDSB>

    % Remove quantities fixed by user and LHS quantities from dynamic links
    temp = getActiveLhsPtr(this.Link);
    blazer.IdToExclude.Level = [blazer.IdToFix.Level, temp];
    blazer.IdToExclude.Growth = [blazer.IdToFix.Growth, temp];
end%




function blazer = hereRunBlazer(this, opt)
    TYPE = @int8;

    numQuants = length(this.Quantity.Name);
    ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
    ixp = this.Quantity.Type==TYPE(4);

    % Run solver.blazer.Blazer on steady equations
    blazer = prepareBlazer(this, 'Steady', opt);

    % Populate IdToFix and IdToExclude
    hereProcessFixOptions(this, blazer, opt);

    % Analyze block-sequential structure and prepare block.Steady
    run(blazer, opt);

    if blazer.IsSingular
        throw( exception.Base('Steady:StructuralSingularity', 'warning') );
    end

    % Index of variables that will be always set to zero.
    ixZero = struct( );
    ixZero.Level = false(1, numQuants);
    ixZero.Level(ixe) = true;
    if opt.Growth
        ixZero.Growth = false(1, numQuants);
        ixZero.Growth(ixe | ixp) = true;
    else
        ixZero.Growth = true(1, numQuants);
    end
    if opt.ZeroMultipliers
        ixZero.Level = ixZero.Level | this.Quantity.IxLagrange;
        ixZero.Growth = ixZero.Growth | this.Quantity.IxLagrange;
    end
    blazer.IxZero = ixZero;
end%




function blazer = herePrepareBounds(this, blazer, opt)
    numQuants = length(this.Quantity.Name);
    numBlocks = length(blazer.Block);
    inxValidLevels = true(1, numQuants);
    inxValidChanges = true(1, numQuants);
    for iBlk = 1 : numBlocks
        blk = blazer.Block{iBlk};
        if blk.Type~=solver.block.Type.SOLVE
            continue
        end
        
        % Steady level bounds
        lsLevel = this.Quantity.Name(blk.PosQty.Level);
        [lbl, ubl, inxValidLevels] = hereSetBounds( ...
            lsLevel, blk.PosQty.Level, opt.LevelBounds, inxValidLevels ...
        );
        
        % Steady change bounds
        lsGrowth = this.Quantity.Name(blk.PosQty.Growth);
        [lbg, ubg, inxValidChanges] = hereSetBounds( ...
            lsGrowth, blk.PosQty.Growth, opt.ChangeBounds, inxValidChanges ...
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
        
        blazer.Block{iBlk} = blk;
    end

    if any(~inxValidLevels)
        throw( exception.Base('Steady:WRONG_SIGN_LEVEL_BOUNDS', 'error'), ...
               this.Quantity.Name{~inxValidLevels} );
    end
    if any(~inxValidChanges)
        throw( exception.Base('Steady:WRONG_SIGN_GROWTH_BOUNDS', 'error'), ...
               this.Quantity.Name{~inxValidChanges} );
    end

    return


        function [vecLb, vecUb, inxValid] = hereSetBounds(list, nameId, bnd, inxValid)
            nList = length(list);
            vecLb = -inf(1, nList);
            vecUb = inf(1, nList);
            for jj = 1 : nList
                name = list{jj};
                %{
                isLogPlus = opt.IxLogPlus( nameId(jj) );
                isLogMinus = opt.IxLogMinus( nameId(jj) );
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

