function X = fixcov(X)
% fixcov  [Not a public function] Remove numerically negative diagonals from covariance matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

tol = model.DEFAULT_MSE_TOLERANCE;

% Unfold x in 3rd dimension. This is to handle 4-th and higher
% dimensional matrices without having to detect the exact structure of
% dimensions.
xSize = size(X);
X = X(:,:,:);

realX = real(X);
imagX = imag(X);
for i = 1 : size(X,3)
    % Set very small or negative entries to zero.
    inx = abs(diag(realX(:,:,i))) < tol;
    if any(inx)
        realX(inx,inx,i) = 0;
    end
    inx = abs(diag(imagX(:,:,i))) < tol;
    if any(inx)
        imagX(inx,inx,i) = 0;
    end
end
X = realX + 1i*imagX;

% Get `X` back in shape.
if length(xSize) > 3
    X = reshape(X,xSize);
end

end