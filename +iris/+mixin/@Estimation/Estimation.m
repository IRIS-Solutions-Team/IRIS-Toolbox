% Estimation  Estimation mixin class
%
% Backend [IrisToolbox] class
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

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
