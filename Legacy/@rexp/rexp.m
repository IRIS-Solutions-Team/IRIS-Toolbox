% rexp  Wrapper for Regular Expressions (rexp Objects)
%
% Backend IRIS class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team


classdef rexp
    properties
        String = ''
    end
    
    
    methods
        function this = rexp(varargin)
            if isempty(varargin)
                return
            end
            if length(varargin)==1 && isa(varargin{1}, 'rexp')
                this = varargin{1};
                return
            end
            if ischar(varargin{1}) || isa(varargin{1}, 'string')
                this.String = char(varargin{1});
            end
        end%
    end
    
    
    methods
        function varargout = char(this)
            varargout{1} = this.String;
        end%


        function varargout = cellstr(this)
            varargout{1} = cellstr(this.String);
        end%
        
        
        function varargout = string(this)
            varargout{1} = string(this.String);
        end%


        function varargout = isempty(this, varargin)
            [varargout{1:nargout}] = isempty(this.String, varargin{:});
        end%
        
        
        function varargout = length(this, varargin)
            [varargout{1:nargout}] = strlength(this.String, varargin{:});
        end%
        
        
        function varargout = strlength(this, varargin)
            [varargout{1:nargout}] = strlength(this.String, varargin{:});
        end%
        
        
        function varargout = size(this, varargin)
            [varargout{1:nargout}] = size(this.String, varargin{:});
        end%
        
        
        function varargout = strcmp(varargin)
            [varargout{1:nargout}] = apply(@strcmp, varargin{:});
        end%
        
        
        function varargout = strcmpi(varargin)
            [varargout{1:nargout}] = apply(@strcmpi, varargin{:});
        end%
        
        
        function varargout = strncmp(varargin)
            [varargout{1:nargout}] = apply(@strncmp, varargin{:});
        end% 
        
        function varargout = strncmpi(varargin)
            [varargout{1:nargout}] = apply(@strncmpi, varargin{:});
        end%
        
        
        function this = strrep(this, varargin)
            this.String = strrep(this.String, varargin{:});
        end%
        
        
        function this = strtrim(this, varargin)
            this.String = strtrim(this.String, varargin{:});
        end%
        
        
        function varargout = regexp(varargin)
            [varargout{1:nargout}] = apply(@regexp, varargin{:});
        end%
        
        
        function varargout = regexprep(varargin)
            [varargout{1:nargout}] = apply(@regexprep, varargin{:});
        end%
        
        
        function varargout = regexprepi(varargin)
            [varargout{1:nargout}] = apply(@regexprepi, varargin{:});
        end%
        
        
        function varargout = regexptranslate(varargin)
            [varargout{1:nargout}] = apply(@regexptranslate, varargin{:});
            varargout{1} = rexp(varargout{1});
        end%
        
                
        function varargout = sprintf(varargin)
            [varargout{1:nargout}] = apply(@sprintf, varargin{:});
        end%
        
        
        function varargout = apply(Fn, varargin)
            ix = cellfun(@(x) isa(x, 'rexp'), varargin);
            for i = find(ix)
                varargin{i} = varargin{i}.String;
            end 
            [varargout{1:nargout}] = Fn(varargin{:});
        end%
    end
    
    
    methods
        function K = end(this, varargin)
            K = length(this.String);
        end%
        
        
        function flag = eq(varargin)
            ix = cellfun(@(x) isa(x, 'rexp'), varargin);
            for i = find(ix)
                varargin{i} = varargin{i}.String;
            end 
            flag = eq(varargin{:});
        end%
        
        
        function this = subsref(this, varargin)
            this.String = subsref(this.String, varargin{:});
        end%
        
        
        function this = subsasgn(this, varargin)
            this.String = subsasgn(this.String, varargin{:});
        end%

        
        function s = minus(s, this)
            if iscellstr(s) && isa(this, 'rexp')
                start = regexp(s, this.String, 'once');
                ixKeep = cellfun(@isempty, start);
                s = s(ixKeep);
            elseif isstruct(s) && isa(this, 'rexp')
                list = dbnames(s, 'NameFilter', this);
                s = dbminus(s, list);
            end
        end%


        function d = mtimes(d, this)
            if isstruct(d)
                list = dbnames(d, 'NameFilter', this);
                d = dbmtimes(d, list);
            end
        end%
    end
end
