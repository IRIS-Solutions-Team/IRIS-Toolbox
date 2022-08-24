function [T, R, K, Z, H, D, U, Zb, inxV, inxW, numUnit, inxInit] = ...
    getIthKalmanSystem(this, variantRequested, requiredForward)

if nargin<3
    requiredForward = 0;
end

%--------------------------------------------------------------------------

[~, ~, nb, ~, ne] = sizeSolution(this.Vector);
[T, R, K, Z, H, D, U, ~, Zb] = getIthFirstOrderSolution(this.Variant, variantRequested);

currentForward = size(R, 2)/ne - 1;
if requiredForward>currentForward
    expansion = getIthFirstOrderExpansion(this.Variant, variantRequested);
    R = model.expandFirstOrder(R, [ ], expansion, requiredForward);
end

if isempty(Z)    
    Z = zeros(0, nb);
end

if isempty(Zb)
    Zb = zeros(0, nb);
end

if isempty(H)
    H = zeros(0, ne);
end

if isempty(D)
    D = zeros(0, 1);
end

inxE = getIndexByType(this.Quantity, 31, 32);
inxW = this.Quantity.Type(inxE)==31;
inxV = this.Quantity.Type(inxE)==32;
numUnit = getNumOfUnitRoots(this.Variant, variantRequested);
inxInit = this.Variant.InxInit(:, :, variantRequested);

end%

