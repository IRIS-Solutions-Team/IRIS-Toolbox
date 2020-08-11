function [exitFlag, dcy] = simulateSelective(simulateFunc, rect, data, ~)
% simulateSelective  Run equations-selective simulation on one time frame
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

MAX_DENSITY = 1/3;
MAX_NUM_OF_ELEMENTS = 2e6;

%--------------------------------------------------------------------------

deviation = data.Deviation;
hashEquations = rect.HashEquationsAll;
firstColumnFrame = data.FirstColumnOfFrame;
inxE = data.InxOfE;
inxYX = data.InxOfYX;
numYX = nnz(inxYX);
inxLogYX = data.InxLog(inxYX);
solverOpt = data.SolverOptions;
solverName = solverOpt(1).SolverName;
window = data.Window;

columnRangeHashWindow = firstColumnFrame + (0 : window-1);

tempE = data.AnticipatedE;
tempE(:, firstColumnFrame) = tempE(:, firstColumnFrame) ...
                                 + data.UnanticipatedE(:, firstColumnFrame);

if data.NumOfExogenizedPointsY==0
    %
    % No need to simulate measurement equations in the interim iterations
    % (before the final run) if there are no exogenized measurement
    % variables
    %
    rect.SimulateY = false;
end

objectiveFunction = @hereObjectiveFunctionFull;
%
% Calculate the density of the matrix indicating the variables occurring in
% nonlinear equations; run the multiplier type of simulation only if the
% density is smaller than a cut-off.
%
if data.NumOfExogenizedPoints==0
    hereGetHashIncidence( );
    lastHashedYX = data.LastHashedYX;
    columnRangeOfHashedYX = firstColumnFrame : lastHashedYX;
    inxHashedYX = data.InxOfHashedYX(:, columnRangeOfHashedYX);
    density = nnz(inxHashedYX) / numel(inxHashedYX);
    numElements = nnz(inxHashedYX) * rect.NumOfHashEquations * data.Window;
    if  density<MAX_DENSITY || numElements<MAX_NUM_OF_ELEMENTS
        %
        % Run the nonlinear simulations by precalculating the hash multipliers
        % and calculating the incremental impact of the nonlin addfactors on
        % the affected variables only if the density of the affected
        % variables is less than a threshold; otherwise, the performance is
        % likely to deteriorate rather than improve
        %
        calculateHashMultipliers(rect, data);
        numHashedColumns = numel(columnRangeOfHashedYX);
        simulateFunc(rect, data);
        objectiveFunction = @hereObjectiveFunctionShort;
    end
end

nlafInit = data.NonlinAddf(:, columnRangeHashWindow);

if strncmpi(solverName, 'IRIS', 4)
    % [IrisToolbox] Solver
    data0 = data;
    initNlaf0 = nlafInit;
    for i = 1 : numel(solverOpt)
        ithSolver = solverOpt(i);
        if i>1 && ithSolver.Reset
            data = data0;
            nlafInit = initNlaf0;
        end
        [nlafFinal, dcy, exitFlag] = solver.algorithm.qnsd( ...
            objectiveFunction, nlafInit, ithSolver, rect.Header ...
        );
        if hasSucceeded(exitFlag)
            break
        end
    end

elseif strcmpi(solverName, 'fminsearch')
    % Plain fminsearch
    temp = @(x) sum(power(objectiveFunction(x), 2), [1, 2]);
    [nlafFinal, dcy, exitFlag] = fminsearch(temp, nlafInit, solverOpt);
    if exitFlag==1
        exitFlag = solver.ExitFlag.CONVERGED;
    elseif exitFlag==0
        exitFlag = solver.ExitFlag.MAX_ITER_FUN_EVALS;
    else
        exitFlag = solver.ExitFlag.OBJ_FUN_FAILED;
    end

else
    if strcmpi(solverName, 'fsolve')
        % Optimization Tbx
        [nlafFinal, dcy, exitFlag] = fsolve(objectiveFunction, nlafInit, solverOpt);
    elseif strcmpi(solverName, 'lsqnonlin')
        % Optimization Tbx
        [nlafFinal, ~, dcy, exitFlag] = lsqnonlin(objectiveFunction, nlafInit, [ ], [ ], solverOpt);
    end
    exitFlag = solver.ExitFlag.fromOptimTbx(exitFlag);
end

rect.SimulateY = true;
data.NonlinAddf(:, columnRangeHashWindow) = nlafFinal; 
simulateFunc(rect, data);

return


    function dcy = hereObjectiveFunctionFull(nlaf)
    %(
        data.NonlinAddf(:, columnRangeHashWindow) = nlaf;
        simulateFunc(rect, data);
        YXEPG = data.YXEPG;

        if data.NeedsUpdateShocks
            % The `simulateFunc` modified the shocks and they need to
            % be updated in the main databank
            tempE = data.AnticipatedE;
            tempE(:, firstColumnFrame) = ...
                tempE(:, firstColumnFrame) ...
                + data.UnanticipatedE(:, firstColumnFrame);
        end
        YXEPG(inxE, :) = tempE;

        dcy = hereEvaluateHashEquations(YXEPG);
    %)
    end%




    function dcy = hereObjectiveFunctionShort(nlaf)
    %(
        % Simulated data with zero hash factors
        YXEPG = data.YXEPG;

        % Calculate impact of current hash factors and add them to
        % simulated data
        impact = zeros(numYX, numHashedColumns);
        impact(inxHashedYX) = rect.HashMultipliers * (nlaf(:) - nlafInit(:));
        if any(inxLogYX)
            impact(inxLogYX, :) = exp( impact(inxLogYX, :) );
        end

        tempYX = YXEPG(inxYX, columnRangeOfHashedYX);
        tempYX(~inxLogYX, :) = tempYX(~inxLogYX, :)  + impact(~inxLogYX, :);
        tempYX(inxLogYX, :)  = tempYX(inxLogYX, :)  .* impact(inxLogYX, :);
        YXEPG(inxYX, columnRangeOfHashedYX) = tempYX;

        YXEPG(inxE, :) = tempE;

        dcy = hereEvaluateHashEquations(YXEPG);
    %)
    end%




    function dcy = hereEvaluateHashEquations(YXEPG)
    %(
        yxepg0 = YXEPG;
        if deviation
            yx = YXEPG(inxYX, :);
            yx(~inxLogYX, :) = yx(~inxLogYX, :)  + data.BarYX(~inxLogYX, :);
            yx(inxLogYX, :)  = yx(inxLogYX, :)  .* data.BarYX(inxLogYX, :);
            YXEPG(inxYX, :) = yx;
        end
        try
            dcy = hashEquations(YXEPG, columnRangeHashWindow, data.BarYX);
        catch
            dcy = [ ];
            hereReportError( );
        end
        %if ~all(isfinite(dcy(:))
        %    hereReportNaN( );
        %end
        return

            function hereReportError( )
                numHashEquations = numel(rect.HashEquationsIndividually);
                report = cell.empty(1, 0);
                for i = 1 : numHashEquations
                    try
                        rect.HashEquationsIndividually{i}(YXEPG, columnRangeHashWindow, data.BarYX);
                    catch Err
                        report{1, end+1} = rect.HashEquationsInput{i};
                        report{1, end+1} = Err.message;
                    end
                end
                thisError = [
                    "Model:ErrorEvaluatingHashEquation"
                    "Error evaluating this hash equation: %s \nMatlab reports this error:\n%s\n "
                ];
                throw(exception.Base(thisError, 'error'), report{:});
            end%


            function hereReportNaN( )
            end%
    %)
    end%




    function hereGetHashIncidence( )
    %(
        TYPE = @int8;
        inc = across(rect.HashIncidence, 'Equations');
        inc = inc(inxYX, :);
        shifts = rect.HashIncidence.Shift;
        inxHashedYX = false(numYX, data.NumOfColumns);
        for ii = columnRangeHashWindow
            columnRange = ii + shifts;
            inxHashedYX(:, columnRange) = inxHashedYX(:, columnRange) | inc;
        end
        data.InxOfHashedYX = inxHashedYX;
    %)
    end%
end%

