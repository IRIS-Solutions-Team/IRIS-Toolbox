classdef Link
    properties
        Input = cell.empty(1, 0)    % Input equation
        LhsPtr = int8.empty(1, 0)   % LHS pointer
        RhsExpn = cell.empty(1, 0)  % RHS expression
        Order = int16.empty(1, 0)   % Ordering
    end


    methods
        varargout = reorder(varargin)
        varargout = refresh(varargin)


        function n = length(this)
            n = length(this.LhsPtr);
        end


        function flag = isempty(this)
            flag = isempty(this.LhsPtr);
        end


        function flag = any(this)
            flag = any(this.LhsPtr>0);
        end


        function vec = getActiveLhsPtr(this)
            PTR = @int16;
            ixActive = this.LhsPtr>PTR(0);
            vec = this.LhsPtr(ixActive);
        end
    end
end

