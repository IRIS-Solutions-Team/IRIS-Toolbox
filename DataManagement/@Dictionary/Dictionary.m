classdef Dictionary < matlab.mixin.Copyable
    properties (SetAccess=protected)
        Keys = string.empty(1, 0)
        Values = cell.empty(1, 0)
    end




    properties (Dependent)
        Count
    end




    methods
        function this = Dictionary(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'Dictionary')
                this = varargin{1};
                return
            end
            this = store(this, varargin{:});
        end%




        function value = subsref(this, s)
            if strcmp(s(1).type, '.')
                key = string(s(1).subs);
            else
                if numel(s(1).subs)~=1
                    hereThrowError( );
                end
                key = string(s(1).subs{1});
            end
            if numel(key)~=1
                hereThrowError( );
            end
            value = retrieve(this, key);
            s = s(2:end);
            if ~isempty(s)
                value = subsref(value, s);
            end
            return
                function hereThrowError( )
                    THIS_ERROR = { 'Dictionary:InvalidSubscriptedReference'
                                   'Invalid subscripted reference to a Dictionary' };
                    throw( exception.Base(THIS_ERROR, 'error') );
                end%
        end%




        function this = subsasgn(this, s, value)
            if strcmp(s(1).type, '.')
                key = string(s(1).subs);
            else
                if numel(s(1).subs)~=1
                    hereThrowError( );
                end
                key = string(s(1).subs{1});
            end
            s = s(2:end);
            if ~isempty(s)
                value = subsasgn(retrieve(this, key), s, value);
            end
            this = store(this, key, value);
            return
                function hereThrowError( )
                    THIS_ERROR = { 'Dictionary:InvalidSubscriptedAssignment'
                                   'Invalid subscripted assignment to a Dictionary' };
                    throw( exception.Base(THIS_ERROR, 'error') );
                end%
        end%




        function flag = isfield(this, key)
            flag = lookupKey(this, key);
        end%




        function list = fieldnames(this)
            list = this.Keys(:);
            list = cellstr(list);
        end%




        function this = rmfield(this, keys)
            this = remove(this, keys);
        end%




        function value = getfield(this, key)
            value = retrieve(this, key);
        end%




        function this = setfield(this, key, value)
            this = store(this, key, value);
        end%




        function value = numel(this, varargin)
            value = 1;
        end%




        function list = keys(this)
            list = this.Keys;
        end%




        function list = keysAsChar(this)
            list = cellstr(this.Keys);
        end%




        function output = values(this)
            output = this.Values;
        end%




        function this = store(this, varargin)
            for i = 1 : 2 : numel(varargin)
                key = string(varargin{i});
                value = varargin{i+1};
                [flag, pos] = lookupKey(this, key);
                if flag
                    this.Values{pos} = value;
                else
                    this.Keys(1, end+1) = key;
                    this.Values(1, end+1) = { value };
                end
            end
        end%




        function value = retrieve(this, key)
            [flag, pos] =  lookupKey(this, key);
            if flag
                value = this.Values{pos};
            else
                THIS_ERROR = { 'Dictionary:KeyNotFound'
                               'This key does not exist in the Dictionary: %s ' };
                throw( exception.Base(THIS_ERROR, 'error'), ...
                       key );
            end
        end%




        function this = remove(this, keys)
            pos = lookupKeys(this, keys);
            inxFound = ~isnan(pos);
            pos = pos(inxFound);
            this.Keys(pos) = [ ];
            this.Values(pos) = [ ];
            if any(~inxFound)
                keysNotFound = cellstr(keys(~inxFound));
                THIS_WARNING = { 'Dictionary:KeyNotFound'
                                 'This key does not exist in the Dictionary: %s ' };
                throw( exception.Base(THIS_WARNING, 'warning'), ...
                       keysNotFound{:} );
            end
        end%
    end        




    methods % Getters and Setters
        function value = get.Count(this)
            value = numel(this.Keys);
        end%
    end




    methods (Access=protected)
        function [flag, pos] = lookupKey(this, key)
            inx = this.Keys==key;
            flag = any(inx);
            if flag
                pos = find(inx, 1);
            else
                pos = double.empty(1, 0);
            end
        end%




        function pos = lookupKeys(this, keys)
            numOfInquiries = numel(keys);
            inx = this.Keys(:)==transpose(keys(:));
            pos = nan(size(keys));
            for i = find(any(inx, 1))
                pos(i) = find(inx(:, i), 1);
            end
        end%
    end
end

