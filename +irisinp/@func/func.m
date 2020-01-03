% irisinp.func  Define and store input arguments for a function.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

classdef func < handle
    properties
        Inp = cell(1, 0);
        InpClassName = cell(1, 0);
    end
    
    
    
    
    methods
        varargout = parse(varargin)
        
        
        
        
        function this = func(varargin)
            if isempty(varargin)
                return
            end
            if nargin==1 && isa(varargin{1}, 'irisinp.func')
                this = varargin{1};
                return
            end
            for i = 1 : nargin
                inp = varargin{i};
                this.Inp{i} = inp;
                className = regexp(class(inp), '\.', 'split');
                this.InpClassName{i} = className{2};
            end
        end
    end
end
