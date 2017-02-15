function varargout = prepareSteady(this, displayMode, varargin)
% prepareSteady  Prepare steady-state solver.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% Run user-supplied steady-state solver:
% 'sstate=', @func
if length(varargin)==1 && isa(varargin{1}, 'function_handle')
    varargout{1} = varargin{1};
    return
end

% Run user-supplied steady-state solver with extra arguments:
% 'sstate=', { @func, arg2, arg3,...}
if length(varargin)==1 && iscell(varargin{1}) ...
        && ~isempty(varargin{1}) ...
        && isa(varargin{1}{1}, 'function_handle')
    varargout{1} = varargin{1};
    return
end

% Do not run steady-state solver:
% 'sstate=', false
if length(varargin)==1 && isequal(varargin{1}, false)
    varargout{1} = false;
    return
end

% Do run steady-state solve with default options:
% sstate=, true
if length(varargin)==1 && isequal(varargin{1}, true)
    varargin(1) = [ ];
end

%--------------------------------------------------------------------------

if this.IsLinear
    % Linear sstate solver
    %----------------------
    opt = passvalopt('model.SteadyLinear', varargin{:});
    varargout{1} = opt;
else
    % Nonlinear sstate solver
    %-------------------------
    % Capture obsolete syntax with solver options directly passed among other
    % sstate options and not as suboptions through Solver=; these are only used
    % if Solver= is a char.
    [opt, obsoleteSolverOpt] = passvalopt('model.SteadyNonlinear', varargin{:});
    [opt.Solver, opt.Gradient] = ...
        solver.Options.processOptions(opt.Solver, opt.Gradient, displayMode, obsoleteSolverOpt);
    blz = createBlocks(this, opt);
    blz = processFixOpt(this, blz, opt);
    blz = prepareBounds(this, blz, opt);
    blz.NanInit = opt.NanInit;
    blz.Reuse = opt.Reuse;
    blz.Warning = opt.Warning;
    varargout{1} = blz;
end

end




function blz = processFixOpt(this, blz, opt)
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
list = {'fix', 'fixlevel', 'fixgrowth'};
for i = 1 : length(list)
    fix = list{i};
    fixAllBut = [fix, 'allbut'];
    
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
        posFix  = ell.PosName;
        ixValid = ~isnan(posFix);
        if any(~ixValid)
            throw( exception.Base('Steady:CANNOT_FIX', 'error'), opt.(fix){~ixValid} );
        end
        opt.(fix) = posFix;
    else
        opt.(fix) = [ ];
    end
end

fixL = false(1, nQty);
fixL(opt.fix) = true;
fixL(opt.fixlevel) = true;
fixG = false(1, nQty);
% Fix growth of endogenized parameters to zero.
fixG(ixp) = true;
if opt.growth
    fixG(opt.fix) = true;
    fixG(opt.fixgrowth) = true;
else
    fixG(:) = true;
end
% Fix optimal policy multipliers. The level and growth of
% multipliers will be set to zero in the main loop.
if opt.zeromultipliers
    fixL = fixL | this.Quantity.IxLagrange;
    fixG = fixG | this.Quantity.IxLagrange;
end

blz.PosFix = struct( );
blz.PosFix.Level = PTR( find(fixL) ); %#ok<FNDSB>
blz.PosFix.Growth = PTR( find(fixG) ); %#ok<FNDSB>

% Remove quantities fixed by user and LHS quantities from dynamic links.
ixl = this.Pairing.Link.Lhs>PTR(0);
posExclude = struct( );
posExclude.Level = [blz.PosFix.Level, this.Pairing.Link.Lhs(ixl)];
posExclude.Growth = [blz.PosFix.Growth, this.Pairing.Link.Lhs(ixl)];
exclude(blz, posExclude);
end




function blz = createBlocks(this, opt)
TYPE = @int8;

nQty = length(this.Quantity.Name);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixp = this.Quantity.Type==TYPE(4);

% Run solver.blazer.Blazer on steady equations.
blz = prepareBlazer(this, 'steady', opt);
run(blz);

% Prepare solver.block.Blocks for evaluation.
prepareBlocks(blz, opt);

if blz.IsSingular
    throw( ...
        exception.Base('Steady:STRUCTURAL_SINGULARITY', 'warning')...
        );
end

% Index of level variables that will be always set to zero.
ixZero = struct( );
ixZero.Level = false(1, nQty);
ixZero.Level(ixe) = true;
if opt.growth
    ixZero.Growth = false(1, nQty);
    ixZero.Growth(ixe | ixp) = true;
else
    ixZero.Growth = true(1, nQty);
end
if opt.zeromultipliers
    ixZero.Level = ixZero.Level | this.Quantity.IxLagrange;
    ixZero.Growth = ixZero.Growth | this.Quantity.IxLagrange;
end
blz.IxZero = ixZero;
end




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
        boundsHere(lsLevel, blk.PosQty.Level, opt.levelbounds, ixValidLevel);
    
    % Growth bounds.
    lsGrowth = this.Quantity.Name(blk.PosQty.Growth);
    [lbg, ubg, ixValidGrowth] = ...
        boundsHere(lsGrowth, blk.PosQty.Growth, opt.growthbounds, ixValidGrowth);
    
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
end

