% postprocessFilterOutput  Postprocess regular (non-hdata) output arguments from the Kalman filter or FD lik.
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function [F, predictError, V, delta, PDelta, initials, this] ...
    = postprocessFilterOutput(this, regOutp, extdRange, opt)

try
    isNamedMat = strcmpi(opt.MatrixFormat, 'namedmat');
catch
    isNamedMat = false;
end

TIME_SERIES_TEMPLATE = Series();

inxY = this.Quantity.Type==1;
inxE = this.Quantity.Type==31 | this.Quantity.Type==32;
nv = countVariants(this);

startDate = extdRange(1);

F = [ ];
if isfield(regOutp, 'F')
    F = TIME_SERIES_TEMPLATE;
    F = replace(F, permute(regOutp.F, [3, 1, 2, 4]), startDate);
end

predictError = [ ];
if isfield(regOutp, 'Pe')
    logPrefix = string(model.component.Quantity.LOG_PREFIX);
    predictError = struct( );
    for i = find(inxY)
        name = string(this.Quantity.Name(i));
        data = permute(regOutp.Pe(i, :, :), [2, 3, 1]);
        if this.Quantity.IxLog(i)
            name = logPrefix + name;
        end
        predictError.(name) = TIME_SERIES_TEMPLATE;
        predictError.(name) = fill(predictError.(name), data, startDate, "Prediction error");
    end
end

V = [ ];
if isfield(regOutp, 'V')
    V = regOutp.V;
end

% Update out-of-lik parameters in the model object
delta = struct( );
namesOutLik = string(this.Quantity.Name(opt.OutOfLik));
if isfield(regOutp, 'Delta')
    for i = 1 : numel(opt.OutOfLik)
        name = namesOutLik(i);
        posQty = opt.OutOfLik(i);
        this.Variant.Values(:, posQty, :) = regOutp.Delta(i, :);
        delta.(name) = regOutp.Delta(i, :);
    end
end

PDelta = [ ];
if isfield(regOutp, 'PDelta')
    PDelta = regOutp.PDelta;
    if isNamedMat
        PDelta = namedmat(PDelta, namesOutLik, namesOutLik);
    end
end


%
% Initials for the original transition vector
%
initials = regOutp.Init;
for v = 1 : size(initials{1}, 3)
    U = regOutp.U{v};
    if ~isempty(U)
        initials{1}(:, :, v) = U * initials{1}(:, :, v);
        initials{2}(:, :, v) = U * initials{2}(:, :, v) * U';
        initials{3}(:, :, v) = U * initials{3}(:, :, v) * U';
    end
end



% Update the std parameters in the model object.
if opt.Relative && nargout>6
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

