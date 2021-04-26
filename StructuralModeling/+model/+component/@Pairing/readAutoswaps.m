function autoswaps = readAutoswap(quantity, puc)

numQuantities = numel(quantity);
autoswaps = model.component.Pairing.initAutoswaps(numQuantities);

ix = puc.Type==1;
if any(ix)
    namesToExogenize = puc.Lhs(ix);
    namesToEndogenize = puc.Rhs(ix);
    autoswaps.Simulate = model.component.Pairing.setAutoswaps( ...
        autoswaps.Simulate, "simulate"...
        , quantity, namesToExogenize, namesToEndogenize ...
    );
end

ix = puc.Type==2;
if any(ix)
    namesToExogenize = puc.Lhs(ix);
    namesToEndogenize = puc.Rhs(ix);
    autoswaps.Steady = model.component.Pairing.setAutoswaps( ...
        autoswaps.Steady, "steady"...
        , quantity, namesToExogenize, namesToEndogenize ...
    );
end

end%

