function [x, stab] = eig(this, vecAlt)
% eig  Eigenvalues of the transition matrix.
%
% Syntax
% =======
%
%     [e, stab] = eig(m)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object whose eigenvalues will be returned.
%
%
% Output arguments
% =================
%
% * `e` [ numeric ] - Array of all eigenvalues associated with the model,
% i.e. all stable, unit, and unstable roots are included.
%
% * `stab` [ int8 ] - Classification of individual eigenvalues in `e`: `0`
% means a stable root (or a model with no solution), `1` means a unit root,
% `2` means an unstable root.
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

try
    if isequal(vecAlt, Inf)
        vecAlt = ':';
    end
catch
    vecAlt = ':';
end

if isequal(vecAlt, ':') && numel(this.Variant)==1
    vecAlt = 1;
end

%--------------------------------------------------------------------------

if isnumericscalar(vecAlt)
    x = this.Variant{vecAlt}.Eigen;
    if nargout>1
        stab = this.Variant{vecAlt}.Stability;
    end
else
    x = model.Variant.get(this.Variant, 'Eigen', vecAlt);
    if nargout>1
        stab = model.Variant.get(this.Variant, 'Stability', vecAlt);
    end
end

end
