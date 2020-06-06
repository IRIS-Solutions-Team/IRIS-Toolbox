function  [this, success, outputInfo] = steadyNonlinear(this, blazer, variantsRequested)
% steadyNonlinear  Solve steady equations in nonlinear models
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

nv = countVariants(this);
if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : nv;
else
    variantsRequested = variantsRequested(:).';
end
success = true(1, nv);
outputInfo = struct( ...
    'ExitFlags', solver.ExitFlag.empty(0), ...
    'Blazer', blazer ...
);

if isequal(blazer, false)
    return
end

inxZero = blazer.InxZero;

%--------------------------------------------------------------------------

numQuantities = numel(this.Quantity);
numBlocks = numel(blazer.Blocks);
needsRefresh = any(this.Link);
inxP = getIndexByType(this.Quantity, TYPE(4));
inxLogInBlazer = blazer.Model.Quantity.InxLog;

% Index of endogenous level and change quantities
[inxEndgLevel, inxEndgChange] = hereGetInxEndogenous( );


if needsRefresh
    this = refresh(this, variantsRequested);
end


%
% Find the largest position of a std or corr on the LHS or RHS in links,
% and include a subvector of StdCorr in levelX and changeX
%
maxStdCorr = 0;
if needsRefresh
    eps = model.component.Incidence.getIncidenceEps(this.Link.RhsExpn);
    temp = [eps(:, 2); reshape(this.Link.LhsPtr, [ ], 1)] - numQuantities;
    maxStdCorr = max([0; temp]);
end


% * Check for levels and growth rate fixed to NaNs
% * Check for NaN in non-endogenous quantities (parameters, exogenous)
steadyLevel = real(this.Variant.Values(:, :, variantsRequested));
steadyChange = imag(this.Variant.Values(:, :, variantsRequested));
hereCheckFixedToNaN( );
hereCheckExogenizedToNaN( );

levelX0 = [ ];
changeX0 = [ ];
firstRun = true;


% /////////////////////////////////////////////////////////////////////////
outputInfo.ExitFlags = cell(1, nv);
for v = variantsRequested
    [levelX, changeX] = hereInitialize( );

    
    %
    % Add a minimum necessary subvector of StdCorr
    %
    addStdCorr = double.empty(1, 0);
    if maxStdCorr>0
        addStdCorr = this.Variant.StdCorr(:, 1:maxStdCorr, v);
    end


    %
    % Cycle over individual blocks
    %
    outputInfo.ExitFlags{v} = repmat(solver.ExitFlag.IN_PROGRESS, 1, numBlocks);
    for i = 1 : numBlocks
        blk = blazer.Blocks{i};
        blk.SteadyShift = 3;
        header = sprintf("[Variant:%g][Block:%g]", v, i);
        [levelX, changeX, exitFlag, error] = run( ...
            blk, this.Link, levelX, changeX, addStdCorr, header ...
        );
        outputInfo.ExitFlags{v}(i) = exitFlag;
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
    changeX(inxP & inxLogInBlazer) = 0;

    if any(changeX(:)~=0)
        this.Variant.Values(:, :, v) = levelX + 1i*changeX;
    else
        this.Variant.Values(:, :, v) = levelX;
    end

    
    % 
    % Check for zero or negative levels or rates of change in variables
    % with log-status=true
    %
    [flagLog, ~, inxInvalidLevel, inxInvalidChange] = checkZeroLog(this, v);
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
    levelX0 = levelX(1:numQuantities);
    changeX0 = changeX(1:numQuantities);
    firstRun = false;
end
% /////////////////////////////////////////////////////////////////////////


if needsRefresh
    this = refresh(this, variantsRequested);
end

% Return status only for parameterizations requested in variantsRequested.
success = success(variantsRequested);

return


    function [inxEndgLevel, inxEndgChange] = hereGetInxEndogenous( )
        inxEndgLevel = false(1, numQuantities);
        inxEndgChange = false(1, numQuantities);
        for ii = 1 : numBlocks
            [ptrLevel, ptrChange] = iris.utils.splitRealImag(blazer.Blocks{ii}.PtrQuantities);
            inxEndgLevel(ptrLevel) = true;
            inxEndgChange(ptrChange) = true;
        end
    end%




    function [levelX, changeX] = hereInitialize( )
        % __Initialize levels of endogenous quantities__
        levelX = real(this.Variant.Values(:, :, v));
        % Level variables that are set to zero (all shocks)
        levelX(inxZero.Level) = 0;
        % Assign NaN level initial conditions. First, assign values from the
        % previous iteration, if they exist and option 'reuse=' is `true`
        inx = isnan(levelX) & inxEndgLevel;
        if ~firstRun && blazer.Reuse && any(inx) && ~isempty(levelX0)
            levelX(inx) = levelX0(inx);
            inx = isnan(levelX) & inxEndgLevel;
        end
        % Use option NanInit= to assign NaNs.
        levelX(inx) = real(blazer.NanInit);
        
        % __Initialize growth rates of endogenous quantities__
        changeX = imag(this.Variant.Values(:, :, v));
        % Variables with zero growth (all variables if 'growth=' false).
        changeX(inxZero.Change) = 0;
        if any(~inxZero.Change)
            % Assign NaN growth initial conditions. First, assign values from
            % the previous iteration if they exist and `reuse=true`
            inx = isnan(changeX) & inxEndgChange;
            if ~firstRun && blazer.Reuse && any(inx) && ~isempty(changeX0)
                changeX(inx) = changeX0(inx);
                inx = isnan(changeX) & inxEndgChange;
            end
            % Use option NanInit= to assign NaNs.
            changeX(inx) = imag(blazer.NanInit);
        end
        % Reset zero growth to 1 for *all* log quantities (not only endogenous).
        changeX(inxLogInBlazer & changeX==0) = 1;
    end%




    function hereCheckFixedToNaN( )
        [levelToExclude, changeToExclude] = iris.utils.splitRealImag(blazer.QuantitiesToExclude);

        % Check for levels fixed to NaN
        inxToExclude = false(1, numQuantities);
        inxToExclude(levelToExclude) = true;
        inxNaN = any(isnan(steadyLevel), 3) & inxToExclude & ~inxZero.Level;
        if any(inxNaN)
            throw( ...
                exception.Base('Steady:LevelFixedToNan', 'error'), ...
                this.Quantity.Name{inxNaN} ...
            );
        end

        % Check for change rates fixed to NaN
        inxToExclude = false(1, numQuantities);
        inxToExclude(changeToExclude) = true;
        inxNaN = any(isnan(steadyChange), 3) & inxToExclude & ~inxZero.Change;
        if any(inxNaN)
            throw( ...
                exception.Base('Steady:GrowthFixedToNan', 'error'), ...
                this.Quantity.Name{inxNaN} ...
            );
        end
    end%




    function hereCheckExogenizedToNaN( )
        inxNeeded = any( across(this.Incidence.Steady, 'Shifts'), 1);
        inxNeeded = full(inxNeeded);
        inxLevelNeeded = inxNeeded & ~inxEndgLevel & ~inxZero.Level;
        inxChangeNeeded = inxNeeded & ~inxEndgChange & ~inxZero.Change;
        % Level or growth is endogenous, not fixed, and NaN
        inxLevelNaN = any(isnan(steadyLevel), 3);
        inxChangeNaN = any(isnan(steadyChange), 3);
        inxLevelToReport = inxLevelNeeded & inxLevelNaN;
        inxChangeToReport = inxChangeNeeded & inxChangeNaN;
        if any(inxLevelToReport)
            throw( ...
                exception.Base('Steady:ExogenousLevelNan', 'warning'), ...
                this.Quantity.Name{inxLevelToReport} ...
            );
        end
        if any(inxChangeToReport)
            throw( ...
                exception.Base('Steady:ExogenousGrowthNan', 'warning'), ...
                this.Quantity.Name{inxChangeToReport} ...
            );
        end
    end%




    function hereInvalidSteady( )
        realValues__ = real(this.Variant.Values(:, :, v));
        imagValues__ = imag(this.Variant.Values(:, :, v));
        realValues__(inxInvalidLevel) = NaN;
        imagValues__(inxInvalidChange) = NaN;
        if all(imagValues__==0)
            this.Variant.Values(:, :, v) = realValues__;
        else
            this.Variant.Values(:, :, v) = realValues__ + 1i*imagValues__;
        end
    end%
end%

