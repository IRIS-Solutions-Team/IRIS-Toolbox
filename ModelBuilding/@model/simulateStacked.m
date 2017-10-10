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
numOfQuantities = length(this.Quantity);
%ixy = this.Quantity.Type==TYPE(1);
%ixx = this.Quantity.Type==TYPE(2);
%ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
%ixg = this.Quantity.Type==TYPE(5);
%ixyxeg = ixy | ixx | ixe | ixg;
ok = true(1, nv);

% Base range is the simulation range requested by the user. Base range plus
% N is the base range extended to include N additional periods at the end,
% where N is the number of full nonlinear periods to be simulated in
% forward-looking blocks. Extended range is the base range plus N, extended
% to cover max lags and max leads.

N = 50;
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
numOfColumns = size(YXEPG, 2);
numOfColumnsSimulated = lastColumn - firstColumn + 1;

blz = prepareBlazer(this, 'Stacked', opt);
run(blz);
prepareBlocks(blz, opt);

ixLog = blz.IxLog;
ixLog(:) = false;
numOfBlocks = numel(blz.Block);
%ixEndg = false(1, numOfQuantities); % Index of all endogenous quantities.
%for i = 1 : numOfBlocks
%    ixEndg(blz.Block{i}.PosQty) = true;
%end

state = struct( );

for v = 1 : nv
    vthData = simulate.Data( );
    [vthData.YXEPG, vthData.L] = lp4lhsmrhs(this, YXEPG(:, :, v), v, [ ]);
    vthRect = simulate.Rectangular.fromModel(this, v, opt.anticipate);
    deviation = false;
    flat(vthRect, vthData, firstColumn, numOfColumns, deviation);
    blockExitStatus = ones(numOfBlocks, numOfColumns);

    if ~opt.FOTC
        vthRect = [ ];
    end

    for i = 1 : numOfBlocks
        ithBlk = blz.Block{i};
            if ithBlk.Type~=solver.block.Type.SOLVE || ithBlk.MaxLead==0
                runColumns = firstColumn : lastColumn;
                [exitStatus, error] = run(ithBlk, vthData, runColumns, ixLog, [ ]);
                blockExitStatus(i, runColumns) = exitStatus;
            else
                for t = firstColumn %: lastColumn
                    runColumns = t + (0:N-1);
                    [exitStatus, error] = run(ithBlk, vthData, runColumns, ixLog, vthRect);
                    blockExitStatus(i, t) = exitStatus;
                end
            end


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

names = this.Quantity.Name;
labels = this.Quantity.Label;
outputDatabank = databank.fromDoubleArrayNoFrills( ...
    YXEPG, names, extendedRange(1), labels ...
);


end
