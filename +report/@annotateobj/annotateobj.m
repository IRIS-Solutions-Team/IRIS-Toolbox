classdef annotateobj < report.genericobj
    % annotateobj  [Not a public class] Superclass for highlight and vline objects.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2022 IRIS Solutions Team.
    
    properties
        location = [ ];
        background = NaN;
    end
    
    methods
        function This = annotateobj(varargin)
            isnumericscalar = @(x) isnumeric(x) && isscalar(x);
            This = This@report.genericobj(varargin{:});
            This.childof = {'graph'};
            This.default = [This.default, { ...
                'vposition','top', ...
                @(x) (isnumericscalar(x) && x >= 0 &&  x <= 1) ...
                || (validate.anyString(x,"top","bottom","centre","center","middle")),true,...
                'hposition','right', ...
                @(x) validate.anyString(x,"left","right","centre","center","middle"),true,...
                'timeposition','middle', ...
                @(x) validate.anyString(x,"middle","after","before"),true, ...
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
            if ~isempty(varargin)
                This.location = varargin{1};
                varargin(1) = [ ];
            end
        end
        
    end
    
end
