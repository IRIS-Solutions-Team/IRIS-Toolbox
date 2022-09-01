
function [triangular, eigenValues, eigenStability] ...
    = triangularize(rectangular, tolerance)

    % rectangular = {T, R, k, Z, H, d}
    % triangular = {T, R, k, Z, H, d, U, Zb}

    try, tolerance = double(tolerance(1));
        catch, tolerance = iris.mixin.Tolerance.DEFAULT_EIGEN;
    end

    [T0, R0, k0, Z0, H0, d0] = rectangular{:};

    nv = size(T0, 3);
    numXi = size(T0, 1);
    numV = size(R0, 2);
    numY = size(Z0, 1);
    numW = size(H0, 2);

    T = nan(numXi, numXi, nv);
    R = nan(numXi, numV, nv);
    k = nan(numXi, 1, nv);
    Z = nan(numY, numXi, nv);

    H = H0;
    d = d0;

    [T, U] = iris.mixin.Kalman.triangularize(T0, tolerance);
    for v = 1 : nv
        U__ = U(:, :, v);
        Ut__ = U__';
        R(:, :, v) = Ut__ * R0(:, :, v);
        k(:, :, v) = Ut__ * k0(:, :, v);
        Z(:, :, v) = Z9(:, :, v) * U__;
    end

    triangular = {T, R, k, Z, H, d, U, Z0};

end%

