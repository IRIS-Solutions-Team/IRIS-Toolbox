% Dictionary  
%
% Dictionary is a databank like object similar to the standard Matlab
% `struct`.
% 
% 
% Dictionary methods:
%
% ## Summary of Dictionary Functions by Category ##
%
% ### Constructor ###
% ------------------------------------------------------------------------------------------------------------
%   Dictionary                - 
%
%
% ### Creating New Copies of Existing Dictionary Objects ###
% ------------------------------------------------------------------------------------------------------------
%   copy                      - 
%
%
% ### Getting Information about Dictionary Objects ###
% ------------------------------------------------------------------------------------------------------------
%   keys                      - 
%   values                    - 
%   isKey                     - 
%
%
% ### Adding, Getting and Removing Dictionary Fields ###
% ------------------------------------------------------------------------------------------------------------
%   subsref                   - 
%   subsasgn                  - 
%   store                     - 
%   retrieve                  - 
%   remove                    - 
%
%
% #### Alternative Function Names ###
% ------------------------------------------------------------------------------------------------------------
%   setfield                  - 
%   getfield                  - 
%   fieldnames                - 
%   isfield                   - 
%   rmfield                   - 
%


% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team


classdef Dictionary < matlab.mixin.Copyable
    properties
        CaseSensitive = true
    end




    properties (SetAccess=protected)
        Keys = string.empty(1, 0)
        Values = cell.empty(1, 0)
    end




    properties (Dependent)
        Count
    end




    properties (Constant, Hidden)
        WARNING_KEY_NOT_FOUND =    { 'Dictionary:KeyNotFound'
                                     'This key does not exist in the Dictionary: %s ' }

        ERROR_INVALID_REFERENCE =  { 'Dictionary:InvalidSubscriptedReference'
                                     'Invalid subscripted reference to a Dictionary' }

        ERROR_INVALID_ASSIGNMENT = { 'Dictionary:InvalidSubscriptedAssignment'
                                     'Invalid subscripted assignment to a Dictionary' }
    end




    methods
        function this = Dictionary(varargin)
% Dictionary  Create new Dictionary object
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'Dictionary')
                this = varargin{1};
                return
            end
            this = store(this, varargin{:});
        end%




        function this = caseSensitive(this, newValue)
            this.CaseSensitive = newValue;
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
                    throw( exception.Base(this.ERROR_INVALID_REFERENCE, 'error') );
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
                    throw( exception.Base(this.ERROR_INVALID_ASSIGNMENT, 'error') );
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




        function flag = isKey(this, key)
            flag = lookupKey(this, key);
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
            if ~flag
                throw( exception.Base(this.WARNING_KEY_NOT_FOUND, 'error'), ...
                       key );
            end
            value = this.Values{pos};
        end%




        function this = remove(this, keys)
            if isa(keys, 'Except')
                keys.CaseSensitive = this.CaseSensitive;
                keys = resolve(keys, this.Keys);
            end
            pos = lookupKeys(this, keys);
            inxFound = ~isnan(pos);
            if any(~inxFound)
                keysNotFound = cellstr(keys(~inxFound));
                throw( exception.Base(this.WARNING_KEY_NOT_FOUND, 'error'), ...
                       keysNotFound{:} );
            end
            pos = pos(inxFound);
            this.Keys(pos) = [ ];
            this.Values(pos) = [ ];
        end%
    end        




    methods % Getters and Setters
        function value = get.Count(this)
            value = numel(this.Keys);
        end%
    end




    methods (Access=protected)
        function [flag, pos] = lookupKey(this, key)
            if isequal(this.CaseSensitive, true)
                inx = this.Keys==key;
            else
                inx = lower(this.Keys)==lower(key);
            end
            flag = any(inx);
            if flag
                pos = find(inx, 1);
            else
                pos = double.empty(1, 0);
            end
        end%




        function pos = lookupKeys(this, keys)
            numOfInquiries = numel(keys);
            if isequal(this.CaseSensitive, true)
                inx = this.Keys(:)==transpose(keys(:));
            else
                inx = lower(this.Keys(:))==lower(transpose(keys(:)));
            end
            pos = nan(size(keys));
            for i = find(any(inx, 1))
                pos(i) = find(inx(:, i), 1);
            end
        end%
    end
end

