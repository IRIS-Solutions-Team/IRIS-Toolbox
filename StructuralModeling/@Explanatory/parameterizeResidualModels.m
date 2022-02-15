function output = parameterizeResidualModels(this)

nv = countVariants(this);
nq = numel(this);
output = repmat(Armani( ), nq, nv);
for q = 1 : nq
    for v = 1 : nv
        output(q, v) = Armani.fromParamArmani(this(q).ResidualModel, v);
    end
end

end%

