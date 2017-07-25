function varargout = omega(this, newOmg, vecAlt)
% omega  Get or set the covariance matrix of shocks.
%
% Syntax for getting covariance matrix
% =========================================
%
%     Omg = omega(M)
%
%
% Syntax for setting covariance matrix
% =====================================
%
%     M = omega(M, Omg)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model or bkwmodel object.
%
% * `Omg` [ numeric ] - Covariance matrix that will be converted to new
% values for std deviations and cross-corr coefficients.
%
%
% Output arguments
% =================
%
% * `Omg` [ numeric ] - Covariance matrix of shocks or residuals based on
% the currently assigned std deviations and cross-correlation coefficients.
%
% * `M` [ model ] - Model object with new values for std deviations and
% cross-corr coefficients based on the input covariance matrix.
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

%#ok<*VUNUS>
%#ok<*CTCH>

TYPE = @int8;

try, newOmg; catch, newOmg = @get; end %#ok<NOCOM>
try, vecAlt; catch, vecAlt = ':'; end %#ok<NOCOM>

%--------------------------------------------------------------------------

if isequal(vecAlt, Inf)
    vecAlt = ':';
end

if isequal(newOmg, @get)
    % Return Omega from StdCorr vector.
    ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
    ne = sum(ixe);
    vecStdCorr = model.Variant.getStdCorr(this.Variant, ':', vecAlt);
    vecStdCorr = permute(vecStdCorr, [2, 3, 1]);
    newOmg = covfun.stdcorr2cov(vecStdCorr, ne);
    varargout{1} = newOmg;
    varargout{2} = vecStdCorr;
else
    % Assign StdCorr vector from Omega.
    nAlt = length(this.Variant);
    newOmg = newOmg(:, :, :);
    vecStdCorr = covfun.cov2stdcorr(newOmg);
    vecStdCorr = permute(vecStdCorr, [3, 1, 2]);
    if size(vecStdCorr, 3)<nAlt
        vecStdCorr(1, :, end+1:nAlt) = vecStdCorr(1, :, end*ones(1, nAlt-end));
    end
    this.Variant = model.Variant.assignStdCorr( ...
        this.Variant, ':', vecAlt, vecStdCorr, ...
        this.Quantity.IxStdCorrAllowed ...
        );
    varargout{1} = this;
end

end
