function varargout = expansionMatrices(this, variantRequested, triangular)
if nargin<3
    triangular = true;
end
expansion = getIthFirstOrderExpansion(this.Variant, variantRequested);
if ~triangular
    vthU = this.Variant.FirstOrderSolution{7}(:, :, variantRequested);
    expansion{1} = vthU*expansion{1};
end
[varargout{1:nargout}] = expansion{:};
end

