function this = stdscale(this, factor)

ne = nnz(this.Quantity.Type==31 | this.Quantity.Type==32);

factor = factor(:);
if all(factor==1)
    return
elseif all(factor==0)
    this.Variant.StdCorr(:, 1:ne, :) = 0;
    return
end

nv = length(this);
numOfFactors = length(factor);
if numOfFactors==1 && nv>1
    factor = repmat(factor, 1, nv);
end

for v = 1 : nv
    this.Variant.StdCorr(:, 1:ne, v) = this.Variant.StdCorr(:, 1:ne, v) * factor(v);
end

end%

