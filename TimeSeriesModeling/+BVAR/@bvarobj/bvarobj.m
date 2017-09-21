classdef bvarobj
    % bvarobj  [Not a public class] Bayesian VAR object for creating dummy observations
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2017 IRIS Solutions Team.
    
    properties
        name = '';
        y0 = '';
        y1 = '';
        k0 = '';
        g1 = '';
    end
    
    methods
        
        function This = bvarobj(varargin)
            if length(varargin) == 1 ...
                    && isa(varargin{1},'bvarobj')
                This = varargin{1};
                return
            end
        end
        
        function Flag = isempty(This)
            Flag = isempty(This.y0);
        end
        
        function [Lhs,Rhs] = dummyobs(This,varargin)
            Lhs = This.y0(varargin{:});
            Rhs = [ ...
                This.k0(varargin{:}); ...
                This.y1(varargin{:}); ...
                This.g1(varargin{:}); ...
                ];
        end % dummyobs( ).
        
        
        
    end
    
end