function This = ctranspose(This)
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
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

rowNames = This.RowNames;
colNames = This.ColNames;

This = double(This);
n = ndims(This);
realX = real(This);
imagX = imag(This);
realX = permute(realX,[2,1,3:n]);
imagX = permute(imagX,[2,1,3:n]);
This = realX - 1i*imagX;

This = namedmat(This,colNames,rowNames);

end
