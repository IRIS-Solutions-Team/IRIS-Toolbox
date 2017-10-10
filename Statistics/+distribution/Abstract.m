% distribution.Abstract

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef (Abstract) Abstract < handle
    properties (SetAccess=protected)
        Name = ''
        Location
        Shape
        Scale
        Mean
        Std
        Var
        Mode
        Median
    end


    methods
        function this = Abstract(parameterization, varargin)
            persistent INPUT_PARSER
            if nargin==0
                return
            end
            if isempty(INPUT_PARSER)
                INPUT_PARSER = extend.InputParser('distribution/Abstract');
                INPUT_PARSER.addRequired('ParameterizationType', @(x) ischar(x) || isa(x, 'string'));
                INPUT_PARSER.addRequired('Parameters', @(x) all(cellfun(@isnumeric, x)));
            end
            INPUT_PARSER.parse(parameterization, varargin);
        end
    end


    methods (Abstract)
        varargout = inDomain(varargin)
        varargout = logPdf(varargin)
        varargout = pdf(varargin)
        varargout = info(varargin)
    end
end
