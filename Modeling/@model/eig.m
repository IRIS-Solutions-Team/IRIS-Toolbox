function [eigenValues, eigenStability] = eig(this, variantsRequested)
% eig  Eigenvalues of model transition matrix
%
% __Syntax__
%
%     [EigenVal, Stab] = eig(M)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object whose eigenvalues will be returned.
%
%
% __Output Arguments__
%
% * `EigenVal` [ numeric ] - Array of all eigenvalues associated with
% the model, i.e. all stable, unit, and unstable roots are included.
%
% * `Stab` [ int8 ] - Classification of each root in the `EigenValues`
% vector: `0` means a stable root, `1` means a unit root, `2` means an
% unstable root. `Stab` is filled with zeros in models or parameter
% variants where no solution has been computed.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if nargin<2 || isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = ':';
end

%--------------------------------------------------------------------------

eigenValues = this.Variant.EigenValues(:, :, variantsRequested);
if nargout>1
    eigenStability = this.Variant.EigenStability(:, :, variantsRequested);
end

end
