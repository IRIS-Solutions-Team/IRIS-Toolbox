classdef Model < model
    methods
        function this = Model(varargin)
            this = this@model(varargin{:});
        end%

        varargout = simulate(varargin)
    end


    methods (Hidden) 
        varargout = checkCompatibilityOfPlan(varargin)
        varargout = checkInitialConditions(varargin)
        varargout = getIdOfInitialConditions(varargin)
        varargout = getInxOfInitInPresample(varargin)
        varargout = simulateFirstOrder(varargin)
    end
end
