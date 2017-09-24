function  [this, ixOk] = steadyNonlinear(this, blz, variantsRequested)
% steadyNonlinear  Solve steady equations in nonlinear models.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

PTR = @int16;

nv = length(this);
if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : nv;
else
    variantsRequested = variantsRequested(:).';
end
ixOk = true(1, nv);

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
    ixOk(v) = chkQty(this, v, 'log') && all(blockExitStatus);
    
    % TODO: Report more details on failed equations and variables.
    if blz.Warning && ~ixOk(v)
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
ixOk = ixOk(variantsRequested);

return


    function [lx, gx] = initialize( )
        % Initialise levels of endogenous quantities
        %--------------------------------------------
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
        
        % Initialise growth rates of endogenous quantities
        %--------------------------------------------------
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
        numOfQuantities = length(this.Quantity);
        % __Check for Levels Fixed to NaN__
        idToFix = blz.IdToFix.Level;
        indexToFix = false(1, numOfQuantities);
        indexToFix(idToFix) = true;
        indexOfNaN = any(isnan(real(asgn)), 3) & indexToFix & ~blz.IxZero.Level;
        if any(indexOfNaN)
            throw( ...
                exception.Base('Steady:LevelFixedToNan', 'error'), ...
                this.Quantity.Name{indexOfNaN} ...
                );
        end
        % __Check for Growth Rates Fixed to NaN__
        idToFix = blz.IdToFix.Growth;
        indexToFix = false(1, numOfQuantities);
        indexToFix(idToFix) = true;
        indexOfNaN = any(isnan(imag(asgn)), 3) & indexToFix & ~blz.IxZero.Growth;
        if any(indexOfNaN)
            throw( ...
                exception.Base('Steady:GrowthFixedToNan', 'error'), ...
                this.Quantity.Name{indexOfNaN} ...
                );
        end
    end


    function checkExogenizedToNaN( )
        % Parameter or exogenous variable occurs in steady equations.
        ixNeeded = any( across(this.Incidence.Steady, 'Shifts'), 1);
        ixNeeded = full(ixNeeded);
        % Level or growth is endogenous and NaN.
        ixNan = (isnan(real(asgn)) & ~ixEndg.Level) ...
            | (isnan(imag(asgn)) & ~ixEndg.Growth);
        ixRpt = ixNeeded & ixNan;
        if any(ixRpt)
            throw( ...
                exception.Base('Steady:ExogenousNan', 'warning'), ...
                this.Quantity.Name{ixRpt} ...
                );
        end
    end
end
