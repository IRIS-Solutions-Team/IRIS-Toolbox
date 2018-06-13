classdef (CaseInsensitiveProperties=true) ...
    FAVAR < DFM
    methods
        function this = FAVAR(varargin)
            this = this@DFM(varargin{:});
        end
    end
end
