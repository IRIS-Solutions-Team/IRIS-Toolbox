classdef PairingUnderConstruction < handle
    properties
        Type = repmat(parser.PairingUnderConstruction.PAIRING_TYPE(0), 1, 0)
        Lhs = cell(1, 0)
        Rhs = cell(1, 0)
    end


    properties (Constant)
        PAIRING_TYPE = @int8
    end
end
