classdef userinputobj < report.genericobj
    % userinputobj  [Not a public class] Base class for report elements built on user input.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2022 IRIS Solutions Team.
    
    properties
        userinput = '';
    end
    
    methods
        
        function This = userinputobj(varargin)
            islogicalscalar = @(x) islogical(x) && isscalar(x);
            This = This@report.genericobj(varargin{:});
            This.childof = {'report'};
            This.default = [This.default,{ ...
                'centering',false,islogicalscalar,true, ...
                'verbatim',false,islogicalscalar,true, ...                                
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
        end
        
    end
    
    methods (Access=protected,Hidden)
        
        varargout = speclatexcode(varargin)
        
    end
    
end
