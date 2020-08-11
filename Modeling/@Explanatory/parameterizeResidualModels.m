function output = parameterizeResidualModels(this)

nv = countVariants(this);
nq = numel(this);
output = repmat(Armani( ), nq, nv);
for q = 1 : nq
    for v = 1 : nv
        output(q, v) = Armani.fromParameterizedArmani(this(q).ResidualModel, this(q).ResidualModelParameters(:, :, v));
    end
end

end%

