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
firstColumn = rnglen(extendedRange(1), startOfBaseRange);
lastColumn = rnglen(extendedRange(1), endOfBaseRange);
numColumnsSimulated = lastColumn - firstColumn + 1;
numColumns = size(YXEPG, 2);

blz = prepareBlazer(this, opt.Method, numColumnsSimulated, opt);
run(blz);
prepareBlocks(blz, opt);

ixLog = blz.IxLog;
ixLog(:) = false;
numBlocks = numel(blz.Block);
blockExitStatus = repmat({ones(numBlocks, numColumns)}, 1, nv);
for v = 1 : nv
    vthData = simulate.Data( );
    [vthData.YXEPG, vthData.L] = lp4lhsmrhs(this, YXEPG(:, :, v), v, [ ]);
    vthRect = simulate.Rectangular.fromModel(this, v, opt.anticipate);
    deviation = false;
    observed = true;
    prepareDataDependentProperties(vthRect, vthData, firstColumn);

    % Simulate on the simulation range to get initial values.
    flat(vthRect, vthData, firstColumn, numColumns, deviation, observed);

    if needsFotc
        % Reset the Rectangular object for simulation of terminal condition.
        firstColumnFotc = lastColumn + 1;
        prepareDataDependentProperties(vthRect, vthData, firstColumnFotc);
    else
        vthRect = [ ];
    end

    for i = 1 : numBlocks
        ithBlk = blz.Block{i};
        if strcmpi(opt.Method, 'Stacked')
            % Stacked time
            runColumns = firstColumn : lastColumn;
            [exitStatus, error] = run(ithBlk, vthData, runColumns, ixLog, vthRect);
            blockExitStatus{v}(i, runColumns) = exitStatus;
        else
            % Period by period
            for t = firstColumn : lastColumn
                [exitStatus, error] = run(ithBlk, vthData, t, ixLog, vthRect);
                blockExitStatus{v}(i, t) = exitStatus;
            end
        end
        if ~isempty(error.EvaluatesToNan)
            throw( ...
                exception.Base('Dynamic:EvaluatesToNan', 'error'), ...
                '', ...
                this.Equation.Input{error.EvaluatesToNan} ...
            );
        end
    end 
    blockExitStatus{v} = blockExitStatus{v}(:, firstColumn:lastColumn);
    ok(v) = all(blockExitStatus{v}(:)==1);
    YXEPG(:, firstColumn:lastColumn, v) = vthData.YXEPG(:, firstColumn:lastColumn);
end

% Report parameter variants where some blocks failed to converge
if any(~ok) 
    throw( ...
        exception.Base('Model:StackedSimulationFailed', 'warning'), ...
        exception.Base.alt2str(~ok) ...
    );
end

YXEPG = YXEPG(:, 1:lastColumn, :);
names = this.Quantity.Name;
labels = this.Quantity.Label;
outputDatabank = databank.fromDoubleArrayNoFrills( ...
    YXEPG, names, extendedRange(1), labels ...
);

end%
