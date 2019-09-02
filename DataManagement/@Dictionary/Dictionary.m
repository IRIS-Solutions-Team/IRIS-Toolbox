% Dictionary  
%{
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
%   list                      - 
%   values                    - 
%   isKey                     - 
%   isempty                   - 
%
%
% ### Manipulating Dictionary entries ###
% ------------------------------------------------------------------------------------------------------------
%   subsref                   - 
%   subsasgn                  - 
%   store                     - 
%   rename                    - 
%   retrieve                  - 
%   remove                    - 
%   updateSeries              - 
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
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team


classdef Dictionary < matlab.mixin.Copyable
    properties (SetAccess=protected)
        Keys (1, :) string = string.empty(1, 0)
        Values (1, :) cell = cell.empty(1, 0)
        CaseSensitive (1, 1) logical = true
        EnforceKey = [ ]
    end




    properties (Dependent)
        Count
    end




    properties (Constant, Hidden)
        EXCEPTION_KEY_NOT_FOUND =    { 'Dictionary:KeyNotFound'
                                       'This key does not exist in the Dictionary: %s ' }

        EXCEPTION_INVALID_REFERENCE =  { 'Dictionary:InvalidSubscriptedReference'
                                         'Invalid subscripted reference to a Dictionary' }

        EXCEPTION_INVALID_ASSIGNMENT = { 'Dictionary:InvalidSubscriptedAssignment'
                                         'Invalid subscripted assignment to a Dictionary' }

        EXCEPTION_CANNOT_RENAME =      { 'Dictionary:CannotRename'
                                         'Cannot rename because this key already exists in the Dictionary: %s' };

        EXCEPTION_CANNOT_MAKE_CASE_INSENSITIVE = { 'Dictionary:CannotMakeCaseInsensitive'
                                                   'Cannot make the Dictionary case insensitive because some keys would become indistiguishable' };

        EXCEPTION_EMPTY_KEY =          { 'Dictionary:EmptyKey'
                                         'Empty keys are not allowed in a Dictionary' };

        EXCEPTION_TOO_MANY_OUTPUT_ARGS =  { 'Dictionary:EmptyKey'
                                            'Too many output arguments' };

        EXCEPTION_UPDATE_SERIES = { 'Dictionary:UpdateMustBeTimeSubscriptable'
                                    'Method udpateSeries only works on entries of TimeSubscriptable class' }

    end




    methods
        varargout = list(varargin)
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
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Dictionary.Dictionary');
                addParameter(parser, 'CaseSensitive', true, @validate.logicalScalar);
                addParameter(parser, 'EnforceKey', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
            end
            parse(parser, varargin{:});
            this.CaseSensitive = parser.Results.CaseSensitive;
            this.EnforceKey = parser.Results.EnforceKey;
        end%




        function flag = isempty(this)
% isempty  True if a Dictionary stores no entries
            if numel(this)==1
                flag = isempty(this.Keys);
            else
                flag = arrayfun(@(x) isempty(x.Keys), this);
            end
        end%




        function varargout = subsref(this, s)
% subsref  Subscripted reference to Dictionary
            if strcmp(s(1).type, '.')
                key = string(s(1).subs);
            elseif strcmp(s(1).type, '{}')
                try
                    key = string(s(1).subs);
                catch
                    hereThrowError( );
                end
            else
                error('...')

                index = s(1).subs{1};
                if ~isnumeric(index) || any(index~=round(index)) || any(index<=0) ...
                   || numel(s(1).subs)>1
                    hereThrowError( );
                end
                varargout{1} = this(index);
                s = s(2:end);
                if ~isempty(s)
                    varargout{1} = subsref(varargout{1}, s);
                end
                return
            end
            numKeys = numel(key);
            numOutputs = max(1, nargout);
            if numKeys<numOutputs
                throw( exception.Base(this.EXCEPTION_TOO_MANY_OUTPUT_ARGS, 'error') );
            end
            s = s(2:end);
            for i = 1 : numOutputs
                value = retrieve(this, key(i));
                if ~isempty(s)
                    value = subsref(value, s);
                end
                varargout{i} = value;
            end
            return
                function hereThrowError( );
                    throw( exception.Base(this.EXCEPTION_INVALID_REFERENCE, 'error') );
                end%
        end%




        function this = subsasgn(this, s, value)
% subsasgn  Subscripted assignment to Dictionary
            if strcmp(s(1).type, '.')
                key = string(s(1).subs);
            elseif strcmp(s(1).type, '{}') && numel(s(1).subs)==1 && numel(s(1).subs{1})==1
                key = string(s(1).subs{1});
            elseif strcmp(s(1).type, '()')
                error('...')

                index = s(1).subs{1};
                if ~isnumeric(index) || any(index~=round(index)) || any(index<=0) ...
                   || numel(s(1).subs)>1
                    hereThrowError( );
                end
                s = s(2:end);
                if isempty(s)
                    this(index) = value;
                else
                    this(index) = subsasgn(this(index), s, value);
                end
                return
            else
                hereThrowError( );
            end
            s = s(2:end);
            if ~isempty(s)
                value = subsasgn(retrieve(this, key), s, value);
            end
            this = store(this, key, value);
            return
                function hereThrowError( )
                    throw( exception.Base(this.EXCEPTION_INVALID_ASSIGNMENT, 'error') );
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
            value = prod(size(this));
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
% store  Store new entries in Dictionary
            for i = 1 : 2 : numel(varargin)
                key = string(varargin{i});
                value = varargin{i+1};
                [flag, pos, key] = lookupKey(this, key);
                if flag
                    this.Values{pos} = value;
                else
                    this.Keys(1, end+1) = key;
                    this.Values(1, end+1) = { value };
                end
            end
        end%




        function [this, x] = updateSeries(this, key, range, data)
% updateSeries  Update time series in Dictionary
            x = retrieve(this, key);
            if ~isa(x, 'TimeSubscriptable')
                throw( exception.Base(this.EXCEPTION_UPDATE_SERIES, 'error') );
            end
            x = setData(x, range, data);
            store(this, key, x);
        end%




        function value = retrieve(this, key)
% retrieve  Retrieve value with specified key from Dictionary
            [flag, pos] =  lookupKey(this, key);
            if ~flag
                throw( exception.Base(this.EXCEPTION_KEY_NOT_FOUND, 'error'), ...
                       key );
            end
            value = this.Values{pos};
        end%




        function this = rename(this, oldKey, newKey)
% rename  Rename keys in Dictionary
            [flag, posOldKey, oldKey] = lookupKey(this, oldKey);
            if ~flag
                throw( exception.Base(this.EXCEPTION_KEY_NOT_FOUND, 'error'), ...
                       oldKey );
            end
            [flag, ~, newKey] = lookupKey(this, newKey);
            if flag
                throw( exception.Base(this.EXCEPTION_CANNOT_RENAME, 'error'), ...
                       newKey );
            end
            if isempty(newKey)
                throw( exception.Base(this.EXCEPTION_EMPTY_KEY, 'error') );
            end
            this.Keys(posOldKey) = newKey;
        end%




        function this = remove(this, keys)
% remove  Remove entries from Dictionary
            if isa(keys, 'Except')
                keys.CaseSensitive = this.CaseSensitive;
                keys = resolve(keys, this.Keys);
            end
            pos = lookupKeys(this, keys);
            inxFound = ~isnan(pos);
            if any(~inxFound)
                keysNotFound = cellstr(keys(~inxFound));
                throw( exception.Base(this.EXCEPTION_KEY_NOT_FOUND, 'error'), ...
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
        function [flag, pos, key] = lookupKey(this, key)
            key = preprocessKeyString(this, key);
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
            keys = preprocessKeyString(this, keys);
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




        function key = preprocessKeyString(this, key)
            key = strtrim(key);
            if ~isempty(this.EnforceKey)
                key = this.EnforceKey(key);
            end
        end%
    end
end

