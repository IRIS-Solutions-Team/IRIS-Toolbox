function n = length(this)
% length  Number of model variants.
%
% Syntax
% =======
%
%     N = length(M)
%
%
% Input arguments
% ================
%
% * `M` [ model | esteq ] - Model or esteq object.
%
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of model variants.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

n = length(this.Variant);

end
