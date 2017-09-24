function  [outp, ok] = simulateStacked(this, inp, range, variantsRequested, opt)
% simulateStacked  Simulate stacked-time system.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

nv = length(this);
numOfQuantities = length(this.Quantity);
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixg = this.Quantity.Type==TYPE(5);
ixyxeg = ixy | ixx | ixe | ixg;
ok = true(1, nv);
range = range(1) : range(end);
if isequal(variantsRequested, @all)
    variantsRequested = 1 : nv;
end
numOfVariantsRequested = numel(variantsRequested);

blz = prepareBlazer(this, 'Stacked', opt);
run(blz);
prepareBlocks(blz, opt);

ixLog = blz.IxLog;
numOfBlocks = numel(blz.Block);
ixEndg = false(1, numOfQuantities); % Index of all endogenous quantities.
for i = 1 : numOfBlocks
    ixEndg(blz.Block{i}.PosQty) = true;
end

state = struct( );

%[YXEPG, ~, extendedRange] = data4lhsmrhs(this, inp, range);
%firstPeriod = find(datcmp(range(1), data.ExtendedRange), 1);
%lastPeriod = find(datcmp(range(end), data.ExtendedRange), 1, 'last');
keyboard
for i = 1 : numOfVariantsRequested
    v = variantsRequested(i);
    data = simulate.Data(this, v, inp, range);
  
    X = data.YXEPG(:, :, i);
    [X, L] = lp4lhsmrhs(this, X, v, [ ]);
    X(end+1, :, :) = 1; %#ok<AGROW>

    state.IAlt = v;
    x0 = X;
    for t = firstPeriod : lastPeriod
        state.T = firstPeriod;
        state.Date = extendedRange(t);
        state.PrintDate = dat2char(state.Date);
        blockExitStatus = false(1, numOfBlocks);
        if strcmpi(opt.InitEndog, 'Static')
            X(:, 1:t-1) = x0(:, 1:t-1);
        end
        for i = 1 : numOfBlocks
            ithBlock = blz.Block{i};
            [X, blockExitStatus(i), error] = run(ithBlock, X, t, L, ixLog);
            if ~isempty(error.EvaluatesToNan)
                throw( ...
                    exception.Base('Dynamic:EvaluatesToNan', 'error'), ...
                    state.PrintDate, ...
                    this.Equation.Input{error.EvaluatesToNan} ...
                );
            end
        end
        YXEPG(:, t, i) = X(1:end-1, t);
    end
end

outp = array2db( ...
    YXEPG(ixyxeg, firstPeriod:lastPeriod, :).', ...
    range, ...
    this.Quantity.Name(ixyxeg), ...
    [ ] ...
    );

% Return status only for parameterizations requested in variantsRequested.
ok = ok(variantsRequested);

end
