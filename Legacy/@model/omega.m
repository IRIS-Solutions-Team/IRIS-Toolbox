function varargout = omega(this, newOmg)
% omega  Get or set the covariance matrix of shocks.
%
% ## Syntax for Getting Covariance Matrix ##
%
%     Omg = omega(M)
%
%
% ## Syntax for Setting Covariance Matrix ##
%
%     M = omega(M, Omg)
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Model object.
%
% * `Omg` [ numeric ] - Covariance matrix that will be converted to new
% values for std deviations and cross-corr coefficients.
%
%
% ## Output Arguments ##
%
% * `Omg` [ numeric ] - Covariance matrix of shocks or residuals based on
% the currently assigned std deviations and cross-correlation coefficients.
%
% * `M` [ model ] - Model object with new values for std deviations and
% cross-corr coefficients based on the input covariance matrix.
%
%
% ## Description ##
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

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
