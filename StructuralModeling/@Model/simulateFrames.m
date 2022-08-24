function [prepared, outputYXEPG] = simulateFrames(this, systemProperty, run, prepareOnly)

if nargin<4
    prepareOnly = false;
end

runningData = systemProperty.CallerData;
method = runningData.Method(min(run, end));

prepared = [];
outputYXEPG = [];


%
% True if this is a regular call from @Model.simulate; false if this is a
% SystemProperty preparation
%
isRegularCall = systemProperty.NumOfOutputs==0;

baseRangeColumns = runningData.BaseRangeColumns;
firstColumnToRun = baseRangeColumns(1);
lastColumnToRun = baseRangeColumns(end);
inxInitInPresample = runningData.InxOfInitInPresample;
plan = runningData.Plan;

%
% If the solver is NONE, clip the potential presample and postsample data
% in the respective page of the runningData and return immediately
%
if isequal(method, solver.Method.NONE)
    outputYXEPG = local_resetOutsideBaseRange( ...
        runningData.YXEPG(:, :, run), firstColumnToRun:lastColumnToRun, inxInitInPresample ...
    );
    return
end

%
% Set up @simulate.Data from @Model and @Plan, remove measurement trends,
% fill in parameters, steady trends.
%
data = simulate.Data.fromModelAndPlan(this, run, plan, runningData);
data.IgnoreShocks = needsIgnoreShocks(method);

if ~data.Deviation
    data.YXEPG = removeMeasurementTrends(data, data.YXEPG);
end

resetDeviation = data.Deviation;
if data.Deviation && (method==solver.Method.STACKED || method==solver.Method.PERIOD)
    data.YXEPG = addSteadyTrends(data, data.YXEPG);
    data.Deviation = false;
end
preserveTargetValues(data);


% Set up @Rectangular object for simulation
flag = needsFirstOrderSolution( ...
    method, this, runningData.DefaultBlazer.StartIterationsFrom, runningData.DefaultBlazer.Terminal ...
);
rect = simulate.Rectangular.fromModel(this, run, flag);
rect.SparseShocks = runningData.SparseShocks;
rect.Deviation = data.Deviation;
rect.SimulateY = true;
rect.Method = method;
rect.PlanMethod = plan.Method;

%
% Equation-selective specific properties
%
if method==solver.Method.SELECTIVE
    % Prepare hash equations
    [  ...
        rect.HashEquationsAll, ...
        rect.HashEquationsIndividually, ...
        rect.HashEquationsInput, ...
        rect.HashIncidence ...
    ] = prepareHashEquations(this);

    % Reset nonlin add factor array
    numHashEquations = numel(rect.HashEquationsIndividually);
    data.NonlinAddf = zeros(numHashEquations, data.NumColumns);
end

% Split shocks into AnticipatedE and UnanticipatedE properties on
% the whole simulation range
% retrieveE(data);
[data.AnticipatedE, data.UnanticipatedE] = ...
    simulate.Data.splitE(data.YXEPG, data.InxAnticipatedE, data.InxUnanticipatedE, baseRangeColumns);

% Retrieve frames
framesFromTo = runningData.FrameColumns{min(run, end)};
data.MixinUnanticipated = runningData.MixinUnanticipated(min(run, end));

% Simulate @Rectangular object one timeFrame at a time
numFrames = size(framesFromTo, 1);
needsUpdateShocks = false;
exitFlags = repmat(solver.ExitFlag.IN_PROGRESS, 1, numFrames);
discrepancyTables = cell(1, numFrames);


% 
% Simulate individual frammes
%

%===========================================================================
for frame = 1 : numFrames
    setFrame(rect, framesFromTo(frame, :));
    setFrame(data, framesFromTo(frame, :));
    updateSwapsFromPlan(data, plan);
    if ~data.MixinUnanticipated
        updateShocksWithinFrame(data);
    end
    ensureExpansionGivenData(rect, data);

    %
    % Chose first-order simulation function; this is used within nonlinear
    % methods as well; in STACKED and PERIOD, run plain vanilla flat
    % simulations ignoring shocks; the value of simulateFirstOrderFunc is
    % ignored in them
    %
    if ~data.HasExogenizedYX 
        simulateFirstOrderFunc = @flat;
    else
        simulateFirstOrderFunc = @swapped; 
    end

    %
    % Choose simulation type and run simulation
    %
    data.NeedsUpdateShocks = false;
    rect.Header = sprintf("[Variant|Page:%g][Frame:%g]", run, frame);
    func = simulateFunction(method);

    blazer = local_prepareBlazer(this, runningData, framesFromTo(frame, :), data);

    if prepareOnly
        %
        % Prepare only the first-frame simulation for preparation calls
        % from the Kalman filter, and return immediately
        %
        prepared = {func, simulateFirstOrderFunc, rect, data, blazer};
        return
    end

    %
    % Enter simulation function
    %
    [exitFlag, dcy] = func(simulateFirstOrderFunc, rect, data, blazer, frame);

    exitFlags(frame) = exitFlag;
    if ~isempty(dcy) && runningData.PrepareOutputInfo
        dcyTable = local_compileDiscrepancyTable( ...
            this, dcy, ...
            this.Equation.Input(this.Equation.InxHashEquations) ...
        );
        discrepancyTables{frame} = dcyTable;
    end
    needsUpdateShocks = needsUpdateShocks | data.NeedsUpdateShocks;

    % If the simulation of this frame fails and the user does not
    % request results from failed simulations, break immediately from
    % the loop and do not continue to the next frame
    if ~hasSucceeded(exitFlag) && runningData.SuccessOnly
        if frame<numFrames
            fprintf( ...
                "Leaving prematurely because SuccessOnly=true. Frames %g:%g not executed.\n" ...
                , frame+1, numFrames ...
            );
        end
        break
    end

    if runningData.PrepareFrameData
        YXEPG__ = data.YXEPG;
        columnsToRun = data.FirstColumnFrame : data.LastColumnFrame;
        YXEPG__ = local_resetOutsideBaseRange(YXEPG__, columnsToRun, inxInitInPresample);
        runningData.FrameData{run}.YXEPG(:, :, end+1) = YXEPG__;
    end
end
%===========================================================================


% Overall success
success = all(hasSucceeded(exitFlags));

% Update shocks back in YXEPG if needed
if any(needsUpdateShocks)
    storeE(data);
end

data.Deviation = resetDeviation;
if data.Deviation && (method==solver.Method.STACKED || method==solver.Method.PERIOD)
    data.YXEPG = removeSteadyTrends(data, data.YXEPG);
end

if ~data.Deviation
    data.YXEPG = addMeasurementTrends(data, data.YXEPG);
end

%
% Fill in NaNs on the entire simulation range if the simulation failed
% and the user does not request the numbers
%
if ~success && runningData.SuccessOnly
    data.YXEPG(:, firstColumnToRun:lastColumnToRun) = NaN;
end

%
% Reset all data outside the simulation range to NaN except the
% necessary initial conditions
%
data.YXEPG = local_resetOutsideBaseRange( ...
    data.YXEPG, firstColumnToRun:lastColumnToRun, inxInitInPresample ...
);

if isRegularCall
    % This is a call from @Model.simulate
    % Return the data.YXEPG array and update runningData.YXEPG only in
    % Model/simulate; this is much faster than updating it in place
    outputYXEPG = data.YXEPG;
    runningData.Success(run) = success;
    if runningData.PrepareOutputInfo
        runningData.FrameColumns{run} = framesFromTo;
        runningData.ExitFlags{run} = exitFlags;
        runningData.DiscrepancyTables{run} = discrepancyTables;
    end
else
    % This is a call from @SystemPriorWrapper
    % Create system property output
    systemProperty.Outputs{1} = data.YXEPG(:, baseRangeColumns);
end

end%

%
% Local functions
%

function dcyTable = local_compileDiscrepancyTable(~, discrepancy, equations)
    %(
    MAX_STRLENGTH = 50;
    ELLIPSIS = char(8230);

    maxInRow = max(abs(discrepancy), [ ], 2);
    [maxInRow, reorderRows] = sort(maxInRow, 1, 'descend');
    discrepancy = discrepancy(reorderRows, :);
    equations = equations(reorderRows);
    equations = equations(:);
    inxTooLong = cellfun(@(x) length(x)>MAX_STRLENGTH, equations);
    equations(inxTooLong) = cellfun( ...
        @(x) [x(1:MAX_STRLENGTH-1), char(ELLIPSIS)] ...
        , equations(inxTooLong) ...
        , 'UniformOutput', false ...
    );
    dcyTable = table( ...
        equations, maxInRow, discrepancy ...
        , 'VariableNames', {'Equation', 'MaxDiscrepancy', 'Discrepancies'} ...
    );
    %)
end%


function blazer = local_prepareBlazer(~, runningData, frameFromTo, data)
    %(
    if isa(runningData.DefaultBlazer, 'solver.blazer.FirstOrder')
        blazer = [ ];
        return
    end

    if ~data.HasExogenizedYX || ~runningData.DefaultBlazer.IsBlocks
        blazer = runningData.DefaultBlazer;
        setFrame(blazer, frameFromTo);
        prepareForSolver(blazer, runningData.SolverOptions, data);
    else
        blazer = runningData.ExogenizedBlazer;
        run(blazer, data);
        setFrame(blazer, frameFromTo);
        prepareForSolver(blazer, runningData.SolverOptions, data);
    end
    %)
end%


function YXEPG = local_resetOutsideBaseRange(YXEPG, columnsToRun, inxInitInPresample)
    %(
    numQuantities = size(YXEPG, 1);
    numColumnsPresample = size(inxInitInPresample, 2);
    numColumnsBeforePresample = columnsToRun(1) - numColumnsPresample - 1;
    beforePresample = nan(numQuantities, numColumnsBeforePresample);
    if numColumnsPresample>0
        presample = YXEPG(:, columnsToRun(1)-numColumnsPresample:columnsToRun(1)-1);
        presample(~inxInitInPresample) = NaN;
    else
        presample = nan(numQuantities, 0);
    end
    YXEPG(:, 1:columnsToRun(1)-1) = [beforePresample, presample];
    YXEPG(:, columnsToRun(end)+1:end) = NaN;
    %)
end%

