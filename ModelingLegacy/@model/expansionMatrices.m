function varargout = expansionMatrices(this, variantRequested, triangular)

if nargin<3
    triangular = true;
end

expansion = getIthFirstOrderExpansion(this.Variant, variantRequested);

if ~triangular
    U = this.Variant.FirstOrderSolution{7};
    if size(U, 3)>1
        U = U(:, :, variantRequested);
    end
    expansion{1} = U*expansion{1};
end

[varargout{1:nargout}] = expansion{:};

end%

