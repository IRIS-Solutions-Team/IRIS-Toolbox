function  [outputDatabank, ok] = simulateStacked(this, inputDatabank, baseRange, opt)
% simulateStacked  Simulate stacked-time system
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

inxOfYX = this.Quantity.Type==TYPE(1) | this.Quantity.Type==TYPE(2);
inxOfE = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
inxOfLogInModel = this.Quantity.IxLog;
posOfYX = find(inxOfYX);
nv = length(this);
ok = true(1, nv);

baseRange = double(baseRange);
startOfBaseRange = baseRange(1);
endOfBaseRange = baseRange(end);
[YXEPG, ~, extendedRange, ~, maxShift, timeTrend] = data4lhsmrhs( this, ...
                                                                  inputDatabank, ...
                                                                  baseRange, ...
                                                                  'ResetShocks=', true );
startOfExtendedRange = extendedRange(1);
firstColumnToRun = round(startOfBaseRange - startOfExtendedRange + 1);
lastColumnToRun = round(endOfBaseRange - startOfExtendedRange + 1); 
numOfDataColumns = size(YXEPG, 2);

% __Prepare and Run blazer.Stacked__
blz = prepareBlazer(this, opt.Method, opt);
run(blz);
blz.ColumnsToRun = firstColumnToRun : lastColumnToRun;
prepareBlocks(blz, opt);

inxOfLog = blz.Quantity.InxOfLog;
numOfBlocks = numel(blz.Block);
blockExitStatus = repmat({ones(numOfBlocks, numOfDataColumns)}, 1, nv);
for v = 1 : nv
    % Set up simulation data including parameters and steady trends
    plan = true;
    vthData = simulate.Data.fromModelAndPlan(this, v, plan, YXEPG);
    vthData.FirstColumnOfSimulation = firstColumnToRun;
    vthData.LastColumnOfSimulation = numOfDataColumns;
    if opt.Deviation
        vhtData.YXEPG = addSteadyTrends(vthData, vthData.YXEPG);
    end

    % Set up Rectangural for first-order terminal condition simulation
    vthRect = simulate.Rectangular.fromModel(this, v);
    vthRect.Deviation = false;
    vthRect.SimulateY = false;

    if strcmpi(opt.Initial, 'FirstOrder')
        % Simulate on the simulation range to get initial values
        initTimeFrame = [firstColumnToRun, numOfDataColumns];
        setTimeFrame(vthRect, initTimeFrame);
        setTimeFrame(vthData, initTimeFrame);
        flat(vthRect, vthData);
    end

    for i = 1 : numOfBlocks
        ithBlk = blz.Block{i};
        if ithBlk.Type==solver.block.Type.SOLVE
            prepareTerminal( );
        end
        if strcmpi(opt.Method, 'Stacked')
            % Stacked time
            columnsToRun = firstColumnToRun : lastColumnToRun;
            [exitStatus, error] = run(ithBlk, vthData, columnsToRun, inxOfLog);
            blockExitStatus{v}(i, columnsToRun) = exitStatus;
        else
            % Period by period
            for t = firstColumnToRun : lastColumnToRun
                [exitStatus, error] = run(ithBlk, vthData, t, inxOfLog);
                blockExitStatus{v}(i, t) = exitStatus;
            end
        end
        if ~isempty(error.EvaluatesToNan)
            throw( exception.Base('Dynamic:EvaluatesToNan', 'error'), ...
                   '', this.Equation.Input{error.EvaluatesToNan} );
        end
    end 
    blockExitStatus{v} = blockExitStatus{v}(:, firstColumnToRun:lastColumnToRun);
    ok(v) = all(blockExitStatus{v}(:)==1);
    if opt.Deviation
        removeSteadyTrends( );
    end
    YXEPG(:, firstColumnToRun:lastColumnToRun, v) = vthData.YXEPG(:, firstColumnToRun:lastColumnToRun);
end

% Report parameter variants where some blocks failed to converge
if any(~ok) 
    throw( exception.Base('Model:StackedSimulationFailed', 'warning'), ...
           exception.Base.alt2str(~ok) );
end

YXEPG = YXEPG(:, 1:lastColumnToRun, :);
names = this.Quantity.Name;
labels = this.Quantity.Label;
outputDatabank = databank.fromDoubleArrayNoFrills( YXEPG, ...
                                                   names, ...
                                                   startOfExtendedRange, ...
                                                   labels );

return


    function prepareTerminal( )
        maxMaxLead = max(ithBlk.MaxLead);
        if maxMaxLead>0
            % Reset range in @Rectangular and @simulate.Data for simulation of terminal condition
            fotcTimeFrame = [lastColumnToRun+1, lastColumnToRun+maxMaxLead];
            setTimeFrame(vthRect, fotcTimeFrame);
            setTimeFrame(vthData, fotcTimeFrame);
        else
            vthRect = [ ];
        end
        ithBlk.Terminal = vthRect;
    end%
end%
