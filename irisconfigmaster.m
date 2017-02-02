function varargout = irisconfigmaster(varargin)
% irisconfigmaster  IRIS Toolbox master configuration file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent CONFIG LS_CONFIG

if isempty(varargin) || isempty(CONFIG)
    CONFIG = irisconfig( );
    LS_CONFIG = fieldnames(CONFIG);
    mlock( );
end

try
    req = varargin{1};
    varargin(1) = [ ];
catch
    return
end

%--------------------------------------------------------------------------

lsInvalid = { };
lsProtected = { };
lsNotFound = { };

switch req
    case 'get'
        if nargin==1
            varargout{1} = CONFIG;
        else
            lsNotFound = { };
            n = length(varargin);
            varargout = cell(1, n);
            for i = 1 : n
                ix = strcmpi(varargin{i}, LS_CONFIG);
                if any(ix)
                    name = LS_CONFIG{ix};
                    varargout{i} = CONFIG.(name);
                else
                    lsNotFound{end+1} = varargin{i}; %#ok<AGROW>
                    varargout{i} = NaN;
                end
            end
        end
        
    case 'set'
        for i = 1 : 2 : nargin-1
            ix = strcmpi(varargin{i}, LS_CONFIG);
            if ~any(ix)
                lsNotFound{end+1} = varargin{i}; %#ok<AGROW>
                continue
            end
            name = lower(varargin{i});
            if any(strcmp(name, CONFIG.protected))
                lsProtected{end+1} = varargin{i}; %#ok<AGROW>
                continue
            end
            value = varargin{i+1};
            if isfield(CONFIG.validate, name) ...
                    && ~CONFIG.validate.(name)(value)
                lsInvalid{end+1} = name; %#ok<AGROW>
            else
                CONFIG.(name) = value;
            end
        end
        
    case 'reset'
        munlock( );
        CONFIG = irisconfig( );
        LS_CONFIG = fieldnames(CONFIG);
        mlock( );
end

if ~isempty(lsNotFound)
    throw( exception.Base('Config:InvalidOptionName', 'warning'), ...
        lsNotFound{:} );
end
if ~isempty(lsInvalid)
    throw( exception.Base('Config:InvalidOptionValue', 'warning'), ...
        lsInvalid{:} );
end
if ~isempty(lsProtected)
    throw( exception.Base('Config:ProtectedOption', 'warning'), ...
        lsProtected{:} );
end

end
