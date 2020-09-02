function ColNames = colnames(this)
% colnames  Names of columns in namedmat object.
%
% Syntax
% =======
%
%     ColNames = colnames(X)
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
% * `ColNames` [ cellstr ] - Names of columns in `X`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

ColNames = this.ColNames;

end%

