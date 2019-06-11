function [exitFlag, dcy] = simulateSelective( this, simulateFunction, ...
                                              rect, data, needsStoreE, header, ...
                                              solverOptions, window )
% simulateSelective  Run equations-selective simulation on one time frame
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

deviation = data.Deviation;
hashEquations = rect.HashEquationsFunction;
firstColumnOfTimeFrame = data.FirstColumnOfTimeFrame;
inxOfE = data.InxOfE;
inxOfYX = data.InxOfYX;
numOfYX = nnz(inxOfYX);
inxOfLogYX = data.InxOfLog(inxOfYX);
solverName = solverOptions(1).SolverName;

columnRangeOfHashFactors = firstColumnOfTimeFrame + (0 : window-1);

tempE = data.AnticipatedE;
tempE(:, firstColumnOfTimeFrame) = tempE(:, firstColumnOfTimeFrame) ...
                                 + data.UnanticipatedE(:, firstColumnOfTimeFrame);

% No need to simulate measurement equations in iterations (before the
% final run) if there are no exogenized measurement variables
if data.NumOfExogenizedPointsY==0
    rect.SimulateY = false;
    hereGetHashIncidence( );
    calculateHashMultipliers(rect, data);
    lastHashedYX = data.LastHashedYX;
    columnRangeOfHashedYX = firstColumnOfTimeFrame : lastHashedYX;
    inxOfHashedYX = data.InxOfHashedYX(:, columnRangeOfHashedYX);
    numOfHashedColumns = numel(columnRangeOfHashedYX);
    simulateFunction(rect, data);
    objectiveFunction = @objectiveFunctionShort;
else
    objectiveFunction = @objectiveFunctionFull;
end

initNlaf = data.NonlinAddf(:, columnRangeOfHashFactors);

if strncmpi(solverName, 'IRIS', 4)
    % IRIS Solver
    data0 = data;
    initNlaf0 = initNlaf;
    for i = 1 : numel(solverOptions)
        ithSolver = solverOptions(i);
        if i>1 && ithSolver.Reset
            data = data0;
            initNlaf = initNlaf0;
        end
        [finalNlaf, dcy, exitFlag] = ...
            solver.algorithm.qnsd(objectiveFunction, initNlaf, ithSolver, header);
        if hasSucceeded(exitFlag)
            break
        end
    end
else
    if strcmpi(solverName, 'fsolve')
        % Optimization Tbx
        [finalNlaf, dcy, exitFlag] = fsolve(objectiveFunction, initNlaf, solverOptions);
    elseif strcmpi(solverName, 'lsqnonlin')
        % Optimization Tbx
        [finalNlaf, ~, dcy, exitFlag] = lsqnonlin(objectiveFunction, initNlaf, [ ], [ ], solverOptions);
    end
    exitFlag = solver.ExitFlag.fromOptimTbx(exitFlag);
end

rect.SimulateY = true;
data.NonlinAddf(:, columnRangeOfHashFactors) = finalNlaf; 
simulateFunction(rect, data);

return




    function dcy = objectiveFunctionFull(nlaf)
        data.NonlinAddf(:, columnRangeOfHashFactors) = nlaf;
        simulateFunction(rect, data);
        tempYXEPG = data.YXEPG;

        if needsStoreE
            tempE = data.AnticipatedE;
            tempE(:, firstColumnOfTimeFrame) = tempE(:, firstColumnOfTimeFrame) ...
                                             + data.UnanticipatedE(:, firstColumnOfTimeFrame);
        end
        tempYXEPG(inxOfE, :) = tempE;

        if deviation
            tempYX = tempYXEPG(inxOfYX, :);
            tempYX(~inxOfLogYX, :) = tempYX(~inxOfLogYX, :)  + data.BarYX(~inxOfLogYX, :);
            tempYX(inxOfLogYX, :)  = tempYX(inxOfLogYX, :)  .* data.BarYX(inxOfLogYX, :);
            tempYXEPG(inxOfYX, :) = tempYX;
        end
        dcy = hashEquations(tempYXEPG, columnRangeOfHashFactors, data.BarYX);
    end%




    function dcy = objectiveFunctionShort(nlaf)
        % Simulated data with zero hash factors
        tempYXEPG = data.YXEPG;

        % Calculate impact of current hash factors and add them to
        % simulated data
        impact = zeros(numOfYX, numOfHashedColumns);
        impact(inxOfHashedYX) = rect.HashMultipliers * (nlaf(:) - initNlaf(:));
        if any(inxOfLogYX)
            impact(inxOfLogYX, :) = exp( impact(inxOfLogYX, :) );
        end

        tempYX = tempYXEPG(inxOfYX, columnRangeOfHashedYX);
        tempYX(~inxOfLogYX, :) = tempYX(~inxOfLogYX, :)  + impact(~inxOfLogYX, :);
        tempYX(inxOfLogYX, :)  = tempYX(inxOfLogYX, :)  .* impact(inxOfLogYX, :);
        tempYXEPG(inxOfYX, columnRangeOfHashedYX) = tempYX;

        %{
        if needsStoreE
            tempE = data.AnticipatedE;
            tempE(:, firstColumnOfTimeFrame) = tempE(:, firstColumnOfTimeFrame) ...
                                             + data.UnanticipatedE(:, firstColumnOfTimeFrame);
        end
        %}
        tempYXEPG(inxOfE, :) = tempE;

        if deviation
            tempYX = tempYXEPG(inxOfYX, :);
            tempYX(~inxOfLogYX, :) = tempYX(~inxOfLogYX, :)  + data.BarYX(~inxOfLogYX, :);
            tempYX(inxOfLogYX, :)  = tempYX(inxOfLogYX, :)  .* data.BarYX(inxOfLogYX, :);
            tempYXEPG(inxOfYX, :) = tempYX;
        end
        dcy = hashEquations(tempYXEPG, columnRangeOfHashFactors, data.BarYX);
    end%




    function hereGetHashIncidence( )
        TYPE = @int8;
        inc = across(rect.HashIncidence, 'Equations');
        inc = inc(inxOfYX, :);
        shifts = rect.HashIncidence.Shift;
        inxOfHashedYX = false(numOfYX, data.NumOfExtendedPeriods);
        for ii = columnRangeOfHashFactors
            columnRange = ii + shifts;
            inxOfHashedYX(:, columnRange) = inxOfHashedYX(:, columnRange) | inc;
        end
        data.InxOfHashedYX = inxOfHashedYX;
    end%
end%

