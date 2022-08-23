% D2S  Conversion from derivatives to unsolved system matrices.

classdef D2S
    properties
        DerivY = double.empty(1, 0)
        DerivXfMinus = double.empty(1, 0)
        DerivXf = double.empty(1, 0)
        DerivXbMinus = double.empty(1, 0)
        DerivXb = double.empty(1, 0)
        DerivE = double.empty(1, 0)

        SystemY = double.empty(1, 0)
        SystemXfMinus = double.empty(1, 0)
        SystemXf = double.empty(1, 0)
        SystemXbMinus = double.empty(1, 0)
        SystemXb = double.empty(1, 0)
        SystemE = double.empty(1, 0)

        IndexOfXfToRemove = logical.empty(1, 0)
        IdentityA = double.empty(0, 0)
        IdentityB = double.empty(0, 0)
    end
end
