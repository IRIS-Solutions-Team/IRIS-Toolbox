function prepared = simulateTimeFrames(this, systemProperty, run, prepareOnly)
% simulateTimeFrames  Implement simulation by time frames
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;
if nargin<4
    prepareOnly = false;
end

%--------------------------------------------------------------------------

runningData = systemProperty.Specifics;
isAsynchronous = runningData.IsAsynchronous;

% Regular call from @Model.simulate
regularCall = systemProperty.NumOfOutputs==0;

nv = length(this);
numRuns = size(runningData.YXEPG, 3); 
baseRangeColumns = runningData.BaseRangeColumns;
firstColumnToRun = baseRangeColumns(1);
lastColumnToRun = baseRangeColumns(end);
maxShift = runningData.MaxShift;
blazers = runningData.Blazers;
inxInitInPresample = runningData.InxOfInitInPresample;
plan = runningData.Plan;

method = runningData.Method(min(run, end));
deviation = runningData.Deviation(min(run, end));
needsEvalTrends = runningData.NeedsEvalTrends(min(run, end));

% Set up @simulate.Data from @Model and @Plan, update parameters and
% steady trends and measurement trends
vthData = simulate.Data.fromModelAndPlan(this, run, plan, runningData);
vthData.FirstColumnOfSimulation = firstColumnToRun;
vthData.LastColumnOfSimulation = lastColumnToRun;
vthData.Window = runningData.Window;
vthData.Initial = runningData.Initial;
vthData.SolverOptions = runningData.SolverOptions;

if method==solver.Method.STACKED || method==solver.Method.STATIC
    if deviation
        vthData.YXEPG = addSteadyTrends(vthData, vthData.YXEPG);
        vthData.Deviation = false;
    end
else
    vthData.Deviation = deviation;
end

% Set up @Rectangular object for simulation
vthRect = simulate.Rectangular.fromModel(this, run);
vthRect.SparseShocks = runningData.SparseShocks;
vthRect.Deviation = vthData.Deviation;
vthRect.SimulateY = true;
vthRect.Method = method;
vthRect.PlanMethod = plan.Method;
vthRect.NeedsEvalTrends = vthData.NeedsEvalTrends;

% Equation-selective specific properties
if method==solver.Method.SELECTIVE
    prepareHashEquations(this, vthRect, vthData);
end

% Split shocks into AnticipatedE and UnanticipatedE properties on
% the whole simulation range
% retrieveE(vthData);
[ vthData.AnticipatedE, ...
  vthData.UnanticipatedE ] = simulate.Data.splitE( vthData.E, ...
                                                   vthData.AnticipationStatusOfE, ...
                                                   baseRangeColumns );

% Retrieve time frames
timeFrames = runningData.TimeFrames{min(run, end)};
vthData.MixinUnanticipated = runningData.MixinUnanticipated(min(run, end));

% Simulate @Rectangular object one timeFrame at a time
numTimeFrames = size(timeFrames, 1);
needsUpdateShocks = false;
vthExitFlags = repmat(solver.ExitFlag.IN_PROGRESS, 1, numTimeFrames);
vthDiscrepancyTables = cell(1, numTimeFrames);


% 
% Simulate individual time frammes
%

% /////////////////////////////////////////////////////////////////////////
for frame = 1 : numTimeFrames
    setTimeFrame(vthRect, timeFrames(frame, :));
    setTimeFrame(vthData, timeFrames(frame, :));
    updateSwapsFromPlan(vthData, plan);
    ensureExpansionGivenData(vthRect, vthData);
    if vthData.NumOfExogenizedPoints==0
        simulateFirstOrderFunc = @flat;
    else
        simulateFirstOrderFunc = @swapped; 
    end

    %
    % Choose simulation type and run simulation
    %
    vthData.NeedsUpdateShocks = false;
    vthRect.Header = sprintf('[Variant|Page:%g][TimeFrame:%g]', run, frame);
    func = simulateFunction(method);

    if prepareOnly
        %
        % Prepare first-frame simulation only for asynchronous run, and
        % return immediately
        %
        prepared = {func, simulateFirstOrderFunc, vthRect, vthData, blazers};
        return
    end

    [exitFlag__, dcy__] = func( ...
        simulateFirstOrderFunc, vthRect, vthData, blazers ...
    );

    vthExitFlags(frame) = exitFlag__;
    if ~isempty(dcy__) && runningData.PrepareOutputInfo
        dcyTable = compileDiscrepancyTable( ...
            this, dcy__, ...
            this.Equation.Input(this.Equation.InxOfHashEquations) ...
        );
        vthDiscrepancyTables{frame} = dcyTable;
    end
    needsUpdateShocks = needsUpdateShocks | vthData.NeedsUpdateShocks;

    % If the simulation of this time frame fails and the user does not
    % request results from failed simulations, break immediately from
    % the loop and do not continue to the next time frame
    if ~hasSucceeded(exitFlag__) && runningData.SuccessOnly
        break
    end
end % frame
% /////////////////////////////////////////////////////////////////////////


% Overall success
vthSuccess = all(hasSucceeded(vthExitFlags));

% Update shocks back in YXEPG if needed
if any(needsUpdateShocks)
    storeE(vthData);
end

if method==solver.Method.STACKED || method==solver.Method.STATIC
    if deviation
        vthData.YXEPG = removeSteadyTrends(vthData, vthData.YXEPG);
    end
end

% Fill in NaNs on the entire simulation range if the simulation failed
% and the user does not request the numbers
if ~vthSuccess && runningData.SuccessOnly
    vthData.YXEPG(:, firstColumnToRun:lastColumnToRun) = NaN;
end

% Reset all data outside the simulation range to NaN except the
% necessary initial conditions
hereResetOutsideBaseRange( );

if regularCall
    % This is a call from @Model.simulate
    % Update running data
    runningData.YXEPG(:, :, run) = vthData.YXEPG;
    runningData.Success(run) = vthSuccess;
    if runningData.PrepareOutputInfo
        runningData.TimeFrames{run} = timeFrames;
        runningData.ExitFlags{run} = vthExitFlags;
        runningData.DiscrepancyTables{run} = vthDiscrepancyTables;
    end
else
    % This is a call from @SystemPriorWrapper
    % Create system property output
    systemProperty.Outputs{1} = vthData.YXEPG(:, baseRangeColumns);
end

return


    function hereResetOutsideBaseRange( )
        temp = vthData.YXEPG(:, 1:firstColumnToRun-1);
        temp(~inxInitInPresample) = NaN;
        vthData.YXEPG(:, 1:firstColumnToRun-1) = temp;
        vthData.YXEPG(:, lastColumnToRun+1:end) = NaN;
    end%
end%


%
% Local Functions
%


function dcyTable = compileDiscrepancyTable(this, discrepancy, equations)
    MAX_STRLENGTH = 50;
    maxInRow = max(abs(discrepancy), [ ], 2);
    [maxInRow, reorderRows] = sort(maxInRow, 1, 'descend');
    discrepancy = discrepancy(reorderRows, :);
    equations = equations(reorderRows);
    equations = equations(:);
    inxTooLong = cellfun(@(x) length(x)>MAX_STRLENGTH, equations);
    ellipsis = iris.get('Ellipsis');
    equations(inxTooLong) = cellfun( @(x) [x(1:MAX_STRLENGTH-1), ellipsis], ...
                                     equations(inxTooLong), ...
                                     'UniformOutput', false );
    dcyTable = table( equations, maxInRow, discrepancy, ...
                              'VariableNames', {'Equation', 'MaxDiscrepancy', 'Discrepancies'} );
end%

