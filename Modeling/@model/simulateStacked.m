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

startOfBaseRange = baseRange(1);
endOfBaseRange = baseRange(end);
[YXEPG, ~, extendedRange, ~, maxShift, timeTrend] = data4lhsmrhs(this, inputDatabank, startOfBaseRange, endOfBaseRange);
needsFotc = maxShift>0;

% Reset NaN shocks to zero
resetNaNShocks( );

firstColumnToRun = rnglen(extendedRange(1), startOfBaseRange);
lastColumnToRun = rnglen(extendedRange(1), endOfBaseRange);
columnsToRun = firstColumnToRun : lastColumnToRun;
numOfDataColumns = size(YXEPG, 2);

% __Prepare and Run blazer.Stacked__
blz = prepareBlazer(this, opt.Method, opt);
keyboard
run(blz);
blz.ColumnsToRun = columnsToRun;
prepareBlocks(blz, opt);

inxOfLog = blz.IxLog;
% inxOfLog(:) = false;
numOfBlocks = numel(blz.Block);
blockExitStatus = repmat({ones(numOfBlocks, numOfDataColumns)}, 1, nv);
BarYX = zeros(nnz(inxOfYX), numOfDataColumns);
for v = 1 : nv
    % Set up simulation data
    vthData = simulate.Data( );
    [vthData.YXEPG, vthData.L] = lp4lhsmrhs(this, YXEPG(:, :, v), v, [ ]);
    if opt.Deviation
        needsDelog = true;
        BarYX = createTrendArray(this, v, needsDelog, posOfYX, timeTrend);
        addSteadyTrends( );
    end

    % Set up Rectangural for first-order terminal condition simulation
    vthRect = simulate.Rectangular.fromModel(this, v);

    vthRect.Anticipate = opt.Anticipate;
    vthRect.Deviation = false;
    vthRect.SimulateObserved = false;

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
                                                   extendedRange(1), ...
                                                   labels );

return




    function resetNaNShocks( )
        e = YXEPG(inxOfE, :, :);
        e(isnan(e)) = 0;
        YXEPG(inxOfE, :, :) = e;
    end%




    function addSteadyTrends( )
        vthData.YXEPG(inxOfYX & inxOfLogInModel, :) = vthData.YXEPG(inxOfYX & inxOfLogInModel, :) ...
                                                    .* BarYX(inxOfLogInModel(inxOfYX), :);
        vthData.YXEPG(inxOfYX & ~inxOfLogInModel, :) = vthData.YXEPG(inxOfYX & ~inxOfLogInModel, :) ...
                                                     + BarYX(~inxOfLogInModel(inxOfYX), :);
    end%




    function removeSteadyTrends( )
        vthData.YXEPG(inxOfYX & inxOfLogInModel, :) = vthData.YXEPG(inxOfYX & inxOfLogInModel, :) ...
                                                    ./ BarYX(inxOfLogInModel(inxOfYX), :);
        vthData.YXEPG(inxOfYX & ~inxOfLogInModel, :) = vthData.YXEPG(inxOfYX & ~inxOfLogInModel, :) ...
                                                     - BarYX(~inxOfLogInModel(inxOfYX), :);
    end%
end%
