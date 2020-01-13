classdef Plan
    methods (Abstract, Access=protected)
        getEndogenousForPlan
        getExogenousForPlan
        getAutoswapsForPlan
        getSigmasForPlan
    end


    methods (Abstract)
        varargout = getExtendedRange(varargin)
    end


    methods (Hidden)
        varargout = preparePlan(varargin)
        varargout = checkCompatibilityOfPlan(varargin)
    end
end

