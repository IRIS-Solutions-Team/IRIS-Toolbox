function varargout = omega(this, newOmg)
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
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

%--------------------------------------------------------------------------

if nargin<2
    varargout{1} = getIthOmega(this, ':');
else
    % Assign StdCorr vector from Omega
    nv = length(this.Variant);
    newOmg = newOmg(:, :, :);
    vecStdCorr = covfun.cov2stdcorr(newOmg);
    vecStdCorr = permute(vecStdCorr, [3, 1, 2]);
    if size(vecStdCorr, 3)<nv
        vecStdCorr(1, :, end+1:nv) = vecStdCorr(1, :, end*ones(1, nv-end));
    end
    this.Variant.StdCorr(:, :, :) = vecStdCorr;
    varargout{1} = this;
end

end
