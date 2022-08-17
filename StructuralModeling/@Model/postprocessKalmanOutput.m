function [info, this] = postprocessKalmanOutput(this, regOutp, extdRange, opt)

TIME_SERIES_TEMPLATE = Series();
MEAN_OUTPUT = iris.mixin.Kalman.MEAN_OUTPUT;
MSE_OUTPUT = iris.mixin.Kalman.MSE_OUTPUT;

info = struct();

try
    isNamedMatrix = contains(opt.MatrixFormat, "NamedMat", "ignoreCase", true);
catch
    isNamedMatrix = false;
end

inxY = this.Quantity.Type==1;
inxE = this.Quantity.Type==31 | this.Quantity.Type==32;
nv = countVariants(this);

startDate = extdRange(1);


%
% FMSE for measurement variables and prediction errors
%
F = [];
if isfield(regOutp, 'F')
    F = TIME_SERIES_TEMPLATE;
    F = replace(F, permute(regOutp.F, [3, 1, 2, 4]), startDate);
end
info.FMSE = F;


%
% Prediction errors
%
pe = [];
if isfield(regOutp, 'Pe')
    logPrefix = string(model.component.Quantity.LOG_PREFIX);
    pe = struct();
    for i = find(inxY)
        name = string(this.Quantity.Name(i));
        data = permute(regOutp.Pe(i, :, :), [2, 3, 1]);
        if this.Quantity.IxLog(i)
            name = logPrefix + name;
        end
        pe.(name) = TIME_SERIES_TEMPLATE;
        pe.(name) = fill(pe.(name), data, startDate, "Prediction error");
    end
end
info.Error = pe;


%
% Common variance and std factor
%
V = [];
if isfield(regOutp, 'V')
    V = regOutp.V;
end
info.VarScale = V;
info.StdScale = sqrt(V);


%
% Update out-of-lik parameters in the model object
%
info.Outlik = struct();
delta = struct();
namesOutLik = string(this.Quantity.Name(opt.Outlik));
if isfield(regOutp, 'Delta')
    for i = 1 : numel(opt.Outlik)
        name = namesOutLik(i);
        posQty = opt.Outlik(i);
        this.Variant.Values(:, posQty, :) = regOutp.Delta(i, :);
        delta.(name) = regOutp.Delta(i, :);
    end
end
info.Outlik.(MEAN_OUTPUT) = delta;


PDelta = [];
if isfield(regOutp, 'PDelta')
    PDelta = regOutp.PDelta;
    if isNamedMatrix
        PDelta = namedmat(PDelta, namesOutLik, namesOutLik);
    end
end
info.Outlik.(MSE_OUTPUT) = PDelta;



%
% Initials for the original transition vector
%
initials = regOutp.Initials;
info.TriangularInitials = initials;
for v = 1 : size(initials{1}, 3)
    U = regOutp.U{v};
    if ~isempty(U)
        initials{1}(:, :, v) = U * initials{1}(:, :, v);
        initials{2}(:, :, v) = U * initials{2}(:, :, v) * U';
        initials{3}(:, :, v) = U * initials{3}(:, :, v) * U';
    end
end
info.Initials = initials;



%
% Update the std parameters in the model object.
%
if opt.Relative 
    numE = nnz(inxE);
    se = sqrt(V);
    for v = 1 : nv
        this.Variant.StdCorr(:, 1:numE, v) = this.Variant.StdCorr(:, 1:numE, v)*se(v);
    end
    % Refresh dynamic links after we change std deviations because std devs are
    % allowed in dynamic links.
    if any(this.Link)
        this = refresh(this);
    end
end

end%

