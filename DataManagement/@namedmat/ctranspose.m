function this = ctranspose(this)
% ctranspose  Conjugate-transpose each page of matrix with names rows and columns.
%
% Syntax
% =======
%
%     X = ctranspose(X)
%     X = X'
%
% Input arguments
% ================
% 
% * `X` [ namedmat ] - Input matrix or array with named rows and columns.
%
% Output arguments
% =================
%
% * `X` [ namedmat ] - Conjugate transpose of the input matrix; if it is
% more than 2-dimensional, each page of the matrix is transposed.
%
% Description
% ============
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

rowNames = this.RowNames;
colNames = this.ColNames;

this = double(this);
n = ndims(this);
realX = real(this);
imagX = imag(this);
realX = permute(realX, [2, 1, 3:n]);
imagX = permute(imagX, [2, 1, 3:n]);
this = realX - 1i*imagX;

this = namedmat(this, colNames, rowNames);

end%

