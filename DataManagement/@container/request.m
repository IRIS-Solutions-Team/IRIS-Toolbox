function varargout = request(action,varargin)
% request  [Not a public function] Persistent repository for container class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

mlock( );
persistent X;

if isempty(X)
    % @@@@ MOSW
    X = struct( );
    X.name = cell(1,0);
    X.data = cell(1,0);
    X.lock = false(1,0);
end

%--------------------------------------------------------------------------

switch action
    case 'get'
        ix = strcmp(X.name,varargin{1});
        if any(ix)
            varargout{1} = X.data{ix};
            varargout{2} = true;
        else
            varargout{1} = [ ];
            varargout{2} = false;
        end
        
    case 'set'
        ix = strcmp(X.name,varargin{1});
        if any(ix)
            if X.lock(ix)
                varargout{1} = false;
            else
                X.data{ix} = varargin{2};
                varargout{1} = true;
            end
        else
            X.name{end+1} = varargin{1};
            X.data{end+1} = varargin{2};
            X.lock(end+1) = false;
            varargout{1} = true;
        end
        
    case 'list'
        varargout{1} = X.name;
        
    case {'lock','unlock'}
        tmp = strcmp(action,'lock');
        if isempty(varargin)
            X.lock(:) = tmp;
        else
            pos = doFindNames(X,varargin);
            X.lock(pos) = tmp;
        end
    case 'islocked'
        pos = doFindNames(X,varargin);
        varargout{1} = X.lock(pos);
        
    case 'locked'
        varargout{1} = X.name(X.lock);
        
    case 'unlocked'
        varargout{1} = X.name(~X.lock);
        
    case 'clear'
        % @@@@@ MOSW
        X = struct( );
        X.name = cell(1,0);
        X.data = cell(1,0);
        X.lock = false(1,0);
        
    case 'save'
        if nargin > 1
            pos = doFindNames(X,varargin);
            x = struct( );
            x.name = X.name(pos);
            x.data = X.data(pos);
            x.lock = X.lock(pos);
            varargout{1} = x;
        else
            varargout{1} = X;
        end
        
    case 'load';
        pos = textfun.findnames(X.name,varargin{1}.name,'[^\s,;]+');
        new = isnan(pos);
        nnew = sum(new);
        X.name(end+(1:nnew)) = varargin{1}.name(new);
        X.data(end+(1:nnew)) = varargin{1}.data(new);
        X.lock(end+(1:nnew)) = varargin{1}.lock(new);
        pos = pos(~new);
        if any(X.lock(pos))
            pos = pos(X.lock(pos));
            container.error(1,X.name(pos));
        end
        X.data(pos) = varargin{1}.data(~new);
        
    case 'remove'
        if ~isempty(varargin)
            pos = doFindNames(X,varargin);
            X.name(pos) = [ ];
            X.data(pos) = [ ];
            X.lock(pos) = [ ];
        end
    case 'count'
        varargout{1} = numel(X.name);
        
    case '?name'
        varargout{1} = X.name;
        
    case '?data'
        varargout{1} = X.data;
        
    case '?lock'
        varargout{1} = X.lock;
end


% Nested functions...


%**************************************************************************


    function Pos = doFindNames(X,Select)
        Pos = textfun.findnames(X.name,Select,'[^\s,;]+');
        if any(isnan(Pos))
            container.error(2,Select(isnan(Pos)));
        end
    end % doFindNames( )
end
