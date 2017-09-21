classdef (Abstract, InferiorClasses={?matlab.graphics.axis.Axes}) Abstract
    properties (Abstract)
        Start
        Data
        MissingValue
    end


    properties (Dependent)
        Frequency
    end


    properties (Abstract, Dependent)
        MissingTest
    end


    methods (Abstract)
        varargout = getFrequency(varargin)
    end


    methods (Access=protected)
        varargout = getDataNoFrills(varargin)
    end


    methods
        function frequency = get.Frequency(this)
            frequency = getFrequency(this);
        end
    end
end
