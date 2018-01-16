function [Omg, vecStdCorr] = getIthOmega(this, variantsRequested)
% getIthOmega  Get covariance matrix of shocks from StdCorr vector
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

if nargin<2
    variantsRequested = ':';
end

ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ne = sum(ixe);
vecStdCorr = this.Variant.StdCorr(:, :, variantsRequested);
vecStdCorr = permute(vecStdCorr, [2, 3, 1]);
Omg = covfun.stdcorr2cov(vecStdCorr, ne);

end
