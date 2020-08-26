classdef Vector
    properties
        System = repmat({double.empty(1, 0)}, 1, 5)
        Solution = repmat({double.empty(1, 0)}, 1, 5)
    end
    
    
    methods
        function [ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this)
            ny = length(this.Solution{1});
            nxi = length(this.Solution{2});
            nb = sum( imag(this.System{2})<0 ); % Needs to be Vector.System{2}
            nf = nxi - nb;
            ne = length(this.Solution{3});
            ng = length(this.Solution{5});
        end
        
        
        function [ky, kxi, kb, kf, ke, kg] = sizeOfSystem(this)
            ky = length(this.System{1});
            kxi = length(this.System{2});
            kb = sum( imag(this.System{2})<0 );
            kf = kxi - kb;
            ke = length(this.System{3});
            kg = length(this.System{5});
        end
        
        
        function flag = testCompatible(this, obj)
            flag = isa(this, 'model.component.Vector') && isa(obj, 'model.component.Vector') ...
                && isequal(this.System, obj.System) ...
                && isequal(this.Solution, obj.Solution);
        end


        function [answ, isValid, query] = implementGet(this, query, varargin)
            TYPE = @int8;
            answ = [ ];
            isValid = true;
            compare = @(x, y) any(strcmpi(x, y));
            if compare(query, {'Vector.Solution', 'Vector:Solution'})
                answ = this.Solution;
                return
            elseif compare(query, {'Vector.System', 'Vector:System'})
                answ = this.System;
            else
                isValid = false;
            end
        end
    end
end
