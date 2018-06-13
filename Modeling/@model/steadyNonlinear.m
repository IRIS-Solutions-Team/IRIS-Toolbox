function  [this, indexOk] = steadyNonlinear(this, blz, variantsRequested)
% steadyNonlinear  Solve steady equations in nonlinear models
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

nv = length(this);
if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : nv;
else
    variantsRequested = variantsRequested(:).';
end
indexOk = true(1, nv);

if isequal(blz, false)
    return
end

ixLog = blz.IxLog;
ixZero = blz.IxZero;

%--------------------------------------------------------------------------

nQty = length(this.Quantity);
nBlk = numel(blz.Block);
needsRefresh = any(this.Link);

% Index of endogenous level and growth quantities.
ixEndg = struct( );
ixEndg.Level = false(1, nQty);
ixEndg.Growth = false(1, nQty);
for iBlk = 1 : nBlk
    ixEndg.Level(blz.Block{iBlk}.PosQty.Level) = true;
    ixEndg.Growth(blz.Block{iBlk}.PosQty.Growth) = true;
end

if needsRefresh
    this = refresh(this, variantsRequested);
end

% * Check for levels and growth rate fixed to NaNs.
% * Check for NaN in non-endogenous quantities (parameters, exogenous)
asgn = this.Variant.Values(:, :, variantsRequested);
checkFixedToNaN( );
checkExogenizedToNaN( );

lx0 = [ ];
gx0 = [ ];
firstAlt = true;

for v = variantsRequested
    [lx, gx] = initialize( );
    
    % __Cycle over Individual Blocks__
    blockExitStatus = false(1, nBlk);
    for iBlk = 1 : nBlk
        blk = blz.Block{iBlk};
        [lx, gx, blockExitStatus(iBlk), error] = run(blk, this.Link, lx, gx, ixLog);
        if ~blockExitStatus(iBlk)
            fprintf('    Block %g of %g failed to solve.\n', iBlk, nBlk);
        end
        if ~isempty(error.EvaluatesToNan)
            throw( ...
                exception.Base('Steady:EvaluatesToNan', 'error'), ...
                this.Equation.Input{error.EvaluatesToNan} ...
            );
        end
    end
    this.Variant.Values(:, :, v) = lx + 1i*gx;
    
    % Check for zero log variables.
    indexOk(v) = chkQty(this, v, 'log') && all(blockExitStatus);
    
    % TODO: Report more details on failed equations and variables.
    if blz.Warning && ~indexOk(v)
        utils.warning('model:mysstatenonlin', ...
            'Steady state inaccurate or not returned for some variables.');
    end
    
    % Store current values to initialise next parameterisation.
    lx0 = lx;
    gx0 = gx;
    firstAlt = false;
end

if needsRefresh
    this = refresh(this, variantsRequested);
end

% Return status only for parameterizations requested in variantsRequested.
indexOk = indexOk(variantsRequested);

return


    function [lx, gx] = initialize( )
        % __Initialise levels of endogenous quantities__
        lx = real(this.Variant.Values(:, :, v));
        % Level variables that are set to zero (all shocks).
        lx(ixZero.Level) = 0;
        % Assign NaN level initial conditions. First, assign values from the
        % previous iteration, if they exist and option 'reuse=' is `true`.
        ix = isnan(lx) & ixEndg.Level;
        if ~firstAlt && blz.Reuse && any(ix) && ~isempty(lx0)
            lx(ix) = lx0(ix);
            ix = isnan(lx) & ixEndg.Level;
        end
        % Use option NanInit= to assign NaNs.
        lx(ix) = real(blz.NanInit);
        
        % __Initialise growth rates of endogenous quantities__
        gx = imag(this.Variant.Values(:, :, v));
        % Variables with zero growth (all variables if 'growth=' false).
        gx(ixZero.Growth) = 0;
        if any(~ixZero.Growth)
            % Assign NaN growth initial conditions. First, assign values from
            % the previous iteration, if they exist and option 'reuse=' is
            % `true`.
            ix = isnan(gx) & ixEndg.Growth;
            if ~firstAlt && blz.Reuse && any(ix) && ~isempty(gx0)
                gx(ix) = gx0(ix);
                ix = isnan(gx) & ixEndg.Growth;
            end
            % Use option NanInit= to assign NaNs.
            gx(ix) = imag(blz.NanInit);
        end
        % Reset zero growth to 1 for *all* log quantities (not only endogenous).
        gx(ixLog & gx==0) = 1;
    end


    function checkFixedToNaN( )
        numQuantities = length(this.Quantity);
        % __Check for Levels Fixed to NaN__
        idToFix = blz.IdToFix.Level;
        indexToFix = false(1, numQuantities);
        indexToFix(idToFix) = true;
        indexNaN = any(isnan(real(asgn)), 3) & indexToFix & ~blz.IxZero.Level;
        if any(indexNaN)
            throw( ...
                exception.Base('Steady:LevelFixedToNan', 'error'), ...
                this.Quantity.Name{indexNaN} ...
            );
        end
        % __Check for Growth Rates Fixed to NaN__
        idToFix = blz.IdToFix.Growth;
        indexToFix = false(1, numQuantities);
        indexToFix(idToFix) = true;
        indexNaN = any(isnan(imag(asgn)), 3) & indexToFix & ~blz.IxZero.Growth;
        if any(indexNaN)
            throw( ...
                exception.Base('Steady:GrowthFixedToNan', 'error'), ...
                this.Quantity.Name{indexNaN} ...
            );
        end
    end


    function checkExogenizedToNaN( )
        indexNeeded = any( across(this.Incidence.Steady, 'Shifts'), 1);
        indexNeeded = full(indexNeeded);
        indexLevelNeeded = indexNeeded & ~ixEndg.Level & ~ixZero.Level;
        indexGrowthNeeded = indexNeeded & ~ixEndg.Growth & ~ixZero.Growth;
        % Level or growth is endogenous, not fixed, and NaN
        indexLevelNaN = any(isnan(real(asgn)), 3);
        indexGrowthNaN = any(isnan(imag(asgn)), 3);
        indexLevelToReport = indexLevelNeeded & indexLevelNaN;
        indexGrowthToReport = indexGrowthNeeded & indexGrowthNaN;
        if any(indexLevelToReport)
            throw( ...
                exception.Base('Steady:ExogenousLevelNan', 'warning'), ...
                this.Quantity.Name{indexLevelToReport} ...
            );
        end
        if any(indexGrowthToReport)
            throw( ...
                exception.Base('Steady:ExogenousGrowthNan', 'warning'), ...
                this.Quantity.Name{indexGrowthToReport} ...
            );
        end
    end
end
