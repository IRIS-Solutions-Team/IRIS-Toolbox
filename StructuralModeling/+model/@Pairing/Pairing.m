classdef Pairing
    properties
        Autoswaps
        Dtrends
        Assignments

        % Slacks  In optimal policy models and comodels, Slacks(k)=n if
        % k-th name is a regular transition variable (not a Lagrange
        % multiplier) and n is the tune (shock) placed in the derivate of
        % the Lagrangian wrt to k-th variable; otherwise Slacks(k)=0
        Slacks = double.empty(1, 0)

        % Costds  In comodels, Costds(k)=n if k-th name is a conditioning
        % shock turned to a transition variable, and n is the parameter
        % controlling the std of the shock in the loss function
        Costds = double.empty(1, 0)
    end


    methods
        function this = Pairing(numQuantities, numEquations)
            if nargin==0
                numQuantities = 0;
                numEquations = 0;
            end
            this.Autoswaps = model.Pairing.initAutoswaps(numQuantities);
            this.Dtrends = model.Pairing.initDtrends(numEquations);
            this.Assignments = model.Pairing.initAssignments(numEquations);
            this.Slacks = zeros(1, numQuantities);
            this.Costds = zeros(1, numQuantities);
        end%%
    end


    properties (Dependent)
        % Autoexog  Legacy property
        Autoexog
    end


    methods
        varargout = access(varargin)

        function this = set.Autoexog(this, value)
            autoswaps = model.AutoswapStruct( );
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
            autoswaps = model.AutoswapStruct( );
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

