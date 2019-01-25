function X = fixcov(X)
% fixcov  Remove numerically negative diagonals from covariance matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

tolerance = model.DEFAULT_MSE_TOLERANCE;

% Unfold x in 3rd dimension. This is to handle 4-th and higher
% dimensional matrices without having to detect the exact structure of
% dimensions.
sizeX = size(X);
ndimsX = ndims(X);
X = X(:, :, :);

isRealX = isreal(X);
if ~isRealX
    imagX = imag(X);
    X = real(X);
end

for i = 1 : size(X, 3)
    % Set very small or negative entries to zero.
    indexToFix = abs(diag(X(:, :, i)))<tolerance;
    if any(indexToFix)
        X(indexToFix, indexToFix, i) = 0;
    end
    if ~isRealX
        indexToFix = abs(diag(imagX(:, :, i)))<tolerance;
        if any(indexToFix)
            imagX(indexToFix, indexToFix, i) = 0;
        end
    end
end

if ~isRealX
    X = realX + 1i*imagX;
end

if ndimsX>3
    X = reshape(X, sizeX);
end

end
