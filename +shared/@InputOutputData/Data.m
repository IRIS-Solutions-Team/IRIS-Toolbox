classdef Data
    properties (Abstract, Dependent)
        NumOfVariants
        NamesOfAppendables
    end


    properties
        NumOfAppendables
    end


    methods (Hidden)
        varargout = appendData(varargin)
        varargout = checkInputDatabank(varargin)
        varargout = requestData(varargin)
    end


    methods
        function value = get.NumOfAppendables(this)
            value = numel(this.NamesOfAppendables);
        end%
    end
end

