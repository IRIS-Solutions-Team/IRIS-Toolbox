function this = expand(this, k)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model/expand');
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model'));
    INPUT_PARSER.addRequired('Forward', @(x) isnumeric(x) && numel(x)==1 && x>=0 && x==round(x));
end
INPUT_PARSER.parse(this, k);

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==31 | this.Quantity.Type==32;
ne = nnz(ixe);
nh = nnz(this.Equation.IxHash);
nv = length(this);

if ne==0 && nh==0
    return
end

R = this.Variant.FirstOrderSolution{2}(:, 1:ne, :); % Impact matrix of structural shocks.
Y = this.Variant.FirstOrderSolution{8}(:, 1:nh, :); % Impact matrix of non-linear add-factors.

newR = [R, nan(size(R, 1), ne*k, nv)];
newY = [Y, nan(size(Y, 1), nh*k, nv)];
for v = 1 : nv
    vthR = R(:, :, v);
    vthY = Y(:, :, v);
    vthExpansion = getIthFirstOrderExpansion(this.Variant, v);
    [newR(:, :, v), newY(:, :, v)] = model.expandFirstOrder(R(:, :, v), Y(:, :, v), vthExpansion, k);
end
this.Variant.FirstOrderSolution{2} = newR;
this.Variant.FirstOrderSolution{8} = newY;

end
