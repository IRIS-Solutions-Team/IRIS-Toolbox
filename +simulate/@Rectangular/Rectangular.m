% Rectangular
%
% Simulate system with rectangular (non-triangular) transition matrix.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef Rectangular < handle
    properties
        Solution = cell(1, 6)
        Expansion = cell(1, 5)
        IdOfObserved
        IdOfStates
        IdOfShocks
        IdOfExogenous
        Expected
        Unexpected
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
            [this.Expansion{:}] = expansionMatrices(model, variantRequested);
            solution = get(model, 'Vector:Solution');
            this.IdOfObserved = solution{1}(:);
            this.IdOfStates = solution{2}(:);
            this.IdOfShocks = solution{3}(:);
            this.IdOfExogenous = solution{5}(:);
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

