function rect = prepareRectangular( ...
    this, inputDatabank, range, variantRequested, dataSetRequested, anticipate ...
)

if anticipate
    expected = @real;
    unexpected = @imag;
else
    expected = @imag;
    unexpected = @real;
end

rect = simulate.Rectangular( );
data = simulate.Data;

keepExpansion = true;
triangular = false;
[rect.SolutionMatrices{1:6}] = sspaceMatrices(this, variantRequested, keepExpansion, triangular);

namesOfObserved = get(this, 'YNames');
data.Y = transpose( ...
    databank.toDoubleArrayNoFrills(inputDatabank, namesOfObserved, range, dataSetRequested) ...
);

namesOfEndogenous = get(this, 'XNames');
data.X = transpose( ...
    databank.toDoubleArrayNoFrills(inputDatabank, namesOfEndogenous, range, dataSetRequested) ...
);

namesOfShocks = get(this, 'ENames');
shocks = ( ...
    databank.toDoubleArrayNoFrills(inputDatabank, namesOfShocks, range, dataSetRequested) ...
);
data.E = 
