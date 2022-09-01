function [info, this] = postprocessKalmanOutput(this, minusLogLik, regOutp, extdRange, opt)

    TIME_SERIES_TEMPLATE = Series();
    MEAN_OUTPUT = iris.mixin.Kalman.MEAN_OUTPUT;
    MSE_OUTPUT = iris.mixin.Kalman.MSE_OUTPUT;
    startDate = extdRange(1);

    info = struct();
    info.MinusLogLik = minusLogLik;


    %
    % FMSE for measurement variables and prediction errors
    %
    F = [];
    if isfield(regOutp, 'F')
        F = fill( ...
            TIME_SERIES_TEMPLATE ...
            , permute(regOutp.F, [3, 1, 2, 4]) ...
            , startDate ...
        );
    end
    info.FMSE = F;


    %
    % Prediction errors
    %
    pe = [];
    if isfield(regOutp, 'Pe')
        pe = fill( ...
            TIME_SERIES_TEMPLATE ...
            , permute(regOutp.Pe, [2, 3, 1]) ...
            , startDate ...
            , "Prediction errors" ...
        );
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
    delta = [];
    PDelta = [];
    if isfield(regOutp, 'Delta')
        delta = permute(regOutp.Delta, [3, 1, 2]);
        if isfield(regOutp, 'PDelta')
            PDelta = regOutp.PDelta;
        end
    end
    info.Outlik.(MEAN_OUTPUT) = delta;
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
    % Update the std parameters
    %
    if opt.Relative && isfield(info, 'StdScale')
        this = rescaleStd(this, info.StdScale);
    end

end%

