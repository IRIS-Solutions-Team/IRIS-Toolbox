function  [outp, ok] = simulateNonlinear(this, inp, range, vecAlt, displayMode, opt)
% simulateNonlinear  Simulate dynamic equations in global nonlinear mode.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

nAlt = length(this);
nQty = length(this.Quantity);
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixg = this.Quantity.Type==TYPE(5);
ixyxeg = ixy | ixx | ixe | ixg;
ok = true(1, nAlt);
range = range(1) : range(end);
if isequal(vecAlt, @all)
    vecAlt = 1 : nAlt;
end
nVecAlt = length(vecAlt);

[opt.Solver, opt.PrepareGradient] = ...
    solver.Options.processOptions(opt.Solver, opt.PrepareGradient, displayMode);
blz = prepareBlazer(this, 'Dynamic', opt);
run(blz);
prepareBlocks(blz, opt);

ixLog = blz.IxLog;
nBlk = numel(blz.Block);
ixEndg = false(1, nQty); % Index of all endogenous quantities.
for iBlk = 1 : nBlk
    ixEndg(blz.Block{iBlk}.PosQty) = true;
end

% Check for levels and growth rate fixed to NaNs.
% chkFixedNans(this, blz, vecAlt);

state = struct( );

[YXEPG, ~, xRange] = data4lhsmrhs(this, inp, range);
firstPeriod = find(datcmp(range(1), xRange), 1);
lastPeriod = find(datcmp(range(end), xRange), 1, 'last');


for i = 1 : nVecAlt
    iAlt = vecAlt(i);
  
    x = YXEPG(:, :, i);
    [x, L] = lp4yxe(this, x, iAlt, [ ]);
    x(end+1, :, :) = 1; %#ok<AGROW>

    state.IAlt = iAlt;
    x0 = x;
    for t = firstPeriod : lastPeriod
        state.T = firstPeriod;
        state.Date = xRange(t);
        state.PrintDate = dat2char(state.Date);
        blockExitStatus = false(1, nBlk);
        if strcmpi(opt.InitEndog, 'Static')
            x(:, 1:t-1) = x0(:, 1:t-1);
        end
        for iBlk = 1 : nBlk
            blk = blz.Block{iBlk};
            
            [x, blockExitStatus(iBlk), error] = run(blk, x, t, L, ixLog);
            if ~isempty(error.EvaluatesToNan)
                throw( ...
                    exception.Base('Dynamic:EvaluatesToNan', 'error'), ...
                    state.PrintDate, ...
                    this.Equation.Input{error.EvaluatesToNan} ...
                    );
            end
        end
        YXEPG(:, t, i) = x(1:end-1, t);
    end
end

outp = array2db( ...
    YXEPG(ixyxeg, firstPeriod:lastPeriod, :).', ...
    range, ...
    this.Quantity.Name(ixyxeg), ...
    [ ] ...
    );

% Return status only for parameterizations requested in vecAlt.
ok = ok(vecAlt);

end




function chkFixedNans(this, blz, vecAlt)
nQuan = length(this.Quantity);
% Check for levels fixed to NaN.
posFix = blz.PosFix.Level;
ixFix = false(1, nQuan);
ixFix(posFix) = true;
ixZero = blz.IxZero.Level;
asgn = model.Variant.getQuantity(this.Variant, ':', vecAlt);
ixNanLevel = any(isnan(real(asgn)), 3) & ixFix & ~ixZero;
if any(ixNanLevel)
    throw( ...
        exception.Base('Steady:LevelFixedToNan', 'error'), ...
        this.Quantity.Name{ixNanLevel} ...
        );
end

% Check for growth rates fixed to NaN.
posFix = blz.PosFix.Growth;
ixFix = false(1, nQuan);
ixFix(posFix) = true;
ixZero = blz.IxZero.Growth;
ixNanGrowth = any(isnan(imag(asgn)), 3) & ixFix & ~ixZero;
if any(ixNanGrowth)
    throw( ...
        exception.Base('Steady:GrowthFixedToNan', 'error'), ...
        this.Quantity.Name{ixNanGrowth} ...
        );
end
end
