% Rectangular
%
% Simulate system with rectangular (non-triangular) transition matrix off
% a straight data matrix.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef Rectangular < handle
    properties
        Solution = cell(1, 6)   % Solution matrices {T, R, K, Z, H, D}
        Expansion = cell(1, 5)  % Solution expansion matrices {Xa, Xf, Ru, J, Yu}
        IndexOfLog              % Index of log variables
        IdOfObserved            % Positions of observed variables
        IdOfStates              % Positions and shifts of state variables
        IdOfShocks              % Positions of shocks
        IdOfExogenous           % Positions of exogenous variables
        Expected                % Function to retrieve expected shocks from data
        Unexpected              % Function to retrieve unexpected shocks from data
    end


    properties (Dependent)
        NumOfObserved
        NumOfStates
        NumOfForward
        NumOfBackward
        NumOfShocks
        NumOfExogenous
        LenOfExpansion
    end


    methods
        flat(varargin)
    end


    methods (Static)
        function this = fromModel(model, variantRequested, anticipate)
            this = simulate.Rectangular( );
            keepExpansion = true;
            triangular = false;
            [this.Solution{:}] = sspaceMatrices(model, variantRequested, keepExpansion, triangular);
            [this.Expansion{:}] = expansionMatrices(model, variantRequested, triangular);
            this.IndexOfLog = get(model, 'Quantity.IxLog');
            solutionVector = get(model, 'Vector.Solution');
            this.IdOfObserved = solutionVector{1}(:);
            this.IdOfStates = solutionVector{2}(:);
            this.IdOfShocks = solutionVector{3}(:);
            this.IdOfExogenous = solutionVector{5}(:);
            if anticipate
                this.Expected = @real;
                this.Unexpected = @imag;
            else
                this.Expected = @imag;
                this.Unexpected = @real;
            end
        end
    end


    methods
        function n = get.NumOfObserved(this)
            n = numel(this.IdOfObserved);
        end

        
        function n = get.NumOfStates(this)
            n = numel(this.IdOfStates);
        end


        function n = get.NumOfBackward(this)
            n = size(this.Solution{1}, 2);
        end


        function n = get.NumOfForward(this)
            n = this.NumOfStates - this.NumOfBackward;
        end


        function n = get.NumOfShocks(this)
            n = numel(this.IdOfShocks);
        end


        function n = get.NumOfExogenous(this)
            n = numel(this.IdOfExogenous);
        end


        function n = get.LenOfExpansion(this)
            ne = this.NumOfShocks;
            k = size(this.Solution{2}, 2);
            n = k / ne;
        end
    end
end

