function [eigenValues, eigenStability] = eig(this, variantsRequested)
% eig  Eigenvalues of the transition matrix.
%
% __Syntax__
%
%     [EigenValues, Stability] = eig(M)
%
%
% __Input Arguments
%
% * `M` [ model ] - Model object whose eigenvalues will be returned.
%
%
% __Output Arguments__
%
% * `EigenValues` [ numeric ] - Array of all eigenvalues associated with
% the model, i.e. all stable, unit, and unstable roots are included.
%
% * `Stability` [ int8 ] - Classification of each root in the `EigenValues`
% vector: `0` means a stable root, `1` means a unit root, `2` means an
% unstable root. `Stability` is filled with `0`s in models or parameter
% variants where no solution has been computed.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if nargin<2 || isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = ':';
end

%--------------------------------------------------------------------------

eigenValues = this.Variant.EigenValues(:, :, variantsRequested);
if nargout>1
    eigenStability = this.Variant.EigenStability(:, :, variantsRequested);
end

end
