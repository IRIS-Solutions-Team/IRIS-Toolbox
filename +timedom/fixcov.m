function X = fixcov(X, tolerance)
% fixcov  Remove numerically negative diagonals from covariance matrices
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

if nargin<2
    tolerance = iris.mixin.Tolerance.DEFAULT_MSE;
end
    
%--------------------------------------------------------------------------

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
    % Set very small or negative entries to zero
    inxToFix = abs(diag(X(:, :, i)))<tolerance;
    if any(inxToFix)
        X(inxToFix, inxToFix, i) = 0;
    end
    if ~isRealX
        inxToFix = abs(diag(imagX(:, :, i)))<tolerance;
        if any(inxToFix)
            imagX(inxToFix, inxToFix, i) = 0;
        end
    end
end

if ~isRealX
    X = X + 1i*imagX;
end

if ndimsX>3
    X = reshape(X, sizeX);
end

end%

