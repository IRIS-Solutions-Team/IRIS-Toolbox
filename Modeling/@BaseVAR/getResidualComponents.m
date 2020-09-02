function [covResiduals, matResiduals] = getResidualComponents(this, variantsRequested)

if nargin<2
    variantsRequested = ':';
    numVariantsRequested = countVariants(this);
else
    numVariantsRequested = numel(variantsRequested);
end

covResiduals = this.Omega(:, :, variantsRequested);

if nargout>=2
    matResiduals = repmat(eye(this.NumEndogenous), 1, 1, numVariantsRequested);
end

end%

