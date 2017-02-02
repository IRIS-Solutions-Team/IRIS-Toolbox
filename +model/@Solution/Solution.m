classdef Solution
    properties
        NUnit = NaN     % Number of unit root elements in alpha.
        NStable = NaN   % Number of stable elements in alpha.
        
        T
        R
        k
        Z
        H
        d
        U
        Y
        ZZ
        
        StateVec
        StdCorr
    end
    
    
    
    
    properties (Constant)
        DIFFUSE_SCALE = 1e8
    end
    
    
    
    
    methods
        function this = Solution(varargin)
            if nargin==0
                return
            end
            if isnumeric(varargin{1}) && any( length(varargin{1})==[3, 4, 5] )
                this = preallocate(this, varargin{1});
            end
        end
    end
    
    
    
    
    methods
        varargout = preallocate(varargin)
        varargout = sizeOfSolution(varargin)
    end
end
