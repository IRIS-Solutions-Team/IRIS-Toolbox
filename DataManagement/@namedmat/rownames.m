function RowNames = rownames(This)
% rownames  Names of rows in namedmat object.
%
% Syntax
% =======
%
%     RowNames = rownames(X)
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
% * `RowNames` [ cellstr ] - Names of rows in `X`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

RowNames = This.RowNames;

end
