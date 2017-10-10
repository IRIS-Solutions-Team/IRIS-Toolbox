% Estimation  Estimation class.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef Estimation
    properties
    end

    
    methods
        varargout = neighbourhood(varargin)
    end
    
    
    methods (Abstract)
        varargout = objfunc(varargin)
    end
    
    
    methods (Access=protected, Hidden)
        varargout = diffObj(varargin)
        varargout = run(varargin)
        varargout = parseEstimStruct(varargin)
    end
    
    
    methods (Access=protected, Hidden, Static)
        varargout = evalPrior(varargin)
    end
end
