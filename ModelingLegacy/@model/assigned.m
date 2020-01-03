function [assignedValues, assignedStdCorr] = assigned(this, variantsRequested)
% assigned  Get vector of assigned quantities and vector of assigned std deviations and cross-correlations.
%
% __Syntax__
%
%     [AsgndQty, AsgndStdCorr] = assigned(M)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object whose assigned values will be returned.
%
%
% __Output Arguments__
%
% * `AsgndQty` [ numeric ] - Vector of currently assigned quantities
% (steady states of variables, parameters), ordered as follows: measurement
% variables, transition variables, shocks, parameters, exogenous variables.
%
% * `AsgndStdCorr` [ numeric ] - Vector of currently assigned std
% deviations and cross-correlations.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

if nargin<2 || isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = ':';
end

%--------------------------------------------------------------------------

assignedValues = this.Variant.Values(:, :, variantsRequested);
if nargout>1
    assignedStdCorr = this.Variant.StdCorr(:, :, variantsRequested);
end

end
