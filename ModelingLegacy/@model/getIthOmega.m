function [Omg, stdcorr] = getIthOmega(this, variantsRequested, overrideStdcorr, multiplyStd, numPeriods)
% getIthOmega  Get covariance matrix of shocks from Stdcorr vector possibly combining it with user supplied time varying numbers
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

if nargin<2
    variantsRequested = 1 : countVariants(this);
end

%--------------------------------------------------------------------------

inxE = getIndexByType(this.Quantity, TYPE(31), TYPE(32));
ne = nnz(inxE);

stdcorr = getIthStdcorr(this, variantsRequested);
stdcorr = permute(stdcorr, [2, 3, 1]);
if nargin>2
    stdcorr = this.combineStdcorr(stdcorr, overrideStdcorr, multiplyStd, numPeriods);
end

Omg = covfun.stdcorr2cov(stdcorr, ne);

end%

