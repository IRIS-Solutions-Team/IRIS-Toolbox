function  [this, success, outputInfo] = steadyNonlinear(this, blazer, variantsRequested)
% steadyNonlinear  Solve steady equations in nonlinear models
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

nv = length(this);
if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : nv;
else
    variantsRequested = variantsRequested(:).';
end
success = true(1, nv);
outputInfo = struct( 'ExitFlags', solver.ExitFlag.empty(0), ...
                     'Blazer', blazer );

if isequal(blazer, false)
    return
end

inxOfLog = blazer.Quantity.InxOfLog;
inxOfZero = blazer.InxOfZero;

%--------------------------------------------------------------------------

numOfQuantities = length(this.Quantity);
numOfBlocks = numel(blazer.Block);
needsRefresh = any(this.Link);

% Index of endogenous level and growth quantities
ixEndg = struct( );
ixEndg.Level = false(1, numOfQuantities);
ixEndg.Growth = false(1, numOfQuantities);
for i = 1 : numOfBlocks
    ixEndg.Level(blazer.Block{i}.PosQty.Level) = true;
    ixEndg.Growth(blazer.Block{i}.PosQty.Growth) = true;
end

if needsRefresh
    this = refresh(this, variantsRequested);
end

% * Check for levels and growth rate fixed to NaNs
% * Check for NaN in non-endogenous quantities (parameters, exogenous)
steadyLevel = real(this.Variant.Values(:, :, variantsRequested));
steadyChange = imag(this.Variant.Values(:, :, variantsRequested));
hereCheckFixedToNaN( );
hereCheckExogenizedToNaN( );

lx0 = [ ];
gx0 = [ ];
firstAlt = true;

outputInfo.ExitFlags = cell(1, nv);
for v = variantsRequested
    [lx, gx] = hereInitialize( );
    
    % __Cycle over Individual Blocks__
    outputInfo.ExitFlags{v} = repmat(solver.ExitFlag.IN_PROGRESS, 1, numOfBlocks);
    for i = 1 : numOfBlocks
        blk = blazer.Block{i};
        blk.SteadyShift = 3;
        [lx, gx, exitFlag, error] = run(blk, this.Link, lx, gx, inxOfLog);
        outputInfo.ExitFlags{v}(i) = exitFlag;
        %if ~exitFlags{v}(i)
        %    fprintf('    Block %g of %g failed to solve.\n', i, numOfBlocks);
        %end
        if ~isempty(error.EvaluatesToNan)
            throw( exception.Base('Steady:EvaluatesToNan', 'error'), ...
                   this.Equation.Input{error.EvaluatesToNan} );
        end
    end

    if any(gx(:)~=0)
        this.Variant.Values(:, :, v) = lx + 1i*gx;
    else
        this.Variant.Values(:, :, v) = lx;
    end
    
    % Check for zero log variables
    success(v) = checkZeroLog(this, v) ...
              && all(hasSucceeded(outputInfo.ExitFlags{v}));
    
    % TODO: Report more details on failed equations and variables
    if blazer.Warning && ~success(v)
        throw( exception.Base('Model:SteadyInaccurate', 'warning') );
    end
    
    % Store current values to initialize next parameterisation.
    lx0 = lx;
    gx0 = gx;
    firstAlt = false;
end

if needsRefresh
    this = refresh(this, variantsRequested);
end

% Return status only for parameterizations requested in variantsRequested.
success = success(variantsRequested);

return


    function [lx, gx] = hereInitialize( )
        % __Initialize levels of endogenous quantities__
        lx = real(this.Variant.Values(:, :, v));
        % Level variables that are set to zero (all shocks).
        lx(inxOfZero.Level) = 0;
        % Assign NaN level initial conditions. First, assign values from the
        % previous iteration, if they exist and option 'reuse=' is `true`.
        ix = isnan(lx) & ixEndg.Level;
        if ~firstAlt && blazer.Reuse && any(ix) && ~isempty(lx0)
            lx(ix) = lx0(ix);
            ix = isnan(lx) & ixEndg.Level;
        end
        % Use option NanInit= to assign NaNs.
        lx(ix) = real(blazer.NanInit);
        
        % __Initialize growth rates of endogenous quantities__
        gx = imag(this.Variant.Values(:, :, v));
        % Variables with zero growth (all variables if 'growth=' false).
        gx(inxOfZero.Growth) = 0;
        if any(~inxOfZero.Growth)
            % Assign NaN growth initial conditions. First, assign values from
            % the previous iteration if they exist and `reuse=true`
            ix = isnan(gx) & ixEndg.Growth;
            if ~firstAlt && blazer.Reuse && any(ix) && ~isempty(gx0)
                gx(ix) = gx0(ix);
                ix = isnan(gx) & ixEndg.Growth;
            end
            % Use option NanInit= to assign NaNs.
            gx(ix) = imag(blazer.NanInit);
        end
        % Reset zero growth to 1 for *all* log quantities (not only endogenous).
        gx(inxOfLog & gx==0) = 1;
    end%


    function hereCheckFixedToNaN( )
        numQuantities = length(this.Quantity);
        % __Check for Levels Fixed to NaN__
        idToFix = blazer.IdToFix.Level;
        indexToFix = false(1, numQuantities);
        indexToFix(idToFix) = true;
        indexNaN = any(isnan(steadyLevel), 3) & indexToFix & ~blazer.IxZero.Level;
        if any(indexNaN)
            throw( exception.Base('Steady:LevelFixedToNan', 'error'), ...
                   this.Quantity.Name{indexNaN} );
        end
        % __Check for Growth Rates Fixed to NaN__
        idToFix = blazer.IdToFix.Growth;
        indexToFix = false(1, numQuantities);
        indexToFix(idToFix) = true;
        indexNaN = any(isnan(steadyChange), 3) & indexToFix & ~blazer.IxZero.Growth;
        if any(indexNaN)
            throw( exception.Base('Steady:GrowthFixedToNan', 'error'), ...
                   this.Quantity.Name{indexNaN} );
        end
    end%


    function hereCheckExogenizedToNaN( )
        inxNeeded = any( across(this.Incidence.Steady, 'Shifts'), 1);
        inxNeeded = full(inxNeeded);
        inxOfLevelNeeded = inxNeeded & ~ixEndg.Level & ~inxOfZero.Level;
        inxOfGrowthNeeded = inxNeeded & ~ixEndg.Growth & ~inxOfZero.Growth;
        % Level or growth is endogenous, not fixed, and NaN
        inxOfLevelNaN = any(isnan(steadyLevel), 3);
        inxOfGrowthNaN = any(isnan(steadyChange), 3);
        inxOfLevelToReport = inxOfLevelNeeded & inxOfLevelNaN;
        inxOfGrowthToReport = inxOfGrowthNeeded & inxOfGrowthNaN;
        if any(inxOfLevelToReport)
            throw( exception.Base('Steady:ExogenousLevelNan', 'warning'), ...
                   this.Quantity.Name{inxOfLevelToReport} );
        end
        if any(inxOfGrowthToReport)
            throw( exception.Base('Steady:ExogenousGrowthNan', 'warning'), ...
                   this.Quantity.Name{inxOfGrowthToReport} );
        end
    end%
end%

