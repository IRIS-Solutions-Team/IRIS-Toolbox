function autoswap = readAutoswap(quantity, puc)

TYPE = @int8;

%--------------------------------------------------------------------------

numOfQuantities = length(quantity);
autoswap = model.component.Pairing.initAutoswap(numOfQuantities);

ix = puc.Type==TYPE(1);
if any(ix)
    lsExog = puc.Lhs(ix);
    lsEndog = puc.Rhs(ix);
    autoswap.Simulate = ...
        model.component.Pairing.setAutoswap( autoswap.Simulate, 'Simulate', ...
                                             quantity, lsExog, lsEndog );
end

ix = puc.Type==TYPE(2);
if any(ix)
    lsExog = puc.Lhs(ix);
    lsEndog = puc.Rhs(ix);
    autoswap.Steady = model.component.Pairing.setAutoswap( ...
        autoswap.Steady, 'Steady' ...
        , quantity, lsExog, lsEndog ...
    );
end

end%

