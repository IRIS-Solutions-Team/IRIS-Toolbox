function simulateTimeFrames(this, runningData, plan, opt)
% simulateTimeFrames  Implement simulation by time frames
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

numOfRuns = size(runningData.YXEPG, 3); 
startOfBaseRange = runningData.BaseRange(1);
endOfBaseRange = runningData.BaseRange(end);
startOfExtendedRange = runningData.ExtendedRange(1);
firstColumnToRun = runningData.BaseRangeColumns(1);
lastColumnToRun = runningData.BaseRangeColumns(end);
maxShift = runningData.MaxShift;

% Prepare and run Blazer and Blocks if this is a Stacked simulation
blazer = herePrepareBlazer( );

method = repmat(opt.Method, 1, numOfRuns);
deviation = repmat(opt.Deviation, 1, numOfRuns);
needsEvalTrends = repmat(opt.EvalTrends, 1, numOfRuns);

if opt.Contributions
    % Prepare contributions and adjust the number of runs; it is guaranteed
    % by now that numOfDataSets==1
    herePrepareContributions( );
end

outputInfo.TimeFrames = cell(1, numOfRuns);
outputInfo.Success = true(1, numOfRuns);
outputInfo.ExitFlags = cell(1, numOfRuns);

for i = 1 : numOfRuns
    if method(i)==solver.Method.NONE
        continue
    end

    % Set up @simulate.Data from @Model and @Plan, update parameters and
    % steady trends and measurement trends
    vthData = simulate.Data.fromModelAndPlan( this, i, plan, ...
                                              runningData.YXEPG, needsEvalTrends(i) );
    vthData.FirstColumnOfSimulation = firstColumnToRun;
    vthData.LastColumnOfSimulation = lastColumnToRun;
    vthData.Window = opt.Window;

    if method(i)==solver.Method.STACKED || method(i)==solver.Method.STATIC
        if deviation(i)
            vthData.YXEPG = addSteadyTrends(vthData, vthData.YXEPG);
            vthData.Deviation = false;
        end
    else
        vthData.Deviation = deviation(i);
    end

    % Set up @Rectangular object for simulation
    vthRect = simulate.Rectangular.fromModel(this, i);
    vthRect.Deviation = vthData.Deviation;
    vthRect.SimulateY = true;
    vthRect.Method = method(i);
    vthRect.NeedsEvalTrends = vthData.NeedsEvalTrends;

    % Equation-selective specific properties
    if method(i)==solver.Method.SELECTIVE
        [ vthRect.HashEquationsFunction, ...
          vthRect.NumOfHashEquations         ] = prepareHashEquations(this);
        vthData.NonlinAddf = zeros(vthRect.NumOfHashEquations, vthData.NumOfExtendedPeriods);
    end

    % Retrieve shocks into AnticipatedE and UnanticipatedE properties on
    % the whole range
    retrieveE(vthData);

    % Split simulation range into time frames
    if method(i)==solver.Method.STATIC
        timeFrames = [firstColumnToRun, lastColumnToRun];
    else
        [timeFrames, mixinUnanticipated] = splitIntoTimeFrames(vthData, plan, maxShift, opt);
        vthData.MixinUnanticipated = mixinUnanticipated;
    end

    % Simulate @Rectangular object one timeFrame at a time
    numOfTimeFrames = size(timeFrames, 1);
    needsStoreE = false(1, numOfTimeFrames);
    runningData.ExitFlags{i} = repmat(solver.ExitFlag.IN_PROGRESS, 1, numOfTimeFrames);
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

        % Choose simulation type
        switch method(i)
            case solver.Method.FIRST_ORDER
                simulateFunction(vthRect, vthData);
                exitFlag = solver.ExitFlag.LINEAR_SYSTEM;
            case solver.Method.SELECTIVE
                exitFlag = simulateSelective( this, simulateFunction, ...
                                              vthRect, vthData, ...
                                              needsStoreE(frame), opt );
            case solver.Method.STACKED
                if strcmpi(opt.Initial, 'FirstOrder')
                    simulateFunction(vthRect, vthData);
                end
                exitFlag = simulateStacked(this, blazer, vthRect, vthData);
            case solver.Method.STATIC
                exitFlag = simulateStatic(this, blazer, vthRect, vthData);
        end
        runningData.ExitFlags{i}(frame) = exitFlag;
    end % frame

    % Update shocks back in YXEPG if needed
    if any(needsStoreE)
        storeE(vthData);
    end

    if method(i)==solver.Method.STACKED || method(i)==solver.Method.STATIC
        if deviation(i)
            vthData.YXEPG = removeSteadyTrends(vthData, vthData.YXEPG);
        end
    end

    % Update output data
    runningData.YXEPG(:, :, i) = vthData.YXEPG;
    if opt.ReturnNaNIfFailed
        runningData.YXEPG(:, firstColumnToRun:lastColumnToRun, i) = NaN;
    end

    % Update output info struct
    runningData.TimeFrames{i} = timeFrames;
    runningData.Success(i) = all(hasSucceeded(runningData.ExitFlags{i}));
end

if opt.Contributions
    herePostprocessContributions( );
end

% Reset all data outside the simulation range to NaN except initial
% conditions
hereResetOutsideBaseRange( );

% Convert output data to databank if requested

return




    function blazer = herePrepareBlazer( )
        switch opt.Method
            case solver.Method.STACKED
                blazer = prepareBlazer(this, 'Stacked', opt);
                run(blazer);
                blazer.ColumnsToRun = firstColumnToRun : lastColumnToRun;
                prepareBlocks(blazer, opt);
            case solver.Method.STATIC
                blazer = prepareBlazer(this, 'Static', opt);
                run(blazer);
                blazer.ColumnsToRun = firstColumnToRun : lastColumnToRun;
                prepareBlocks(blazer, opt);
            otherwise
                blazer = [ ];
        end
    end%




    function herePrepareContributions( )
        inxOfLog = this.Quantity.InxOfLog;
        inxOfE = getIndexByType(this, TYPE(31), TYPE(32));
        posOfE = find(inxOfE);
        numOfE = nnz(inxOfE);
        numOfRuns = numOfE + 2;
        runningData.YXEPG = repmat(runningData.YXEPG, 1, 1, numOfRuns);
        % Zero out initial conditions in shock contributions
        runningData.YXEPG(inxOfLog, 1:firstColumnToRun-1, 1:numOfE) = 1;
        runningData.YXEPG(~inxOfLog, 1:firstColumnToRun-1, 1:numOfE) = 0;
        for ii = 1 : numOfE
            temp = runningData.YXEPG(posOfE(ii), :, ii);
            runningData.YXEPG(inxOfE, :, ii) = 0;
            runningData.YXEPG(posOfE(ii), :, ii) = temp;
        end
        % Zero out all shocks in init+const contributions
        runningData.YXEPG(inxOfE, firstColumnToRun:end, end-1) = 0;

        method = repmat(solver.Method.FIRST_ORDER, 1, numOfRuns);
        if opt.Method==solver.Method.FIRST_ORDER 
            % Assign zero contributions of nonlinearities right away if
            % this is a first order simulation
            method(end) = solver.Method.NONE;
            runningData.YXEPG(inxOfLog, :, end) = 1;
            runningData.YXEPG(~inxOfLog, :, end) = 0;
        else
            method(end) = opt.Method;
        end
        deviation = true(1, numOfRuns);
        deviation(end-1:end) = opt.Deviation;
        needsEvalTrends = false(1, numOfRuns);
        needsEvalTrends(end-1:end) = opt.EvalTrends;
    end%




    function herePostprocessContributions( )
        inxOfLog = this.Quantity.InxOfLog;
        if opt.Method~=solver.Method.FIRST_ORDER
            % Calculate contributions of nonlinearities
            runningData.YXEPG(inxOfLog, :, end) =  runningData.YXEPG(inxOfLog, :, end) ...
                                    ./ prod(runningData.YXEPG(inxOfLog, :, 1:end-1), 3);
            runningData.YXEPG(~inxOfLog, :, end) = runningData.YXEPG(~inxOfLog, :, end) ...
                                     - sum(runningData.YXEPG(~inxOfLog, :, 1:end-1), 3);
        end
    end%




    function hereResetOutsideBaseRange( )
        inxOfInitInPresample = getInxOfInitInPresample(this, firstColumnToRun);
        for ii = 1 : numOfRuns
            temp = runningData.YXEPG(:, 1:firstColumnToRun-1, ii);
            temp(~inxOfInitInPresample) = NaN;
            runningData.YXEPG(:, 1:firstColumnToRun-1, ii) = temp;
        end
        runningData.YXEPG(:, lastColumnToRun+1:end, :) = NaN;
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

