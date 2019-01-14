function [outputData, outputInfo] = simulateFirstOrder(this, inputData, baseRange, plan, databankInfo, opt)
% simulateFirstOrder  Simulate model using FirstOrder or Selective method
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

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

endOfBaseRangeWindow = endOfBaseRange + numOfDummyPeriods;
[YXEPG, ~, extendedRange] = data4lhsmrhs( this, ...
                                          inputData, ...
                                          [startOfBaseRange, endOfBaseRangeWindow], ...
                                          'ResetShocks=', true, ...
                                          'NumOfDummyPeriods', numOfDummyPeriods );
startOfExtendedRange = extendedRange(1);
firstColumnOfSimulation = round(startOfBaseRange - startOfExtendedRange + 1);
lastColumnOfSimulation = round(endOfBaseRange - startOfExtendedRange + 1); 

% Report missing initial conditions
inxOfNaNPresample = any(isnan(YXEPG(:, 1:firstColumnOfSimulation-1, :)), 3);
checkInitialConditions(this, inxOfNaNPresample, firstColumnOfSimulation);

% Expand number of data sets to match number of parameter variants
if size(YXEPG, 3)==1 && numOfRuns>1
    YXEPG = repmat(YXEPG, 1, 1, numOfRuns);
end


outputInfo = struct( );
outputInfo.TimeFrames = cell(1, numOfRuns);
outputInfo.BaseRange = [startOfBaseRange, endOfBaseRange];
outputInfo.ExtendedRange = extendedRange([1, end]);

for run = 1 : numOfRuns
    % Set up @Rectangular object for simulation
    vthRect = simulate.Rectangular.fromModel(this, run);
    vthRect.Deviation = opt.Deviation;
    vthRect.SimulateY = true;
    vthRect.Method = opt.Method;

    % Set up @simulate.Data from @Model and @Plan and update parameters and steady trends
    vthData = simulate.Data.fromModelAndPlan(this, run, plan, YXEPG);
    vthData.FirstColumnOfSimulation = firstColumnOfSimulation;
    vthData.LastColumnOfSimulation = lastColumnOfSimulation;
    vthData.Deviation = opt.Deviation;
    vthData.Window = opt.Window;

    % Method=Selective specific properties
    if strcmpi(opt.Method, 'Selective')
        [vthRect.HashEquationsFunction, vthRect.NumOfHashEquations] = prepareHashEquations(model);
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
        if strcmpi(opt.Method, 'FirstOrder')
            simulateFunction(vthRect, vthData);
        elseif strcmpi(opt.Method, 'Selective')
            simulateSelective(simulateFunction, vthRect, vthData, needsStoreE(frame), opt);
        end
    end % frame

    % Update shocks back in YXEPG if needed
    if any(needsStoreE)
        storeE(vthData);
    end

    % Set all data points in YXEPG in presample and postsample to NaN except intial conditions
    resetOutsideBaseRange(vthData, this);

    % Update output data
    YXEPG(:, :, run) = vthData.YXEPG;

    % Update output info struct
    outputInfo.TimeFrames{run} = timeFrames;
end % run

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




function simulateSelective(simulateFunction, rect, data, needsStoreE, opt)
    hashEquations = rect.HashEquationsFunction;
    firstColumnOfTimeFrame = data.FirstColumnOfTimeFrame;
    columnRangeOfNonlinAddf = firstColumnOfTimeFrame + (0 : opt.Window-1);
    inxOfE = data.InxOfE;
    initNlaf = data.NonlinAddf(:, columnRangeOfNonlinAddf);
    solverName = opt.Solver.SolverName;
    deviation = opt.Deviation;

    tempE = data.AnticipatedE;
    tempE(:, firstColumnOfTimeFrame) = tempE(:, firstColumnOfTimeFrame) ...
                                     + data.UnanticipatedE(:, firstColumnOfTimeFrame);
     
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
            dcy = hashEquations(tempYXEPG, columnRangeOfNonlinAddf, []);%data.BarYX);
        end%
end%

