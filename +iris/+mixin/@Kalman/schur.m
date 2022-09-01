function [T, U, orderedEigenValues, eigenStability] = schur(A, tolerance)

    try, tolerance = double(tolerance(1));
        catch, tolerance = iris.mixin.Tolerance.DEFAULT_EIGEN;
    end

    numXi = size(A, 1);
    nv = size(A, 3);
    T = nan(numXi, numXi, nv);
    U = nan(numXi, numXi, nv);
    orderedEigenValues = nan(1, numXi, nv);
    eigenStability = zeros(1, numXi, nv, 'int8');

    for v = 1 : nv
        if any(any(isnan(A(:, :, v))))
            continue
        end

        [U__, T__] = schur(A(:, :, v));
        eigenVal = ordeig(T__);
        eigenVal = reshape(eigenVal, 1, []);
        inxUnstableRoots = abs(eigenVal) > 1 + tolerance;
        inxUnitRoots = abs(abs(eigenVal) - 1) <= tolerance;
        numUnstableRoots = nnz(inxUnstableRoots);
        numUnitRoots = nnz(inxUnitRoots);
        clusters = zeros(size(eigenVal));
        clusters(inxUnstableRoots) = 2; % Unstable roots first
        clusters(inxUnitRoots) = 1; % Unit roots second, stable roots last
        [U(:, :, v), T(:, :, v)] = ordschur(U__, T__, clusters);
        orderedEigenValues(1, :, v) = reshape(ordeig(T(:, :, v)), 1, []);
        eigenStability(1, 1:numUnstableRoots, v) = 2;
        eigenStability(1, numUnstableRoots+(1:numUnitRoots), v) = 1;
        eigenStability(1, numUnstableRoots+numUnitRoots+1:end, v) = 0;
    end

end%

