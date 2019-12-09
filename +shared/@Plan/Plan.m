classdef Plan
    methods (Abstract, Access=protected)
        getEndogenousForPlan
        getExogenousForPlan
        getAutoswapsForPlan
        getSigmasForPlan
    end


    methods
        varargout = preparePlan(varargin)
    end
end

