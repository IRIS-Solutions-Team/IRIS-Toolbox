function [info, this] = postprocessKalmanOutput(this, minusLogLik, regOutp, extdRange, opt)

    [info, this] = postprocessKalmanOutput@iris.mixin.Kalman(this, minusLogLik, regOutp, extdRange, opt);

    TIME_SERIES_TEMPLATE = Series();
    MEAN_OUTPUT = iris.mixin.Kalman.MEAN_OUTPUT;
    MSE_OUTPUT = iris.mixin.Kalman.MSE_OUTPUT;
    startDate = extdRange(1);

    try
        isNamedMatrix = contains(opt.MatrixFormat, "NamedMat", "ignoreCase", true);
    catch
        isNamedMatrix = false;
    end

    inxY = this.Quantity.Type==1;
    inxE = this.Quantity.Type==31 | this.Quantity.Type==32;


    %
    % Prediction errors
    %
    pe = [];
    if isfield(regOutp, 'Pe')
        logPrefix = string(model.Quantity.LOG_PREFIX);
        pe = struct();
        for i = find(inxY)
            name = string(this.Quantity.Name(i));
            if this.Quantity.IxLog(i)
                name = logPrefix + name;
            end
            pe.(name) = fill( ...
                TIME_SERIES_TEMPLATE ...
                , permute(regOutp.Pe(i, :, :), [2, 3, 1]) ...
                , startDate ...
                , "Prediction error" ...
            );
        end
    end
    info.Error = pe;


    %
    % Update out-of-lik parameters in the model object
    %
    info.Outlik = struct();
    delta = struct();
    PDelta = [];
    if isfield(regOutp, 'Delta')
        namesOutLik = string(this.Quantity.Name(opt.Outlik));
        for i = 1 : numel(opt.Outlik)
            name = namesOutLik(i);
            posQty = opt.Outlik(i);
            this.Variant.Values(:, posQty, :) = regOutp.Delta(i, :);
            delta.(name) = regOutp.Delta(i, :);
        end
        if isfield(regOutp, 'PDelta')
            PDelta = regOutp.PDelta;
            if isNamedMatrix
                PDelta = namedmat(PDelta, namesOutLik, namesOutLik);
            end
        end
    end
    info.Outlik.(MEAN_OUTPUT) = delta;
    info.Outlik.(MSE_OUTPUT) = PDelta;


    %
    % Update dynamic links
    %
    if any(this.Link)
        this = refresh(this);
    end

end%

