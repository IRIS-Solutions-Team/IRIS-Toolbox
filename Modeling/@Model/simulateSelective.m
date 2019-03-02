function exitFlag = simulateSelective(this, simulateFunction, rect, data, needsStoreE, opt)
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
columnRangeOfNonlinAddf = firstColumnOfTimeFrame + (0 : opt.Window-1);
inxOfE = data.InxOfE;
initNlaf = data.NonlinAddf(:, columnRangeOfNonlinAddf);
solverName = opt.Solver.SolverName;

tempE = data.AnticipatedE;
tempE(:, firstColumnOfTimeFrame) = tempE(:, firstColumnOfTimeFrame) ...
                                 + data.UnanticipatedE(:, firstColumnOfTimeFrame);

% No need to simulate measurement equations in iterations (before the
% final run) if there are no exogenized measurement variables
if data.NumOfExogenizedPointsY==0
    rect.SimulateY = false;
end

if any(strcmpi(solverName, {'IRIS-qad', 'IRIS-newton', 'IRIS-qnsd'}))
    % IRIS Solver
    data0 = data;
    initNlaf0 = initNlaf;
    for i = 1 : numel(opt.Solver)
        ithSolver = opt.Solver(i);
        if i>1 && ithSolver.Reset
            data = data0;
            initNlaf = initNlaf0;
        end
        [finalNlaf, dcy, exitFlag] = ...
            solver.algorithm.qnsd(@objectiveFunction, initNlaf, ithSolver);
        if hasSucceeded(exitFlag)
            break
        end
    end
else
    if strcmpi(solverName, 'fsolve')
        % Optimization Tbx
        [finalNlaf, dcy, exitFlag] = fsolve(@objectiveFunction, initNlaf, opt.Solver);
    elseif strcmpi(solverName, 'lsqnonlin')
        % Optimization Tbx
        [finalNlaf, ~, dcy, exitFlag] = lsqnonlin(@objectiveFunction, initNlaf, [ ], [ ], opt.Solver);
    end
    exitFlag = solver.ExitFlag.fromOptimTbx(exitFlag);
end

rect.SimulateY = true;
data.NonlinAddf(:, columnRangeOfNonlinAddf) = finalNlaf; 
simulateFunction(rect, data);

return


    function dcy = objectiveFunction(nlaf)
        data.NonlinAddf(:, columnRangeOfNonlinAddf) = nlaf;
        simulateFunction(rect, data);

        tempYXEPG = data.YXEPG;

        if needsStoreE
            tempE = data.AnticipatedE;
            tempE(:, firstColumnOfTimeFrame) = tempE(:, firstColumnOfTimeFrame) ...
                                             + data.UnanticipatedE(:, firstColumnOfTimeFrame);
        end
        tempYXEPG(inxOfE, :) = tempE;

        if deviation
            tempYX = tempYXEPG(data.InxOfYX, :);
            inxOfLogYX = data.InxOfLog(data.InxOfYX);
            tempYX(~inxOfLogYX, :) = tempYX(~inxOfLogYX, :)  + data.BarYX(~inxOfLogYX, :);
            tempYX(inxOfLogYX, :)  = tempYX(inxOfLogYX, :)  .* data.BarYX(inxOfLogYX, :);
            tempYXEPG(data.InxOfYX, :) = tempYX;
        end
        dcy = hashEquations(tempYXEPG, columnRangeOfNonlinAddf, data.BarYX);
    end%
end%

