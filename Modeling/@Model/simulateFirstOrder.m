function [outputData, outputInfo] = simulateFirstOrder(this, inputData, baseRange, plan, databankInfo, opt)
% simulateFirstOrder  Simulate model using FirstOrder or Selective method
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

nv = this.NumOfVariants;
numOfDataSets = databankInfo.NumOfDataSets;
numOfRuns = max(nv, numOfDataSets);

% Get all data from input databank
baseRange = double(baseRange);
startOfBaseRange = baseRange(1);
endOfBaseRange = baseRange(end);

[~, maxShift] = getActualMinMaxShifts(this);

% Dummy periods
numOfDummyPeriods = opt.Window - 1;
if strcmpi(opt.Method, 'Selective')
    numOfDummyPeriods = numOfDummyPeriods + maxShift;
end
if numOfDummyPeriods>0
    plan = extendWithDummies(plan, numOfDummyPeriods);
end

endOfBaseRangePlusDummy = endOfBaseRange + numOfDummyPeriods;
[YXEPG, ~, extendedRange] = data4lhsmrhs( this, ...
                                          inputData, ...
                                          [startOfBaseRange, endOfBaseRangePlusDummy], ...
                                          'ResetShocks=', true, ...
                                          'IgnoreShocks=', opt.IgnoreShocks, ...
                                          'NumOfDummyPeriods', numOfDummyPeriods );

startOfExtendedRange = extendedRange(1);
firstColumnOfSimulation = round(startOfBaseRange - startOfExtendedRange + 1);
lastColumnOfSimulation = round(endOfBaseRange - startOfExtendedRange + 1); 

% Report missing initial conditions
inxOfNaNPresample = any(isnan(YXEPG(:, 1:firstColumnOfSimulation-1, :)), 3);
checkInitialConditions(this, inxOfNaNPresample, firstColumnOfSimulation);

method = repmat({opt.Method}, 1, numOfRuns);
deviation = repmat(opt.Deviation, 1, numOfRuns);
needsEvalTrends = repmat(opt.EvalTrends, 1, numOfRuns);
if size(YXEPG, 3)==1 && numOfRuns>1
    % Expand number of data sets to match number of parameter variants
    YXEPG = repmat(YXEPG, 1, 1, numOfRuns);
end

if opt.Contributions
    % Prepare contributions and adjust the number of runs; it is guaranteed
    % by now that numOfDataSets==1
    herePrepareContributions( );
end

outputInfo = struct( );
outputInfo.TimeFrames = cell(1, numOfRuns);
outputInfo.BaseRange = [startOfBaseRange, endOfBaseRange];
outputInfo.ExtendedRange = extendedRange([1, end]);
outputInfo.Success = true(1, numOfRuns);
outputInfo.ExitFlags = cell(1, numOfRuns);

for run = 1 : numOfRuns
    if strcmpi(method{run}, 'None')
        continue
    end

    % Set up @simulate.Data from @Model and @Plan, update parameters and
    % steady trends and measurement trends
    vthData = simulate.Data.fromModelAndPlan(this, run, plan, YXEPG, needsEvalTrends(run));
    vthData.FirstColumnOfSimulation = firstColumnOfSimulation;
    vthData.LastColumnOfSimulation = lastColumnOfSimulation;
    vthData.Deviation = deviation(run);
    vthData.Window = opt.Window;

    % Set up @Rectangular object for simulation
    vthRect = simulate.Rectangular.fromModel(this, run);
    vthRect.Deviation = vthData.Deviation;
    vthRect.SimulateY = true;
    vthRect.Method = method{run};
    vthRect.NeedsEvalTrends = vthData.NeedsEvalTrends;

    % Equation-selective specific properties
    if strcmpi(method{run}, 'Selective')
        [vthRect.HashEquationsFunction, vthRect.NumOfHashEquations] = prepareHashEquations(this);
        vthData.NonlinAddf = zeros(vthRect.NumOfHashEquations, vthData.NumOfExtendedPeriods);
    end

    % Retrieve shocks into AnticipatedE and UnanticipatedE properties on
    % the whole range
    retrieveE(vthData);

    % Split simulation range into time frames
    [timeFrames, mixinUnanticipated] = splitIntoTimeFrames(vthData, plan, maxShift, opt);
    vthData.MixinUnanticipated = mixinUnanticipated;

    % Simulate @Rectangular object one timeFrame at a time
    numOfTimeFrames = size(timeFrames, 1);
    needsStoreE = false(1, numOfTimeFrames);
    outputInfo.ExitFlags{run} = repmat(solver.ExitFlag.IN_PROGRESS, 1, numOfTimeFrames);
    for frame = 1 : numOfTimeFrames
        setTimeFrame(vthRect, timeFrames(frame, :));
        setTimeFrame(vthData, timeFrames(frame, :));
        updateSwap(vthData, plan);
        ensureExpansionGivenData(vthRect, vthData);
        if vthData.NumOfExogenizedPoints==0
            simulateFunction = @flat;
        else
            simulateFunction = @swapped;
            needsStoreE(frame) = true;
        end
        if strcmpi(method{run}, 'FirstOrder')
            simulateFunction(vthRect, vthData);
            exitFlag = solver.ExitFlag.LINEAR_SYSTEM;
        elseif strcmpi(method{run}, 'Selective')
            exitFlag = simulateSelective( simulateFunction, ...
                                          vthRect, vthData, needsStoreE(frame), ...
                                          deviation(run), opt );
        end
        outputInfo.ExitFlags{run}(frame) = exitFlag;
    end % frame

    % Update shocks back in YXEPG if needed
    if any(needsStoreE)
        storeE(vthData);
    end

    % Update output data
    YXEPG(:, :, run) = vthData.YXEPG;
    if opt.ReturnNaNIfFailed
        YXEPG(:, firstColumnOfSimulation:lastColumnOfSimulation, run) = NaN;
    end

    % Update output info struct
    outputInfo.TimeFrames{run} = timeFrames;
    outputInfo.Success(run) = all(hasSucceeded(outputInfo.ExitFlags{run}));
end % run

if opt.Contributions
    herePostprocessContributions( );
end

% Reset all data outside the simulation range to NaN except initial
% conditions
hereResetOutsideBaseRange( );

% Convert output data to databank if requested
if strcmpi(opt.OutputData, 'Databank')
    if opt.Contributions
        comments = this.Quantity.Label4ShockContributions;
    else
        comments = this.Quantity.LabelOrName;
    end
    inxToInclude = ~getIndexByType(this.Quantity, TYPE(4));
    outputData = databank.fromDoubleArrayNoFrills( YXEPG(:, 1:lastColumnOfSimulation, :), ...
                                                   this.Quantity.Name, ...
                                                   startOfExtendedRange, ...
                                                   comments, ...
                                                   inxToInclude );
    outputData = addToDatabank('Default', this, outputData);
else
    outputData = YXEPG;
end

return




    function herePrepareContributions( )
        inxOfLog = this.Quantity.InxOfLog;
        inxOfE = getIndexByType(this, TYPE(31), TYPE(32));
        posOfE = find(inxOfE);
        numOfE = nnz(inxOfE);
        numOfRuns = numOfE + 2;
        YXEPG = repmat(YXEPG, 1, 1, numOfRuns);
        % Zero out initial conditions in shock contributions
        YXEPG(inxOfLog, 1:firstColumnOfSimulation-1, 1:numOfE) = 1;
        YXEPG(~inxOfLog, 1:firstColumnOfSimulation-1, 1:numOfE) = 0;
        for i = 1 : numOfE
            temp = YXEPG(posOfE(i), :, i);
            YXEPG(inxOfE, :, i) = 0;
            YXEPG(posOfE(i), :, i) = temp;
        end
        % Zero out all shocks in init+const contributions
        YXEPG(inxOfE, firstColumnOfSimulation:end, end-1) = 0;

        method = cell(1, numOfRuns);
        method(1:end-1) = {'FirstOrder'};
        if strcmpi(opt.Method, 'FirstOrder')
            % Assign zero contributions of nonlinearities right away if
            % this is a first order simulation
            method(end) = {'None'};
            YXEPG(inxOfLog, :, end) = 1;
            YXEPG(~inxOfLog, :, end) = 0;
        else
            method(end) = {'Selective'};
        end
        deviation = true(1, numOfRuns);
        deviation(end-1:end) = opt.Deviation;
        needsEvalTrends = false(1, numOfRuns);
        needsEvalTrends(end-1:end) = opt.EvalTrends;
    end%




    function herePostprocessContributions( )
        inxOfLog = this.Quantity.InxOfLog;
        if strcmpi(opt.Method, 'Selective')
            YXEPG(inxOfLog, :, end) =  YXEPG(inxOfLog, :, end) ...
                                    ./ prod(YXEPG(inxOfLog, :, 1:end-1), 3);
            YXEPG(~inxOfLog, :, end) = YXEPG(~inxOfLog, :, end) ...
                                     - sum(YXEPG(~inxOfLog, :, 1:end-1), 3);
        end
    end%




    function hereResetOutsideBaseRange( )
        inxOfInitInPresample = getInxOfInitInPresample(this, firstColumnOfSimulation);
        for i = 1 : numOfRuns
            temp = YXEPG(:, 1:firstColumnOfSimulation-1, i);
            temp(~inxOfInitInPresample) = NaN;
            YXEPG(:, 1:firstColumnOfSimulation-1, i) = temp;
        end
        YXEPG(:, lastColumnOfSimulation+1:end, :) = NaN;
    end%
end%


%
% Local Functions
%


function [timeFrames, mixinUnanticipated] = splitIntoTimeFrames(data, plan, maxShift, opt)
    inxOfUnanticipatedE = data.UnanticipatedE~=0;
    inxOfUnanticipatedAny = inxOfUnanticipatedE | plan.InxOfUnanticipatedEndogenized;
    posOfUnanticipatedAny = find(any(inxOfUnanticipatedAny, 1));
    if ~any(posOfUnanticipatedAny==data.FirstColumnOfSimulation)
        posOfUnanticipatedAny = [data.FirstColumnOfSimulation, posOfUnanticipatedAny];
    end
    lastAnticipatedExogenizedYX = plan.LastAnticipatedExogenized;
    numOfTimeFrames = numel(posOfUnanticipatedAny);
    timeFrames = nan(numOfTimeFrames, 2);
    for i = 1 : numOfTimeFrames
        startOfTimeFrame = posOfUnanticipatedAny(i);
        if i==numOfTimeFrames
            endOfTimeFrame = data.LastColumnOfSimulation;
        else
            endOfTimeFrame = max([posOfUnanticipatedAny(i+1)-1, lastAnticipatedExogenizedYX]);
        end
        lenOfTimeFrame = endOfTimeFrame - startOfTimeFrame + 1;
        numOfDummyPeriods = 0;
        minLenOfTimeFrame = opt.Window;
        if strcmpi(opt.Method, 'Selective')
            minLenOfTimeFrame = minLenOfTimeFrame + maxShift;
        end
        if lenOfTimeFrame<minLenOfTimeFrame
            numOfDummyPeriods = minLenOfTimeFrame - lenOfTimeFrame;
            endOfTimeFrame = endOfTimeFrame + numOfDummyPeriods;
            lenOfTimeFrame = minLenOfTimeFrame;
        end
        timeFrames(i, :) = [startOfTimeFrame, endOfTimeFrame];
    end
    mixinUnanticipated = false;
end%




function exitFlag = simulateSelective(simulateFunction, rect, data, needsStoreE, deviation, opt)
    hashEquations = rect.HashEquationsFunction;
    firstColumnOfTimeFrame = data.FirstColumnOfTimeFrame;
    columnRangeOfNonlinAddf = firstColumnOfTimeFrame + (0 : opt.Window-1);
    inxOfE = data.InxOfE;
    initNlaf = data.NonlinAddf(:, columnRangeOfNonlinAddf);
    solverName = opt.Solver.SolverName;

    tempE = data.AnticipatedE;
    tempE(:, firstColumnOfTimeFrame) = tempE(:, firstColumnOfTimeFrame) ...
                                     + data.UnanticipatedE(:, firstColumnOfTimeFrame);
     
    if any(strcmpi(solverName, {'IRIS-qad', 'IRIS-newton', 'IRIS-qnsd'}))
        % IRIS Solver
        [finalNlaf, dcy, exitFlag] = solver.algorithm.qnsd(@objectiveFunction, initNlaf, opt.Solver);
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

