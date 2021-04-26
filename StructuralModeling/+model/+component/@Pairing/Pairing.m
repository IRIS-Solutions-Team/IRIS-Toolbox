classdef Pairing
    properties
        Autoswaps
        Dtrends
        Assignments
    end


    methods
        function this = Pairing(numQuantities, numEquations)
            if nargin==0
                numQuantities = 0;
                numEquations = 0;
            end
            this.Autoswaps = model.component.Pairing.initAutoswaps(numQuantities);
            this.Dtrends = model.component.Pairing.initDtrends(numEquations);
            this.Assignments = model.component.Pairing.initAssignments(numEquations);
        end%%
    end


    properties (Dependent)
        % Autoexog  Legacy property
        Autoexog
    end


    methods
        function this = set.Autoexog(this, value)
            autoswaps = model.component.AutoswapStruct( );
            autoswaps.Simulate = value.Dynamic;
            autoswaps.Steady = value.Steady;
            this.Autoswaps = autoswaps;
        end%
    end


    methods (Static)
        varargout = getAutoswaps(varargin)
        varargout = checkConsistency(varargin)
        varargout = readAssignments(varargin)
        varargout = readAutoswaps(varargin)
        varargout = setAutoswaps(varargin)
        varargout = implementGet(varargin)
    end


    methods (Static)
        function autoswaps = initAutoswaps(numQuantities)
            PTR = @int16;
            autoswaps = model.component.AutoswapStruct( );
            autoswaps.Simulate = repmat(PTR(0), 1, numQuantities);
            autoswaps.Steady = repmat(PTR(0), 1, numQuantities);
        end%


        function dtrends = initDtrends(numEquations)
            PTR = @int16;
            dtrends = repmat(PTR(0), 1, numEquations);
        end%


        function assignments = initAssignments(numEquations)
            PTR = @int16;
            assignments = struct( );
            assignments.Dynamic.Lhs = repmat(PTR(0), 1, numEquations);
            assignments.Dynamic.Type = repmat(solver.block.Type.UNKNOWN, 1, numEquations);
            assignments.Steady.Lhs = repmat(PTR(0), 1, numEquations);
            assignments.Steady.Type = repmat(solver.block.Type.UNKNOWN, 1, numEquations);
        end%
    end
end

