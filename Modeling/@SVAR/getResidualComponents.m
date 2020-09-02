function [covResiduals, matResiduals] = getResidualComponents(this, variantsRequested)

if nargin<2
    variantsRequested = ':';
    numVariantsRequested = countVariants(this);
else
    numVariantsRequested = numel(variantsRequested);
end

covResiduals = repmat(eye(this.NumEndogenous), 1, 1, numVariantsRequested);

if nargout>=2
    matResiduals = this.B(:, :, variantsRequested);
end

end%


