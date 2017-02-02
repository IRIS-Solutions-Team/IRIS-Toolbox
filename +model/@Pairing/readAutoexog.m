function auto = readAutoexog(quantity, puc)

TYPE = @int8;

%--------------------------------------------------------------------------

nQty = length(quantity);
auto = model.Pairing.initAutoexog(nQty);

ix = puc.Type==TYPE(1);
if any(ix)
    lsExog = puc.Lhs(ix);
    lsEndog = puc.Rhs(ix);
    auto.Dynamic = ...
        model.Pairing.setAutoexog(auto.Dynamic, 'dynamic', quantity, lsExog, lsEndog);
end

ix = puc.Type==TYPE(2);
if any(ix)
    lsExog = puc.Lhs(ix);
    lsEndog = puc.Rhs(ix);
    auto.Steady = ...
        model.Pairing.setAutoexog(auto.Steady, 'steady', quantity, lsExog, lsEndog);
end

end
