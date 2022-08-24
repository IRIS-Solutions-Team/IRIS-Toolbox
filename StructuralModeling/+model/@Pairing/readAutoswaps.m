function autoswaps = readAutoswap(quantity, puc)

numQuantities = numel(quantity);
autoswaps = model.Pairing.initAutoswaps(numQuantities);

ix = puc.Type==1;
if any(ix)
    namesToExogenize = puc.Lhs(ix);
    namesToEndogenize = puc.Rhs(ix);
    autoswaps.Simulate = model.Pairing.setAutoswaps( ...
        autoswaps.Simulate, "simulate"...
        , quantity, namesToExogenize, namesToEndogenize ...
    );
end

ix = puc.Type==2;
if any(ix)
    namesToExogenize = puc.Lhs(ix);
    namesToEndogenize = puc.Rhs(ix);
    autoswaps.Steady = model.Pairing.setAutoswaps( ...
        autoswaps.Steady, "steady"...
        , quantity, namesToExogenize, namesToEndogenize ...
    );
end

end%

