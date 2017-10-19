function  [outputDatabank, ok] = simulateStacked(this, inputDatabank, baseRange, opt)
% simulateStacked  Simulate stacked-time system.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
nv = length(this);
numQuantities = length(this.Quantity);
%ixy = this.Quantity.Type==TYPE(1);
%ixx = this.Quantity.Type==TYPE(2);
%ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
%ixg = this.Quantity.Type==TYPE(5);
%ixyxeg = ixy | ixx | ixe | ixg;
ok = true(1, nv);

% Base range is the simulation range requested by the user. Base range plus
% N is the base range extended to include N additional periods at the end,
% where N is the number of full nonlinear periods to be simulated in
% forward-looking blocks. Extended range is the base range plus N extended
% to cover all lags and leads.

N = 1;
baseRange = baseRange(1) : baseRange(end);
baseRangePlusN = baseRange(1) : baseRange(end)+(N-1);
[YXEPG, ~, extendedRange] = data4lhsmrhs(this, inputDatabank, baseRangePlusN);
for i = find(ixe)
    e = YXEPG(i, :, :);
    e(isnan(e)) = 0;
    YXEPG(i, :, :) = e;
end
firstColumn = rnglen(extendedRange(1), baseRange(1));
lastColumn = rnglen(extendedRange(1), baseRange(end));
numColumns = size(YXEPG, 2);
numColumnsSimulated = numel(baseRange);

blz = prepareBlazer(this, 'Stacked', numColumnsSimulated, opt);
run(blz);
prepareBlocks(blz, opt);

ixLog = blz.IxLog;
ixLog(:) = false;
numBlocks = numel(blz.Block);
for v = 1 : nv
    vthData = simulate.Data( );
    [vthData.YXEPG, vthData.L] = lp4lhsmrhs(this, YXEPG(:, :, v), v, [ ]);
    vthRect = simulate.Rectangular.fromModel(this, v, opt.anticipate);
    deviation = false;
    observed = true;
    prepareDataDependentProperties(vthRect, vthData, firstColumn);
    flat(vthRect, vthData, firstColumn, numColumns, deviation, observed);
    blockExitStatus = ones(numBlocks, numColumns);

    firstColumnFotc = lastColumn + 1;
    prepareDataDependentProperties(vthRect, vthData, firstColumnFotc);

    if ~opt.FOTC
        vthRect = [ ];
    end

    for i = 1 : numBlocks
        ithBlk = blz.Block{i};
        runColumns = firstColumn : lastColumn;
        [exitStatus, error] = run(ithBlk, vthData, runColumns, ixLog, vthRect);
        blockExitStatus(i, runColumns) = exitStatus;
        %else
        %    for t = firstColumn %: lastColumn
        %        runColumns = t : t+numColumnsSimulated-1;
        %        [exitStatus, error] = run(ithBlk, vthData, runColumns, ixLog, vthRect);
        %        blockExitStatus(i, t) = exitStatus;
        %    end
        %end


        if ~isempty(error.EvaluatesToNan)
            throw( ...
                exception.Base('Dynamic:EvaluatesToNan', 'error'), ...
                '', ...
                this.Equation.Input{error.EvaluatesToNan} ...
            );
        end
    end % for i
    blockExitStatus = blockExitStatus(:, firstColumn:lastColumn);
    ok(v) = all(blockExitStatus(:)==1);
    YXEPG(:, firstColumn:lastColumn, v) = vthData.YXEPG(:, firstColumn:lastColumn);
end % for v

YXEPG = YXEPG(:, 1:lastColumn, :);
names = this.Quantity.Name;
labels = this.Quantity.Label;
outputDatabank = databank.fromDoubleArrayNoFrills( ...
    YXEPG, names, extendedRange(1), labels ...
);

end
