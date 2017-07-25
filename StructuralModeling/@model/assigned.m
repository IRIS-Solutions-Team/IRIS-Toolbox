function [asgndQty, asgndStdCorr] = assigned(this, vecAlt)
% assigned  Get vector of assigned quantities and vector of assigned std deviations and cross-correlations.
%
% Syntax
% =======
%
%     [asgndQty, asgndStdCorr] = assigned(m)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object whose assigned values will be returned.
%
%
% Output arguments
% =================
%
% * `asgndQty` [ numeric ] - Vector of currently assigned quantities
% (steady states of variables, parameters), ordered as follows: measurement
% variables, transition variables, shocks, parameters, exogenous variables.
%
% * `asgndStdCorr` [ numeric ] - Vector of currently assigned std
% deviations and cross-correlations.
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
    asgndQty = this.Variant{vecAlt}.Quantity;
    if nargout>1
        asgndStdCorr = this.Variant{vecAlt}.StdCorr;
    end
else
    asgndQty = model.Variant.get(this.Variant, 'Quantity', vecAlt);
    if nargout>1
        asgndStdCorr = model.Variant.get(this.Variant, 'StdCorr', vecAlt);
    end
end

end
