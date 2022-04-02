classdef Plan
    methods (Abstract)
        getEndogenousForPlan
        getExogenousForPlan
        getAutoswapsForPlan
        getSigmasForPlan
    end % methods


    methods
        function slackPairs = getSlackPairsForPlan(this, varargin)
            slackPairs = string.empty(0, 2);
        end%
    end % methods


    methods (Abstract)
        varargout = getExtendedRange(varargin)
    end % methods


    methods (Hidden)
        varargout = preparePlan(varargin)
        varargout = checkPlanConsistency(varargin)
    end % methods
end % classdef

