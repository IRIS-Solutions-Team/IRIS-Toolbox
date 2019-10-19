classdef DatabankPipe
    properties (Abstract, Dependent)
        NumVariants
        NamesOfAppendables
    end


    properties
        NamesInDatabank
        NumOfAppendables
    end


    methods (Hidden)
        varargout = appendData(varargin)
        varargout = checkInputDatabank(varargin)
        varargout = defineNamesInDatabank(varargin)
        varargout = requestData(varargin)
        varargout = substituteNamesInDatabank(varargin)
    end


    methods
        function value = get.NumOfAppendables(this)
            value = numel(this.NamesOfAppendables);
        end%
    end
end

