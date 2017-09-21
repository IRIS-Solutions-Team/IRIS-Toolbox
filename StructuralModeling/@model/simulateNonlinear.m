function  [outp, ok] = simulateNonlinear(this, inp, range, variantsRequested, opt)
% simulateNonlinear  Simulate dynamic equations in global nonlinear mode.
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

blz = prepareBlazer(this, 'Dynamic', opt);
run(blz);
prepareBlocks(blz, opt);

ixLog = blz.IxLog;
nBlk = numel(blz.Block);
ixEndg = false(1, numOfQuantities); % Index of all endogenous quantities.
for iBlk = 1 : nBlk
    ixEndg(blz.Block{iBlk}.PosQty) = true;
end

state = struct( );

[YXEPG, ~, extendedRange] = data4lhsmrhs(this, inp, range);
firstPeriod = find(datcmp(range(1), extendedRange), 1);
lastPeriod = find(datcmp(range(end), extendedRange), 1, 'last');

for i = 1 : numOfVariantsRequested
    iAlt = variantsRequested(i);
  
    X = YXEPG(:, :, i);
    [X, L] = lp4lhsmrhs(this, X, iAlt, [ ]);
    X(end+1, :, :) = 1; %#ok<AGROW>

    state.IAlt = iAlt;
    x0 = X;
    for t = firstPeriod : lastPeriod
        state.T = firstPeriod;
        state.Date = extendedRange(t);
        state.PrintDate = dat2char(state.Date);
        blockExitStatus = false(1, nBlk);
        if strcmpi(opt.InitEndog, 'Static')
            X(:, 1:t-1) = x0(:, 1:t-1);
        end
        for iBlk = 1 : nBlk
            blk = blz.Block{iBlk};
            
            [X, blockExitStatus(iBlk), error] = run(blk, X, t, L, ixLog);
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
