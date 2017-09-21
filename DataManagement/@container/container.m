classdef container
    
    methods        
        function x = list(this) %#ok<MANU>
            x = container.request('list');
        end
        
        function lock(this, varargin) %#ok<INUSL>
            container.request('lock', varargin{:});
        end
        
        function unlock(this, varargin) %#ok<INUSL>
            container.request('unlock', varargin{:});
        end
        
        function Flag = islocked(this, varargin) %#ok<INUSL>
            Flag = container.request('islocked', varargin{:});
        end
        
        function List = locked(this) %#ok<MANU>
            List = container.request('locked');
        end
        
        function List = unlocked(this) %#ok<MANU>
            List = container.request('unlocked');
        end
        
        function this = remove(this,varargin)
            container.request('remove', varargin{:});
        end
        
        function this = clear(this)
            container.request('clear');
            munlock('container.request');
        end
        
        function X = saveobj(this) %#ok<MANU>
            X = container.request('save');
        end
        
        function varargout = get(this, varargin)
            if ~isempty(varargin)
                [varargout{1}, flag] = container.request('get', varargin{1});
                if ~flag
                    container.error(2, varargin{1});
                end
                [varargout{2:length(varargin)}] = get(this, varargin{2:end});
            end
        end
        
        function this = put(this,varargin)
            if ~isempty(varargin)
                pp = inputParser( );
                pp.addRequired('c', @(x) isa(x,'container'));
                pp.addRequired('name', @ischar);
                pp.parse(this,varargin{1});
                if ~isempty(varargin)
                    flag = container.request('set', varargin{1}, varargin{2});
                    if ~flag
                        container.error(1, varargin{1});
                    end
                    this = put(this, varargin{3:end});
                end
            end
        end
        
        function disp(this) %#ok<MANU>
            list = container.request('list');
            status = get(0, 'formatSpacing');
            fprintf('\tcontainer object: 1-by-1\n');
            set(0, 'formatSpacing', 'compact');
            disp(list);
            set(0, 'formatSpacing', status);
        end
    end
    
    methods (Static)
        
        function this = loadobj(this)
            container.request('load', this);
            this = container( );
        end
        
    end
    
    methods (Static,Access=private)
        
        varargout = request(varargin)
        
        function error(code, list, varargin)
            switch code
                case 1
                    msg = ['Cannot re-write container entry %s ', ...
                        'this entry is locked.'];
                case 2
                    msg = 'Reference to non-existent container entry: %s ';
            end
            if nargin==1
                list = { };
            elseif ~iscell(list)
                list = { list };
            end
            utils.error('container', msg, list{:});
        end
    end
    
end