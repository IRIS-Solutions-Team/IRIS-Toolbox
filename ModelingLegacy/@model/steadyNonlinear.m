function  [this, success, outputInfo] = steadyNonlinear(this, blazer, variantsRequested)
% steadyNonlinear  Solve steady equations in nonlinear models
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

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

inxZero = blazer.InxOfZero;

%--------------------------------------------------------------------------

numQuantities = length(this.Quantity);
numBlocks = numel(blazer.Block);
needsRefresh = any(this.Link);
inxP = getIndexByType(this.Quantity, TYPE(4));
inxLogInBlazer = blazer.Model.Quantity.InxOfLog;

% Index of endogenous level and growth quantities
ixEndg = struct( );
ixEndg.Level = false(1, numQuantities);
ixEndg.Growth = false(1, numQuantities);
for i = 1 : numBlocks
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
    outputInfo.ExitFlags{v} = repmat(solver.ExitFlag.IN_PROGRESS, 1, numBlocks);
    for i = 1 : numBlocks
        blk = blazer.Block{i};
        blk.SteadyShift = 3;
        header = sprintf('[Variant:%g][Block:%g]', v, i);
        [lx, gx, exitFlag, error] = run(blk, this.Link, lx, gx, header);
        outputInfo.ExitFlags{v}(i) = exitFlag;
        %{
        if hasFailed(exitFlag)
            fprintf('    Block %g of %g failed to solve.\n', i, numBlocks);
        end
        %}
        if ~isempty(error.EvaluatesToNan)
            throw( ...
                exception.Base('Steady:EvaluatesToNan', 'error'), ...
                this.Equation.Input{error.EvaluatesToNan} ...
            );
        end
    end


    %
    % Remove 1i from parameters with log-status=true
    %
    gx(inxP & inxLogInBlazer) = 0;

    if any(gx(:)~=0)
        this.Variant.Values(:, :, v) = lx + 1i*gx;
    else
        this.Variant.Values(:, :, v) = lx;
    end

    
    % 
    % Check for zero or negative levels or rates of change in variables
    % with log-status=true
    %
    [flagLog, ~, inxInvalidLevel, inxInvalidGrowth] = checkZeroLog(this, v);
    if ~flagLog
        hereInvalidSteady( );
    end


    %
    % Overall success of the v-th variant
    %
    success(v) = flagLog && all(hasSucceeded(outputInfo.ExitFlags{v}));
    

    % TODO: Report more details on failed equations and variables
    if blazer.Warning && ~success(v)
        throw(exception.Base('Model:SteadyInaccurate', 'warning'));
    end
    
    % Store current values to initialize next parameterisation
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
        % Level variables that are set to zero (all shocks)
        lx(inxZero.Level) = 0;
        % Assign NaN level initial conditions. First, assign values from the
        % previous iteration, if they exist and option 'reuse=' is `true`
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
        gx(inxZero.Growth) = 0;
        if any(~inxZero.Growth)
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
        gx(inxLogInBlazer & gx==0) = 1;
    end%




    function hereCheckFixedToNaN( )
        numQuantities = length(this.Quantity);
        % __Check for Levels Fixed to NaN__
        idToFix = blazer.IdToFix.Level;
        indexToFix = false(1, numQuantities);
        indexToFix(idToFix) = true;
        indexNaN = any(isnan(steadyLevel), 3) & indexToFix & ~blazer.IxZero.Level;
        if any(indexNaN)
            throw( ...
                exception.Base('Steady:LevelFixedToNan', 'error'), ...
                this.Quantity.Name{indexNaN} ...
            );
        end
        % __Check for Growth Rates Fixed to NaN__
        idToFix = blazer.IdToFix.Growth;
        indexToFix = false(1, numQuantities);
        indexToFix(idToFix) = true;
        indexNaN = any(isnan(steadyChange), 3) & indexToFix & ~blazer.IxZero.Growth;
        if any(indexNaN)
            throw( ...
                exception.Base('Steady:GrowthFixedToNan', 'error'), ...
                this.Quantity.Name{indexNaN} ...
            );
        end
    end%




    function hereCheckExogenizedToNaN( )
        inxNeeded = any( across(this.Incidence.Steady, 'Shifts'), 1);
        inxNeeded = full(inxNeeded);
        inxLevelNeeded = inxNeeded & ~ixEndg.Level & ~inxZero.Level;
        inxGrowthNeeded = inxNeeded & ~ixEndg.Growth & ~inxZero.Growth;
        % Level or growth is endogenous, not fixed, and NaN
        inxLevelNaN = any(isnan(steadyLevel), 3);
        inxGrowthNaN = any(isnan(steadyChange), 3);
        inxLevelToReport = inxLevelNeeded & inxLevelNaN;
        inxGrowthToReport = inxGrowthNeeded & inxGrowthNaN;
        if any(inxLevelToReport)
            throw( ...
                exception.Base('Steady:ExogenousLevelNan', 'warning'), ...
                this.Quantity.Name{inxLevelToReport} ...
            );
        end
        if any(inxGrowthToReport)
            throw( ...
                exception.Base('Steady:ExogenousGrowthNan', 'warning'), ...
                this.Quantity.Name{inxGrowthToReport} ...
            );
        end
    end%




    function hereInvalidSteady( )
        realValues__ = real(this.Variant.Values(:, :, v));
        imagValues__ = imag(this.Variant.Values(:, :, v));
        realValues__(inxInvalidLevel) = NaN;
        imagValues__(inxInvalidGrowth) = NaN;
        if all(imagValues__==0)
            this.Variant.Values(:, :, v) = realValues__;
        else
            this.Variant.Values(:, :, v) = realValues__ + 1i*imagValues__;
        end
    end%
end%

