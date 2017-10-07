function varargout = expansionMatrices(this, variantsRequested)
expansion = getIthExpansion(this.Variant, variantsRequested);
[varargout{1:nargout}] = expansion{:};
end

