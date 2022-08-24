function [assignedValues, assignedStdCorr] = assigned(this, variantsRequested)

if nargin<2 || isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = ':';
end

%--------------------------------------------------------------------------

assignedValues = this.Variant.Values(:, :, variantsRequested);
if nargout>1
    assignedStdCorr = this.Variant.StdCorr(:, :, variantsRequested);
end

end
