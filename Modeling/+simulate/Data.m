classdef Data < handle
    properties
        % YXEPG  NQ-by-T matrix of [observed; endogenous; expected shocks; parameters; exogenous]
        YXEPG = double.empty(0) 

        % U  NE-by-T matrix of unexpected shocks
        U = double.empty(0) 

        % L  NYX-by-T matrix of steady levels for [observed; endogenous]
        L = double.empty(0) 
    end
end
