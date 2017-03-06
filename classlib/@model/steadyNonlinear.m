function  [this, ixOk] = steadyNonlinear(this, blz, vecAlt)
% steadyNonlinear  Solve steady equations in nonlinear models.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

PTR = @int16;

nAlt = length(this);
if isequal(vecAlt, Inf) || isequal(vecAlt, @all)
    vecAlt = 1 : nAlt;
end
ixOk = true(1, nAlt);

if isequal(blz, false)
    return
end

ixLog = blz.IxLog;
ixZero = blz.IxZero;

%--------------------------------------------------------------------------

nQty = length(this.Quantity);
nBlk = numel(blz.Block);
needsRefresh = any( this.Pairing.Link.Lhs>PTR(0) );

% Index of endogenous level and growth quantities.
ixEndg = struct( );
ixEndg.Level = false(1, nQty);
ixEndg.Growth = false(1, nQty);
for iBlk = 1 : nBlk
    ixEndg.Level(blz.Block{iBlk}.PosQty.Level) = true;
    ixEndg.Growth(blz.Block{iBlk}.PosQty.Growth) = true;
end

if needsRefresh
    this = refresh(this, vecAlt);
end

% * Check for levels and growth rate fixed to NaNs.
% * Check for NaN in non-endogenous quantities (parameters, exogenous)
asgn = model.Variant.getQuantity(this.Variant, ':', vecAlt);
chkNanFixed( );
chkNanExog( );

lx0 = [ ];
gx0 = [ ];
firstAlt = true;

for iAlt = vecAlt
    [lx, gx] = initialize( );
    
    % Cycle over individual blocks
    %------------------------------
    blockExitStatus = false(1, nBlk);
    for iBlk = 1 : nBlk
        blk = blz.Block{iBlk};
        blk.NeedsRefresh = needsRefresh;
        [lx, gx, blockExitStatus(iBlk), error] = run(blk, lx, gx, ixLog);
        
        if ~isempty(error.EvaluatesToNan)
            throw( ...
                exception.Base('Steady:EvaluatesToNan', 'error'), ...
                this.Equation.Input{error.EvaluatesToNan} ...
                );
        end
    end
    gx(ixLog & gx == 1) = 0;
    this.Variant{iAlt}.Quantity = lx + 1i*gx;
    
    % Check for zero log variables.
    ixOk(iAlt) = chkQty(this, iAlt, 'log') && all(blockExitStatus);
    
    % TODO: Report more details on failed equations and variables.
    if blz.Warning && ~ixOk(iAlt)
        utils.warning('model:mysstatenonlin', ...
            'Steady state inaccurate or not returned for some variables.');
    end
    
    % Store current values to initialise next parameterisation.
    lx0 = lx;
    gx0 = gx;
    firstAlt = false;
end

if needsRefresh
    this = refresh(this, vecAlt);
end

% Return status only for parameterizations requested in vecAlt.
ixOk = ixOk(vecAlt);

return





    function [lx, gx] = initialize( )
        % Initialise levels of endogenous quantities
        %--------------------------------------------
        lx = real(this.Variant{iAlt}.Quantity);
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
        gx = imag(this.Variant{iAlt}.Quantity);
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




    function chkNanFixed( )
        nQuan = length(this.Quantity);
        % Check for levels fixed to NaN.
        posFix = blz.PosFix.Level;
        ixFix = false(1, nQuan);
        ixFix(posFix) = true;
        iixZero = blz.IxZero.Level;
        
        ixNanLevel = any(isnan(real(asgn)), 3) & ixFix & ~iixZero;
        if any(ixNanLevel)
            throw( ...
                exception.Base('Steady:LevelFixedToNan', 'error'), ...
                this.Quantity.Name{ixNanLevel} ...
                );
        end
        
        % Check for growth rates fixed to NaN.
        posFix = blz.PosFix.Growth;
        ixFix = false(1, nQuan);
        ixFix(posFix) = true;
        iixZero = blz.IxZero.Growth;
        ixNanGrowth = any(isnan(imag(asgn)), 3) & ixFix & ~iixZero;
        if any(ixNanGrowth)
            throw( ...
                exception.Base('Steady:GrowthFixedToNan', 'error'), ...
                this.Quantity.Name{ixNanGrowth} ...
                );
        end
    end




    function chkNanExog( )
        % Parameter or exogenous variable occurs in steady equations.
        ixNeeded = any( across(this.Incidence.Steady, 'Shifts'), 1);
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
