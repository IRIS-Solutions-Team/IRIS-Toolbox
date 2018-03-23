classdef InpData < handle
    properties
        Range   % Filter range
        y       % Observations with k-step ahead predictions
        aInit   % User-supplied initial condition for a(0|0)
        PaInit  % User-supplied initial condition for Pa(0|0)
    end
    
    
    
    
    methods
        function this = InpData(varargin)
        end
    end
end