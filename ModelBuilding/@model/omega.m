function varargout = omega(this, newOmg, variantsRequested)
% omega  Get or set the covariance matrix of shocks.
%
% __Syntax for Getting Covariance Matrix__
%
%     Omg = omega(M)
%
%
% __Syntax for Setting Covariance Matrix__
%
%     M = omega(M, Omg)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object.
%
% * `Omg` [ numeric ] - Covariance matrix that will be converted to new
% values for std deviations and cross-corr coefficients.
%
%
% __Output Arguments__
%
% * `Omg` [ numeric ] - Covariance matrix of shocks or residuals based on
% the currently assigned std deviations and cross-correlation coefficients.
%
% * `M` [ model ] - Model object with new values for std deviations and
% cross-corr coefficients based on the input covariance matrix.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

TYPE = @int8;

try, newOmg; catch, newOmg = @get; end %#ok<NOCOM>
try, variantsRequested; catch, variantsRequested = ':'; end %#ok<NOCOM>

%--------------------------------------------------------------------------

if isequal(variantsRequested, Inf)
    variantsRequested = ':';
end

if isequal(newOmg, @get)
    % Return Omega from StdCorr vector.
    ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
    ne = sum(ixe);
    vecStdCorr = this.Variant.StdCorr(:, :, variantsRequested);
    vecStdCorr = permute(vecStdCorr, [2, 3, 1]);
    newOmg = covfun.stdcorr2cov(vecStdCorr, ne);
    varargout{1} = newOmg;
    varargout{2} = vecStdCorr;
else
    % Assign StdCorr vector from Omega.
    nv = length(this.Variant);
    newOmg = newOmg(:, :, :);
    vecStdCorr = covfun.cov2stdcorr(newOmg);
    vecStdCorr = permute(vecStdCorr, [3, 1, 2]);
    if size(vecStdCorr, 3)<nv
        vecStdCorr(1, :, end+1:nv) = vecStdCorr(1, :, end*ones(1, nv-end));
    end
    this.Variant.StdCorr(:, :, variantsRequested) = vecStdCorr;
    varargout{1} = this;
end

end
