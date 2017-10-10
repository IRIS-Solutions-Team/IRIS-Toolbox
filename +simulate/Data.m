classdef Data < handle
    properties
        YXEPG = double.empty(0) % NQ-by-T matrix of [observed; endogenous; expected shocks; parameters; exogenous]
        U = double.empty(0) % NE-by-T matrix of unexpected shocks
        L = double.empty(0) % NYX-by-T matrix of steady levels for [observed; endogenous]
    end
end
