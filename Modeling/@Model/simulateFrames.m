function prepared = simulateFrames(this, systemProperty, run, prepareOnly)
% simulateFrames  Implement simulation by time frames
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;
if nargin<4
    prepareOnly = false;
end

%--------------------------------------------------------------------------

runningData = systemProperty.Specifics;
isAsynchronous = runningData.IsAsynchronous;

% Regular call from @Model.simulate
regularCall = systemProperty.NumOfOutputs==0;

nv = countVariants(this);
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

%
% Set up @simulate.Data from @Model and @Plan, fill in parameters,
% steady trends and measurement trends from @Model
%
data__ = simulate.Data.fromModelAndPlan(this, run, plan, runningData);

data__.FirstColumnOfSimulation = firstColumnToRun;
data__.LastColumnOfSimulation = lastColumnToRun;
data__.Window = runningData.Window;
data__.Initial = runningData.Initial;
data__.SolverOptions = runningData.SolverOptions;

if method==solver.Method.STACKED || method==solver.Method.PERIOD
    if deviation
        data__.YXEPG = addSteadyTrends(data__, data__.YXEPG);
        data__.Deviation = false;
    end
else
    data__.Deviation = deviation;
end

% Set up @Rectangular object for simulation
useFirstOrder = method~=solver.Method.PERIOD;
rect__ = simulate.Rectangular.fromModel(this, run, useFirstOrder);
rect__.SparseShocks = runningData.SparseShocks;
rect__.Deviation = data__.Deviation;
rect__.SimulateY = true;
rect__.Method = method;
rect__.PlanMethod = plan.Method;
rect__.NeedsEvalTrends = data__.NeedsEvalTrends;

%
% Equation-selective specific properties
%
if method==solver.Method.SELECTIVE
    % Prepare hash equations
    [  ...
        rect__.HashEquationsAll, ...
        rect__.HashEquationsIndividually, ...
        rect__.HashEquationsInput, ...
        rect__.HashIncidence ...
    ] = prepareHashEquations(this);

    % Reset nonlin add factor array
    numHashEquations = numel(rect__.HashEquationsIndividually);
    data__.NonlinAddf = zeros(numHashEquations, data__.NumOfColumns);
end

% Split shocks into AnticipatedE and UnanticipatedE properties on
% the whole simulation range
% retrieveE(data__);
[data__.AnticipatedE, data__.UnanticipatedE] = ...
    simulate.Data.splitE(data__.E, data__.AnticipationStatusOfE, baseRangeColumns);

% Retrieve time frames
timeFrames__ = runningData.Frames{min(run, end)};
data__.MixinUnanticipated = runningData.MixinUnanticipated(min(run, end));

% Simulate @Rectangular object one timeFrame at a time
numFrames = size(timeFrames__, 1);
needsUpdateShocks = false;
exitFlags__ = repmat(solver.ExitFlag.IN_PROGRESS, 1, numFrames);
discrepancyTables__ = cell(1, numFrames);


% 
% Simulate individual time frammes
%

% /////////////////////////////////////////////////////////////////////////
for frame = 1 : numFrames
    setFrame(rect__, timeFrames__(frame, :));
    setFrame(data__, timeFrames__(frame, :));
    updateSwapsFromPlan(data__, plan);
    ensureExpansionGivenData(rect__, data__);
    if data__.NumOfExogenizedPoints==0
        simulateFirstOrderFunc = @flat;
    else
        simulateFirstOrderFunc = @swapped; 
    end

    %
    % Choose simulation type and run simulation
    %
    data__.NeedsUpdateShocks = false;
    rect__.Header = sprintf("[Variant|Page:%g][Frame:%g]", run, frame);
    func = simulateFunction(method);

    if prepareOnly
        %
        % Prepare first-frame simulation only for asynchronous run, and
        % return immediately
        %
        prepared = {func, simulateFirstOrderFunc, rect__, data__, blazers};
        return
    end

    [exitFlag__, dcy__] = func( ...
        simulateFirstOrderFunc, rect__, data__, blazers ...
    );

    exitFlags__(frame) = exitFlag__;
    if ~isempty(dcy__) && runningData.PrepareOutputInfo
        dcyTable = compileDiscrepancyTable( ...
            this, dcy__, ...
            this.Equation.Input(this.Equation.InxOfHashEquations) ...
        );
        discrepancyTables__{frame} = dcyTable;
    end
    needsUpdateShocks = needsUpdateShocks | data__.NeedsUpdateShocks;

    % If the simulation of this time frame fails and the user does not
    % request results from failed simulations, break immediately from
    % the loop and do not continue to the next time frame
    if ~hasSucceeded(exitFlag__) && runningData.SuccessOnly
        break
    end
end % frame
% /////////////////////////////////////////////////////////////////////////


% Overall success
success__ = all(hasSucceeded(exitFlags__));

% Update shocks back in YXEPG if needed
if any(needsUpdateShocks)
    storeE(data__);
end

if method==solver.Method.STACKED || method==solver.Method.PERIOD
    if deviation
        data__.YXEPG = removeSteadyTrends(data__, data__.YXEPG);
    end
end

% Fill in NaNs on the entire simulation range if the simulation failed
% and the user does not request the numbers
if ~success__ && runningData.SuccessOnly
    data__.YXEPG(:, firstColumnToRun:lastColumnToRun) = NaN;
end

% Reset all data outside the simulation range to NaN except the
% necessary initial conditions
hereResetOutsideBaseRange( );

if regularCall
    % This is a call from @Model.simulate
    % Update running data
    runningData.YXEPG(:, :, run) = data__.YXEPG;
    runningData.Success(run) = success__;
    if runningData.PrepareOutputInfo
        runningData.Frames{run} = timeFrames__;
        runningData.ExitFlags{run} = exitFlags__;
        runningData.DiscrepancyTables{run} = discrepancyTables__;
    end
else
    % This is a call from @SystemPriorWrapper
    % Create system property output
    systemProperty.Outputs{1} = data__.YXEPG(:, baseRangeColumns);
end

return


    function hereResetOutsideBaseRange( )
        temp = data__.YXEPG(:, 1:firstColumnToRun-1);
        temp(~inxInitInPresample) = NaN;
        data__.YXEPG(:, 1:firstColumnToRun-1) = temp;
        data__.YXEPG(:, lastColumnToRun+1:end) = NaN;
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

