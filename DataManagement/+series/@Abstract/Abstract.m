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


        function output = applyFunctionAlongDim(this, func, varargin)
            [output, dim] = func(x.Data, varargin{:});
            if dim>1
                output = fill(this, output, '', [ ]);
            end
        end
    end
end
