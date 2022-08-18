function [Omg, stdcorr] = getIthOmega(this, variantsRequested, overrideStdcorr, multiplyStd, numPeriods)

if nargin<=1
    variantsRequested = 1 : countVariants(this);
end

inxE = getIndexByType(this.Quantity, 31, 32);
ne = nnz(inxE);

stdcorr = getIthStdcorr(this, variantsRequested);
stdcorr = permute(stdcorr, [2, 3, 1]);
if nargin>=3
    stdcorr = this.combineStdcorr(stdcorr, overrideStdcorr, multiplyStd, numPeriods);
end

Omg = covfun.stdcorr2cov(stdcorr, ne);

end%

