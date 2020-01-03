% irisinp.parser  Call appropriate irisinp.func and parse user inputs.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

classdef parser < handle
    properties (Constant)
        Container = irisinp.parser.populate( );
    end
    
    
    methods (Static)
        varargout = populate(varargin)
        
        
        
        
        function varargout = parse(ref, varargin)
            split = regexp(ref, '\.', 'split');
            category = split{1};
            funcName = split{2};
            funcObj = irisinp.parser.Container.(category).(funcName);
            [varargout{1:nargout}] = parse(funcObj, varargin{:});
        end
    end
end
