function varargout = expansionMatrices(this, variantRequested, triangular)
if nargin<3
    triangular = true;
end
expansion = getIthExpansion(this.Variant, variantRequested);
if ~triangular
    vthU = this.Variant.Solution{7}(:, :, variantRequested);
    expansion{1} = vthU*expansion{1};
end
[varargout{1:nargout}] = expansion{:};
end

