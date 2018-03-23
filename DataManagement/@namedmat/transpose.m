function This = transpose(This)
% transpose  Transpose each page of matrix with names rows and columns.
%
% Syntax
% =======
%
%     X = transpose(X)
%     X = X.'
%
% Input arguments
% ================
% 
% * `X` [ namedmat ] - Input matrix or array with named rows and columns.
%
% Output arguments
% =================
%
% * `X` [ namedmat ] - Transpose of the input matrix; if it is more than
% 2-dimensional, each page of the matrix is transposed.
%
% Description
% ============
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

rowNames = This.RowNames;
colNames = This.ColNames;

This = double(This);
n = ndims(This);
This = permute(This,[2,1,3:n]);

This = namedmat(This,colNames,rowNames);

end
