function this = transpose(this)
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
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

rowNames = this.RowNames;
colNames = this.ColNames;

this = double(this);
n = ndims(this);
this = permute(this, [2, 1, 3:n]);

this = namedmat(this, colNames, rowNames);

end%

