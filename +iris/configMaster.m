function varargout = configMaster(varargin)
% iris.configMaster  IRIS Toolbox master configuration file
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent CONFIG 

if nargin==0 || isempty(CONFIG)
    munlock
    CONFIG = iris.Configuration( );
    mlock
end

if nargin==0
    return
end

try
    req = varargin{1};
    varargin(1) = [ ];
catch
    return
end

%--------------------------------------------------------------------------

switch req
    case 'get'
        if nargin==1
            varargout{1} = CONFIG;
        else
            n = length(varargin);
            varargout = cell(1, n);
            for i = 1 : n
                name = varargin{i};
                varargout{i} = CONFIG.(name);
            end
        end
        
    case 'set'
        for i = 1 : 2 : nargin-1
            name = varargin{i};
            value = varargin{i+1};
            CONFIG.(name) = value;
        end
        
    case 'reset'
        munlock
        CONFIG = iris.Configuration( );
        mlock
end

end
