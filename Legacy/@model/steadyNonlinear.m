% steadyNonlinear  Solve steady equations in nonlinear models
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function  [this, success, outputInfo] = steadyNonlinear(this, variantsRequested, blazer)

nv = countVariants(this);
success = true(1, nv);
outputInfo = struct();
if isequal(blazer, false)
    return
end

if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : nv;
else
    variantsRequested = variantsRequested(:).';
end

outputInfo.ExitFlags = cell(1, nv);
outputInfo.LastJacob = cell(1, nv);
outputInfo.Dimension = cell(1, nv);

inxZero = blazer.InxZero;

numQuantities = numel(this.Quantity);
numBlocks = numel(blazer.Blocks);
needsRefresh = any(this.Link);
inxP = getIndexByType(this.Quantity, 4);
inxLogInBlazer = blazer.Model.Quantity.InxLog;

% Index of endogenous level and change quantities
[inxEndgLevel, inxEndgChange] = here_getInxEndogenous();


if needsRefresh
    this = refresh(this, variantsRequested);
end


%
% Find the largest position of a std or corr on the LHS or RHS in links,
% and include a subvector of StdCorr in levelX and changeX
%
maxStdCorr = 0;
if needsRefresh
    eps = model.Incidence.getIncidenceEps(this.Link.RhsExpn);
    temp = [eps(2, :), reshape(this.Link.LhsPtr, 1, [ ])] - numQuantities;
    maxStdCorr = max([0, temp]);
end


% * Check for levels and growth rate fixed to NaNs
% * Check for NaN in non-endogenous quantities (parameters, exogenous)
steadyLevel = real(this.Variant.Values(:, :, variantsRequested));
steadyChange = imag(this.Variant.Values(:, :, variantsRequested));
steadyLevel(1, inxZero.Level, :) = 0;
steadyChange(1, inxZero.Change, :) = 0;
here_checkFixedToNaN();
here_checkExogenizedToNaN();

levelX0 = [ ];
changeX0 = [ ];
firstRun = true;


%=========================================================================
for v = variantsRequested
    %
    % Initialize steady levels and changes
    % 
    [levelX, changeX] = here_initialize();

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
    outputInfo.LastJacob{v} = cell(1, numBlocks);
    outputInfo.Dimension{v} = cell(1, numBlocks);
    for i = 1 : numBlocks
        blk = blazer.Blocks{i};
        header = sprintf("[Variant:%g][Block:%g]", v, i);
        [levelX, changeX, exitFlag, error, lastJacob, dimension] = run( ...
            blk, this.Link, levelX, changeX, addStdCorr, header ...
        );
        outputInfo.ExitFlags{v}(i) = exitFlag;
        outputInfo.LastJacob{v}{i} = lastJacob;
        outputInfo.Dimension{v}{i} = dimension;
        here_handleErrors();
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
        here_invalidSteady();
    end


    %
    % Overall success of the v-th variant
    %
    success(v) = flagLog && all(hasSucceeded(outputInfo.ExitFlags{v}));


    % TODO: Report more details on failed equations and variables
    if blazer.Warning && ~success(v)
        raise(exception.Base('Model:SteadyInaccurate', 'warning'));
    end

    % Store current values to initialize next parameterisation
    levelX0 = levelX(1:numQuantities);
    changeX0 = changeX(1:numQuantities);
    firstRun = false;
end
%=========================================================================


if needsRefresh
    this = refresh(this, variantsRequested);
end

% Return status only for parameterizations requested in variantsRequested.
success = success(variantsRequested);

% Reset steady state for time trend
posTrendLine = locateTrendLine(this.Quantity, NaN);
this.Variant.Values(1, posTrendLine, :) = complex(0, 1);

return

    function [inxEndgLevel, inxEndgChange] = here_getInxEndogenous()
        %(
        inxEndgLevel = false(1, numQuantities);
        inxEndgChange = false(1, numQuantities);
        for ii = 1 : numBlocks
            [ptrLevel, ptrChange] = iris.utils.splitRealImag(blazer.Blocks{ii}.PtrQuantities);
            inxEndgLevel(ptrLevel) = true;
            inxEndgChange(ptrChange) = true;
        end
        %)
    end%


    function [levelX, changeX] = here_initialize()
        %(
        %
        % Initialize levels of endogenous quantities
        %
        levelX = real(this.Variant.Values(:, :, v));

        % Level variables that are set to zero (all shocks)
        levelX(inxZero.Level) = 0;

        % Assign NaN level initial conditions. First, assign values from the
        % previous iteration, if they exist and option
        % PreviousVariant=true
        inx = isnan(levelX) & inxEndgLevel;
        if ~firstRun && blazer.PreviousVariant && any(inx) && ~isempty(levelX0)
            levelX(inx) = levelX0(inx);
            inx = isnan(levelX) & inxEndgLevel;
        end

        % Use option NanInit= to assign NaN initial conditions 
        levelX(inx) = real(blazer.NanInit);

        % Reset zero levels to 1 for *all* log quantities (not only endogenous)
        levelX(inxLogInBlazer & levelX==0) = 1;

        % levelX(inx & inxLogInBlazer) = real(blazer.NanInit);
        % levelX(inx & ~inxLogInBlazer) = log(real(blazer.NanInit));

        %
        % Initialize growth rates of endogenous quantities
        %
        changeX = imag(this.Variant.Values(:, :, v));
        % Variables with zero growth (all variables if Growth=false).
        changeX(inxZero.Change) = 0;
        if any(~inxZero.Change)
            % Assign NaN growth initial conditions. First, assign values from
            % the previous iteration if they exist and `reuse=true`
            inx = isnan(changeX) & inxEndgChange;
            if ~firstRun && blazer.PreviousVariant && any(inx) && ~isempty(changeX0)
                changeX(inx) = changeX0(inx);
                inx = isnan(changeX) & inxEndgChange;
            end
            % Use option NanInit= to assign NaN.
            changeX(inx) = imag(blazer.NanInit);
        end
        % Reset zero growth to 1 for *all* log quantities (not only endogenous).
        changeX(inxLogInBlazer & changeX==0) = 1;
        %)
    end%


    function here_checkFixedToNaN()
        %(
        [levelsToFix, changesToFix] = iris.utils.splitRealImag(blazer.QuantitiesToFix);

        % Check for levels fixed to NaN
        inxLevelsToFix = false(1, numQuantities);
        inxLevelsToFix(levelsToFix) = true;
        inxNaN = any(isnan(steadyLevel), 3) & inxLevelsToFix;
        if any(inxNaN)
            exception.error([
                "Steady:LevelFixedToNaN"
                "The steady level of this variable is fixed but its value is NaN: %s"
            ], this.Quantity.Name{inxNaN});
        end

        % Check for change rates fixed to NaN
        inxChangesToFix = false(1, numQuantities);
        inxChangesToFix(changesToFix) = true;
        inxNaN = any(isnan(steadyChange), 3) & inxChangesToFix;
        if any(inxNaN)
            exception.error([
                "Steady:LevelFixedToNaN"
                "The steady change of this variable is fixed but its value is NaN: %s"
            ], this.Quantity.Name{inxNaN});
        end
        %)
    end%


    function here_checkExogenizedToNaN()
        %(
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
            raise( ...
                exception.Base('Steady:ExogenousLevelNan', 'warning'), ...
                this.Quantity.Name{inxLevelToReport} ...
            );
        end
        if any(inxChangeToReport)
            raise( ...
                exception.Base('Steady:ExogenousGrowthNan', 'warning'), ...
                this.Quantity.Name{inxChangeToReport} ...
            );
        end
        %)
    end%


    function here_invalidSteady()
        %(
        realValues__ = real(this.Variant.Values(:, :, v));
        imagValues__ = imag(this.Variant.Values(:, :, v));
        realValues__(inxInvalidLevel) = NaN;
        imagValues__(inxInvalidChange) = NaN;
        if all(imagValues__==0)
            this.Variant.Values(:, :, v) = realValues__;
        else
            this.Variant.Values(:, :, v) = realValues__ + 1i*imagValues__;
        end
        %)
    end%


    function here_handleErrors()
        %(
        if hasSucceeded(exitFlag)
            return
        end

        if ~isempty(error.EvaluatesToNan)
            raise( ...
                exception.Base('Steady:EvaluatesToNan', 'error'), ...
                this.Equation.Input{error.EvaluatesToNan} ...
            );
        end

        if ~isempty(error.LogAssignedNonpositive)
            name = string(this.Quantity.Name{error.LogAssignedNonpositive});
            exception.error([
                "Model:SteadyLogAssignedNonpositive"
                "This variable is declared a log-variable "
                "but has been assigned a zero or negative steady value: %s "
            ], name);
        end

        exception.error([ ...
            "Model"
            "This equation failed to solve in steady state: %s"
            ], string(this.Equation.Input(blk.PtrEquations)) ...
        );
        %)
    end%
end%

