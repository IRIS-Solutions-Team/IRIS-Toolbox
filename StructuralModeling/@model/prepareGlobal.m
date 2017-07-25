function glb = prepareGlobal(this, inp, range, opt)

TYPE = @int8;

%--------------------------------------------------------------------------

nAlt = length(this);
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixp = this.Quantity.Type==TYPE(4);

glb = simulate.Global( );

[shMin, shMax] = getMaxShift(this.Incidence.Dynamic);
shMin = min(shMin, -1);
if shMax>0
    throw( exception.Base('Global:CANNOT_RUN_LEAD', 'error') );
end

[YXE, ~, xRange] = data4lhsmrhs(this, inp, range);
glb.TTrend = YXE(end, :, 1);
YXE(end, :, :) = [ ]; % Remove time trend from the last row.
nXPer = size(YXE, 2);
nData = size(YXE, 3);
if nData<nAlt
    YXE = cat(3, YXE, repmat(YXE, 1, 1, nAlt-nData));
end

glb.Quantity = this.Quantity;
glb.Equation = this.Equation;
glb.Pairing = this.Pairing;

nRow = sum(ixy | ixx | ixe | ixp);
glb.X = zeros(nRow, nXPer, max(nAlt, nData));
glb.X(ixy | ixx | ixe, :, :) = YXE; 
glb.XRange = xRange;
glb.RunTime = 1-shMin : nXPer;

glb.IsDeviation = opt.deviation;
optimSetDefault = { ...
    'display', 'iter', ...
    };
opt.optimset(1:2:end) = strrep(opt.optimset(1:2:end), '=', '');
glb.OptimSet = optimset(optimSetDefault{:}, opt.optimset{:});
glb.WhenFailed = opt.whenfailed;

end
