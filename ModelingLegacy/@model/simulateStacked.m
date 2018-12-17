function  [outputDatabank, ok] = simulateStacked(this, inputDatabank, baseRange, opt)
% simulateStacked  Simulate stacked-time system
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

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
needsFotc = maxShift>0;

startOfExtendedRange = extendedRange(1);
firstColumnToRun = round(startOfBaseRange - startOfExtendedRange + 1);
lastColumnToRun = round(endOfBaseRange - startOfExtendedRange + 1); 
columnsToRun = firstColumnToRun : lastColumnToRun;
numOfDataColumns = size(YXEPG, 2);

% __Prepare and Run blazer.Stacked__
blz = prepareBlazer(this, opt.Method, opt);
run(blz);
blz.ColumnsToRun = columnsToRun;
prepareBlocks(blz, opt);

inxOfLog = blz.IxLog;
% inxOfLog(:) = false;
numOfBlocks = numel(blz.Block);
blockExitStatus = repmat({ones(numOfBlocks, numOfDataColumns)}, 1, nv);
for v = 1 : nv
    % Set up simulation data including parameters and steady trends
    vthData = simulate.Data.fromModel(this, v, YXEPG);
    if opt.Deviation
        vhtData.YXEPG = addSteadyTrends(vthData, vthData.YXEPG);
    end

    % Set up Rectangural for first-order terminal condition simulation
    vthRect = simulate.Rectangular.fromModel(this, v);

    vthRect.Deviation = false;
    vthRect.SimulateY = false;

    if strcmpi(opt.Initial, 'FirstOrder')
        % Simulate on the simulation range to get initial values
        vthRect.FirstColumn = firstColumnToRun;
        vthRect.LastColumn = numOfDataColumns;
        flat(vthRect, vthData);
    end

    if needsFotc
        % Reset the Rectangular object for simulation of terminal condition
        vthRect.FirstColumn = lastColumnToRun + 1;
        vthRect.LastColumn = numOfDataColumns;
    else
        vthRect = [ ];
    end

    vthRect.LastColumn = lastColumnToRun + maxMaxLead;
    for i = 1 : numOfBlocks
        ithBlk = blz.Block{i};
        ithBlk.Terminal = vthRect;
        maxMaxLead = max(ithBlk.MaxLead);
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

end%
