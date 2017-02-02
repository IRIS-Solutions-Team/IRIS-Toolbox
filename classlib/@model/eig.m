function x = eig(this, vecAlt)
% eig  Eigenvalues of the transition matrix.
%
% Syntax
% =======
%
%     e = eig(m)
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
    vecAlt; %#ok<VUNUS>
catch
    vecAlt = ':';
end

if isequal(vecAlt, Inf)
    vecAlt = ':';
end

%--------------------------------------------------------------------------

x = model.Variant.get(this.Variant, 'Eigen', vecAlt);

end
