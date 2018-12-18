classdef Data
    properties (Abstract, Dependent)
        NumOfVariants
        NamesOfAppendablesInData
    end


    methods (Hidden)
        varargout = appendData(varargin)
        varargout = checkInputDatabank(varargin)
        varargout = requestData(varargin)
    end
end
