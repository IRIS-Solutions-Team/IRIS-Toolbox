function  [outputDatabank, ok] = simulateStacked(this, inputDatabank, baseRange, opt)
% simulateStacked  Simulate stacked-time system
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
nv = length(this);
numQuantities = length(this.Quantity);
ok = true(1, nv);

startOfBaseRange = baseRange(1);
endOfBaseRange = baseRange(end);
[YXEPG, ~, extendedRange, ~, maxShift] = data4lhsmrhs(this, inputDatabank, startOfBaseRange, endOfBaseRange);
needsFotc = maxShift>0;
for i = find(ixe)
    e = YXEPG(i, :, :);
    e(isnan(e)) = 0;
    YXEPG(i, :, :) = e;
end
firstColumnToRun = rnglen(extendedRange(1), startOfBaseRange);
lastColumnToRun = rnglen(extendedRange(1), endOfBaseRange);
numOfColumnsToRun = lastColumnToRun - firstColumnToRun + 1;
numOfDataColumns = size(YXEPG, 2);

blz = prepareBlazer(this, opt.Method, numOfColumnsToRun, opt);
run(blz);
prepareBlocks(blz, opt);

ixLog = blz.IxLog;
% ixLog(:) = false;
numBlocks = numel(blz.Block);
blockExitStatus = repmat({ones(numBlocks, numOfDataColumns)}, 1, nv);
for v = 1 : nv
    vthData = simulate.Data( );
    [vthData.YXEPG, vthData.L] = lp4lhsmrhs(this, YXEPG(:, :, v), v, [ ]);
    vthRect = simulate.Rectangular.fromModel(this, v);

    vthRect.Anticipate = opt.Anticipate;
    vthRect.Deviation = false;
    vthRect.SimulateObserved = false;
    vthRect.FirstColumn = firstColumnToRun;
    vthRect.LastColumn = numOfDataColumns;

    % Simulate on the simulation range to get initial values
    flat(vthRect, vthData);

    if needsFotc
        % Reset the Rectangular object for simulation of terminal condition
        vthRect.FirstColumn = lastColumnToRun + 1;
    else
        vthRect = [ ];
    end

    for i = 1 : numBlocks
        ithBlk = blz.Block{i};
        maxMaxLead = max(ithBlk.MaxLead);
        vthRect.LastColumn = lastColumnToRun + maxMaxLead;
        if strcmpi(opt.Method, 'Stacked')
            % Stacked time
            columnsToRun = firstColumnToRun : lastColumnToRun;
            [exitStatus, error] = run(ithBlk, vthData, columnsToRun, ixLog, vthRect);
            blockExitStatus{v}(i, columnsToRun) = exitStatus;
        else
            % Period by period
            for t = firstColumnToRun : lastColumnToRun
                [exitStatus, error] = run(ithBlk, vthData, t, ixLog, vthRect);
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
    YXEPG(:, firstColumnToRun:lastColumnToRun, v) = vthData.YXEPG(:, firstColumnToRun:lastColumnToRun);
end

% Report parameter variants where some blocks failed to converge
if any(~ok) 
    throw( ...
        exception.Base('Model:StackedSimulationFailed', 'warning'), ...
        exception.Base.alt2str(~ok) ...
    );
end

YXEPG = YXEPG(:, 1:lastColumnToRun, :);
names = this.Quantity.Name;
labels = this.Quantity.Label;
outputDatabank = databank.fromDoubleArrayNoFrills( ...
    YXEPG, names, extendedRange(1), labels ...
);

end%
