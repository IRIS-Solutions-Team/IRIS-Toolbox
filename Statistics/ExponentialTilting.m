classdef ExponentialTilt < handle
    properties
        Condition = [ ]
        Payoff = [ ]
        Weights double = double.empty(1, 0)
        DataCube = [ ]
    end


    methods
        function calculateWeights(this)
        end% 


        function outputData = mean(this, inputData)
        end%


        function [counts, edges] = histcounts(this, inputData, edges)
            [bins, edges] = discretize(inputData, 
        end%
    end
end
