classdef ( Abstract, ...
           CaseInsensitiveProperties=true, ...
           InferiorClasses={?matlab.graphics.axis.Axes, ?DateWrapper} ) ...
         NumericTimeSubscriptable < TimeSubscriptable

    properties
        % Data  Numeric or logical array of time series data
        Data = double.empty(0, 1) 

        % MissingValue  Representation of missing value
        MissingValue = NaN 
    end


    properties (Dependent)
        % MissingTest  Test for missing values
        MissingTest 
    end


    methods 
        function missingTest = get.MissingTest(this)
            missingValue = this.MissingValue;
            if isequaln(missingValue, NaN)
                missingTest = @isnan;
            else
                missingTest = @(x) x==missingValue;
            end
        end%
    end


    methods
        varargout = acf(varargin)
        varargout = apct(varargin)
        varargout = bubble(varargin)
        varargout = ellone(varargin)
    end


    methods (Access=protected, Hidden)
        varargout = binop(varargin)
        varargout = unop(varargin)
        varargout = unopinx(varargin)
    end


    methods (Static, Access=protected)
        varargout = plotSwitchboard(varargin)
        varargout = preparePlot(varargin)
    end
end

