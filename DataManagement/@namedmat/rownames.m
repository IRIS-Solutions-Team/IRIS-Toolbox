function rowNames = rownames(this)
% rownames  Names of rows in namedmat object.
%
% Syntax
% =======
%
%     rowNames = rownames(X)
%
% Input arguments
% ================
%
% * `X` [ namedmat ] - A namedmat object (array with named rows and
% columns) returned as output argument from some model functions.
%
% Output arguments
% =================
%
% * `rowNames` [ cellstr ] - Names of rows in `X`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

%--------------------------------------------------------------------------

rowNames = this.RowNames;

end%

