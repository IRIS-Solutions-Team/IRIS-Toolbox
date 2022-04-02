classdef DatabankPipe
    methods (Hidden)
        varargout = appendData(varargin)
        varargout = checkInputDatabank(varargin)
        varargout = requestData(varargin)
        varargout = ensureLog(varargin)
    end


    methods (Abstract, Hidden)
        varargout = nameAppendables(varargin)
        varargout = countVariants(varargin)
    end


    methods (Abstract)
        varargout = getActualMinMaxShifts(varargin)
    end


    methods
        varargout = getExtendedRange(varargin)
    end
end

