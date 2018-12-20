function outputData = simulateFirstOrder(this, inputData, baseRange, plan, opt)
% simulateFirstOrder  Simulate model using FirstOrder or Selective method
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

nv = length(this);

% Get all data from input databank
baseRange = double(baseRange);
startOfBaseRange = baseRange(1);
endOfBaseRange = baseRange(end);

[minShift, maxShift] = getActualMinMaxShifts(this);
numOfDummyPeriods = opt.Window - 1;
if strcmpi(opt.Method, 'Selective')
    numOfDummyPeriods = numOfDummyPeriods + maxShift;
end
endOfBaseRangeWindow = endOfBaseRange + numOfDummyPeriods;
[YXEPG, ~, extendedRange] = data4lhsmrhs( this, ...
                                          inputData, ...
                                          [startOfBaseRange, endOfBaseRangeWindow], ...
                                          'ResetShocks=', true, ...
                                          'NumOfDummyPeriods', numOfDummyPeriods );
if numOfDummyPeriods>0
    plan = extendWithDummies(plan, numOfDummyPeriods);
end

startOfExtendedRange = extendedRange(1);
firstColumnOfSimulation = round(startOfBaseRange - startOfExtendedRange + 1);
lastColumnOfSimulation = round(endOfBaseRange - startOfExtendedRange + 1); 
numOfDataColumns = size(YXEPG, 2);

% Report missing initial conditions
inxOfNaNPresample = any(isnan(YXEPG(:, 1:firstColumnOfSimulation-1, :)), 3);
checkInitialConditions(this, inxOfNaNPresample, firstColumnOfSimulation);

for v = 1 : nv
    % Set up @Rectangular object for simulation
    vthRect = simulate.Rectangular.fromModel(this, v);
    vthRect.Deviation = opt.Deviation;
    vthRect.SimulateY = true;
    vthRect.Method = opt.Method;

    % Set up @simulate.Data from @Model and @Plan and update parameters and steady trends
    vthData = simulate.Data.fromModelAndPlan(this, v, plan, YXEPG);
    vthData.FirstColumnOfSimulation = firstColumnOfSimulation;
    vthData.LastColumnOfSimulation = lastColumnOfSimulation;
    vthData.Deviation = opt.Deviation;
    updateE(vthData);
    if strcmpi(opt.Method, 'Selective')
        vthData.NonlinAddfactors = zeros(vthRect.NumOfHashEquations, vthData.NumOfExtendedPeriods);
    end

    % Split simulation range into time frames
    [timeFrames, mixinUnanticipated] = splitIntoTimeFrames(vthData, plan, maxShift, opt);
    vthData.MixinUnanticipated = mixinUnanticipated;

    % __Switchboard__
    % Simulate @Rectangular object one timeFrame at a time
    numOfTimeFrames = numel(timeFrames);
    for i = 1 : numOfTimeFrames
        setTimeFrame(vthRect, timeFrames{i});
        setTimeFrame(vthData, timeFrames{i});
        updateSwap(vthData, plan);
        ensureExpansionGivenData(vthRect, vthData);
        if vthData.NumOfExogenizedPoints==0
            simulateFunction = @flat;
        else
            simulateFunction = @swapped;
        end
        if strcmpi(opt.Method, 'FirstOrder')
            simulateFunction(vthRect, vthData);
        else
            simulateSelective(simulateFunction, vthRect, vthData, opt);
        end
    end

    % Set all data points in YXEPG in presample and postsample to NaN except intial conditions
    resetOutsideBaseRange(vthData, this);

    % Update output data
    YXEPG(:, :, v) = vthData.YXEPG;
end

% Convert output data to databank if requested
if strcmpi(opt.OutputData, 'Databank')
    names = this.Quantity.Name;
    labels = this.Quantity.Label;
    inxToInclude = ~getIndexByType(this.Quantity, TYPE(4));
    outputData = databank.fromDoubleArrayNoFrills( YXEPG(:, 1:lastColumnOfSimulation, :), ...
                                                   names, ...
                                                   startOfExtendedRange, ...
                                                   labels, ...
                                                   inxToInclude );
    outputData = addToDatabank('Default', this, outputData);
end

end%


%
% Local Functions
%


function [timeFrames, mixinUnanticipated] = splitIntoTimeFrames(data, plan, maxShift, opt)
    [anticipatedE, unanticipatedE] = retrieveE(data);   
    inxOfUnanticipatedE = unanticipatedE~=0;
    posOfUnanticipated = find(any( inxOfUnanticipatedE ...
                                   | plan.InxOfUnanticipatedEndogenized, 1 ));
    if ~any(posOfUnanticipated==data.FirstColumnOfSimulation)
        posOfUnanticipated = [data.FirstColumnOfSimulation, posOfUnanticipated];
    end
    lastAnticipatedExogenizedYX = plan.LastAnticipatedExogenized;
    numOfTimeFrames = numel(posOfUnanticipated);
    timeFrames = cell(1, numOfTimeFrames);
    for i = 1 : numOfTimeFrames
        startOfTimeFrame = posOfUnanticipated(i);
        if i==numOfTimeFrames
            endOfTimeFrame = data.LastColumnOfSimulation;
        else
            endOfTimeFrame = max([posOfUnanticipated(i+1)-1, lastAnticipatedExogenizedYX]);
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
        timeFrames{i} = [startOfTimeFrame, endOfTimeFrame, numOfDummyPeriods];
    end
    mixinUnanticipated = false;
end%




function simulateSelective(simulateFunction, rect, data, opt)
    hashEquations = rect.HashEquationsFunction;
    columnRange = data.FirstColumn+(0 : opt.Window-1);
    initNlaf = data.NonlinAddfactors(:, columnRange);
    solverName = opt.Solver.SolverName;
    if any(strcmpi(solverName, {'IRIS-qad', 'IRIS-newton', 'IRIS-qnsd'}))
        % IRIS Solver
        [finalNlaf, dcy, flag] = solver.algorithm.qnsd(@objectiveFunction, initNlaf, opt.Solver);
    elseif strcmpi(solverName, 'fsolve')
        % Optimization Tbx
        [finalNlaf, dcy, flag] = fsolve(@objectiveFunction, initNlaf, opt.Solver);
    elseif strcmpi(solverName, 'lsqnonlin')
        % Optimization Tbx
        [finalNlaf, ~, dcy, flag] = lsqnonlin(@objectiveFunction, initNlaf, [ ], [ ], opt.Solver);
    end
    return

        function dcy = objectiveFunction(nlaf)
            data.NonlinAddfactors(:, columnRange) = nlaf;
            simulateFunction(rect, data);
            tempYXEPG = data.YXEPG;
            if data.Deviation
                tempYX = tempYXEPG(data.InxOfYX, :);
                inxOfLogYX = data.InxOfLog(data.InxOfYX);
                tempYX(~inxOfLogYX, :) = tempYX(~inxOfLogYX, :)  + data.BarYX(~inxOfLogYX, :);
                tempYX(inxOfLogYX, :)  = tempYX(inxOfLogYX, :)  .* data.BarYX(inxOfLogYX, :);
                tempYXEPG(data.InxOfYX, :) = tempYX;
            end
            dcy = hashEquations(tempYXEPG, columnRange, data.BarYX);
        end%
end%
