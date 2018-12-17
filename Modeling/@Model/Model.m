classdef Model < model
    methods
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
