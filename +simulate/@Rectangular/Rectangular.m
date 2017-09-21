% Rectangular
%
% Simulate system with rectangular (non-triangular) transition matrix.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef Rectangular < handle
    properties
        SolutionMatrices = cell(1, 6)
        IdOfObserved
        IdOfEndogenous
        IdOfStates
        IdOfShocks
        IdOfExogenous
    end


    properties (Dependent)
        NumOfObserved
        NumOfEndogenous
        NumOfStates
        NumOfBackward
        NumOfShocks
        NumOfExogenous
        LenOfExpansion
    end


    methods
        function this = Rectangular(model, inputDatabank, simulationRange)
            
        flat(varargin)
    end


    methods
        function n = get.NumOfObserved(this)
            n = numel(this.IdOfObserved);
        end

        
        function n = get.NumOfEndogenous(this)
            n = numel(this.IdOfEndogenous);
        end


        function n = get.NumOfStates(this)
            n = numel(this.IdOfStates);
        end


        function n = get.NumOfBackward(this)
            n = size(this.SolutionMatrices{1}, 2);
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
            k = size(this.SolutionMatrices{2}, 2);
            n = k / ne;
        end
    end
end

