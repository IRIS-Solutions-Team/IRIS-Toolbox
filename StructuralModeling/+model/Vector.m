classdef Vector
    properties
        System = repmat({double.empty(1, 0)}, 1, 5)
        Solution = repmat({double.empty(1, 0)}, 1, 5)
    end


    methods
        function [ny, nxi, nb, nf, ne, ng] = sizeSolution(this)
            ny = numel(this.Solution{1});
            nxi = numel(this.Solution{2});
            nb = sum(imag(this.System{2})<0); % Needs to be Vector.System{2}
            nf = nxi - nb;
            ne = numel(this.Solution{3});
            ng = numel(this.Solution{5});
        end%


        function xbVector = getBackwardSolutionVector(this)
            [~, ~, ~, nf] = sizeSolution(this);
            xbVector = this.Solution{2}(nf+1:end);
        end%


        function xbVector = getForwardSolutionVector(this)
            [~, ~, ~, nf] = sizeSolution(this);
            xbVector = this.Solution{2}(1:nf);
        end%


        function [ky, kxi, kb, kf, ke, kg] = sizeSystem(this)
            ky = numel(this.System{1});
            kxi = numel(this.System{2});
            kb = sum(imag(this.System{2})<0);
            kf = kxi - kb;
            ke = numel(this.System{3});
            kg = numel(this.System{5});
        end%


        function flag = testCompatible(this, obj)
            flag = isa(this, 'model.Vector') && isa(obj, 'model.Vector') ...
                && isequal(this.System, obj.System) ...
                && isequal(this.Solution, obj.Solution);
        end%


        function [answ, isValid, query] = implementGet(this, query, varargin)
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
        end%
    end
end
