function simulateTimeFrames(this, runningData, plan, opt)
% simulateTimeFrames  Implement simulation by time frames
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

nv = length(this);
numOfRuns = size(runningData.YXEPG, 3); 
startOfBaseRange = runningData.BaseRange(1);
endOfBaseRange = runningData.BaseRange(end);
startOfExtendedRange = runningData.ExtendedRange(1);
baseRangeColumns = runningData.BaseRangeColumns;
firstColumnToRun = baseRangeColumns(1);
lastColumnToRun = baseRangeColumns(end);
maxShift = runningData.MaxShift;
blazers = runningData.Blazers;
inxOfInitInPresample = runningData.InxOfInitInPresample;

method = repmat(opt.Method, 1, numOfRuns);
deviation = repmat(opt.Deviation, 1, numOfRuns);
needsEvalTrends = repmat(opt.EvalTrends, 1, numOfRuns);

if opt.Contributions
    % Prepare contributions and adjust the number of runs; it is guaranteed
    % by now that numOfDataSets==1
    herePrepareContributions( );
end

if opt.ProgressInfo
    progressInfo = herePrepareProgressInfo( );
end

for i = 1 : numOfRuns
    %for h = homotopySteps
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
        if i<=nv
            vthRect = simulate.Rectangular.fromModel(this, i);
            vthRect.SparseShocks = opt.SparseShocks;
        end
        vthRect.Deviation = vthData.Deviation;
        vthRect.SimulateY = true;
        vthRect.Method = method(i);
        vthRect.NeedsEvalTrends = vthData.NeedsEvalTrends;

        % Equation-selective specific properties
        if method(i)==solver.Method.SELECTIVE
            prepareHashEquations(this, vthRect, vthData);
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
        vthExitFlags = repmat(solver.ExitFlag.IN_PROGRESS, 1, numOfTimeFrames);
        vthDiscrepancyTables = cell(1, numOfTimeFrames);
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

            % Choose simulation type and run simulation
            [exitFlag, vthDiscrepancyTables{frame}] = hereChooseSimulationTypeAndRun( );
            vthExitFlags(frame) = exitFlag;

            % If the simulation of this time frame fails and the user does not
            % request results from failed simulations, break immediately from
            % the loop and do not continue to the next time frame
            if ~hasSucceeded(exitFlag) && opt.SuccessOnly
                break
            end
        end % frame

        % Overall success
        vthSuccess = all(hasSucceeded(vthExitFlags));
    %end % while homotopy

    % Update shocks back in YXEPG if needed
    if any(needsStoreE)
        storeE(vthData);
    end

    if method(i)==solver.Method.STACKED || method(i)==solver.Method.STATIC
        if deviation(i)
            vthData.YXEPG = removeSteadyTrends(vthData, vthData.YXEPG);
        end
    end
    
    % Fill in NaNs on the entire simulation range if the simulation failed
    % and the user does not request the numbers
    if ~vthSuccess && opt.SuccessOnly
        vthData.YXEPG(:, firstColumnToRun:lastColumnToRun) = NaN;
    end

    % Reset all data outside the simulation range to NaN except the
    % necessary initial conditions
    hereResetOutsideBaseRange( );

    % Update output data and output info
    runningData.YXEPG(:, :, i) = vthData.YXEPG;
    runningData.TimeFrames{i} = timeFrames;
    runningData.ExitFlags{i} = vthExitFlags;
    runningData.Success(i) = vthSuccess;
    runningData.DiscrepancyTables{i} = vthDiscrepancyTables;

    if opt.ProgressInfo
        hereUpdateProgressInfo( );
    end
end % run

if opt.Contributions
    herePostprocessContributions( );
end

return




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




    function progressInfo = herePrepareProgressInfo( )
        oneLiner = true;
        solver = { opt.Solver.Display };
        for i = 1 : numel(solver)
            if ~isequal(solver{i}, false) ...
               && ~strcmpi(solver{i}, 'None') ...
               && ~strcmpi(solver{i}, 'Off')
               oneLiner = false;
               break
            end
        end
        progressInfo = ProgressInfo(numOfRuns, oneLiner);
        update(progressInfo);
    end%




    function hereUpdateProgressInfo( )
        progressInfo.Completed = i;
        progressInfo.Success = nnz(runningData.Success);
        update(progressInfo);
    end%



    function [exitFlag, discrepancyTable] = hereChooseSimulationTypeAndRun( )
        header = sprintf('[Variant %g][TimeFrame %g]', i, frame);
        discrepancy = double.empty(0);
        discrepancyTable = table( );
        switch method(i)
            case solver.Method.NONE
                exitFlag = solver.ExitFlag.NOTHING_TO_SOLVE;
            case solver.Method.FIRST_ORDER
                simulateFunction(vthRect, vthData);
                exitFlag = solver.ExitFlag.LINEAR_SYSTEM;
            case solver.Method.SELECTIVE
                [exitFlag, discrepancy] = simulateSelective( this, simulateFunction, ...
                                                             vthRect, vthData, ...
                                                             needsStoreE(frame), header, opt );
                nonlinearEquations = this.Equation.Input(this.Equation.InxOfHashEquations);
            case solver.Method.STACKED
                if strcmpi(opt.Initial, 'FirstOrder')
                    simulateFunction(vthRect, vthData);
                end
                exitFlag = simulateStacked(this, blazers, vthRect, vthData, header);
            case solver.Method.STATIC
                exitFlag = simulateStatic(this, blazers, vthRect, vthData, header);
        end
        if ~isempty(discrepancy)
            discrepancyTable = compileDiscrepancyTable(this, discrepancy,nonlinearEquations);
        end
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
        temp = vthData.YXEPG(:, 1:firstColumnToRun-1);
        temp(~inxOfInitInPresample) = NaN;
        vthData.YXEPG(:, 1:firstColumnToRun-1) = temp;
        vthData.YXEPG(:, lastColumnToRun+1:end) = NaN;
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




function discrepancyTable = compileDiscrepancyTable(this, discrepancy, equations)
    MAX_STRLENGTH = 50;
    maxInRow = max(abs(discrepancy), [ ], 2);
    [maxInRow, reorderRows] = sort(maxInRow, 1, 'descend');
    discrepancy = discrepancy(reorderRows, :);
    equations = equations(reorderRows);
    equations = string(equations(:));
    inxTooLong = strlength(equations)>MAX_STRLENGTH;
    equations(inxTooLong) = extractBefore(equations(inxTooLong), MAX_STRLENGTH+1);
    ellipsis = iris.get('Ellipsis');
    equations(inxTooLong) = replaceBetween( equations(inxTooLong), ...
                                            MAX_STRLENGTH, MAX_STRLENGTH, ...
                                            ellipsis );
    discrepancyTable = table( equations, maxInRow, discrepancy, ...
                              'VariableNames', {'Equation', 'MaxDiscrepancy', 'Discrepancies'} );
end%

