classdef (Abstract) Data
    properties (Abstract, Dependent)
        NumVariants
        NamesAppendable
    end


    methods (Hidden)
        varargout = appendData(varargin)
        varargout = checkInputDatabank(varargin)
        varargout = requestData(varargin)
    end
end
