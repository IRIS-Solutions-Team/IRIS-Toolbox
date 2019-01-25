% GetterSetter  Helper class to implement some shared properties of IRIS objects
%
% Backend IRIS class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

classdef GetterSetter
    properties (Hidden)
        Build = '' % IRIS version in which object was constructed
    end
    
    
    methods
        function this = GetterSetter(varargin)
            persistent VERSION
            if isempty(VERSION)
                VERSION = iris.version( );
            end
            this.Build = VERSION;
        end
    end
    
    
    methods
        function varargout = get(this, varargin)
            varargout = cell(size(varargin));
            nArg = numel(varargin);
            ixValid = true(1, nArg);
            usrQuery = varargin;
            for i = 1 : nArg
                func = [ ];
                if ischar(usrQuery{i})
                    queryArg = cell(1, 0);
                else
                    queryArg = usrQuery{i}(2:end);
                    usrQuery{i} = usrQuery{i}{1};
                end
                query = usrQuery{i};
                query = strtrim(lower(query));
                
                % Remove equal signs.
                query = strrep(query, '=', '');
                
                % Capture function calls inside queries.
                tkn = regexp(query, '^(\w+)\((\w+)\)$', 'once', 'tokens');
                if ~isempty(tkn) && ~isempty(tkn{1})
                    func = tkn{1};
                    query = tkn{2};
                end
                
                % Remove blank spaces.
                query(isstrprop(query, 'wspace')) = '';
                
                % Call class implementation.
                [varargout{i}, ixValid(i)] = implementGet(this, query, queryArg{:});
                
                if ~isempty(func)
                    varargout{i} = feval(func, varargout{i});
                end
            end
            
            % Report invalid queries.
            if any(~ixValid)
                throw( exception.Base('GetterSetter:INVALID_GET_QUERY', 'error'), ...
                    class(this), usrQuery{~ixValid} ); %#ok<GTARG>
            end
        end
        
        
        function this = set(this, varargin)
            usrRequest = varargin(1:2:end);
            value = varargin(2:2:end);
            nRequest = numel(usrRequest);
            ixValidRequest = true(1, nRequest);
            ixValidValue = true(1, nRequest);
            for i = 1 : nRequest
                if ischar(usrRequest{i})
                    requestArg = cell(1, 0);
                else
                    requestArg = usrRequest{i}(2:end);
                    usrRequest{i} = usrRequest{i}{1};
                end
                request = usrRequest{i};
                request = strtrim(lower(request));
                request = strrep(request, '=', '');
                
                % Replace alternate names with the standard ones.
                request = this.myalias(request);
                
                % Remove blank spaces.
                request(isstrprop(request, 'wspace')) = '';
                
                % Call class implementation.
                [this, ixValidRequest(i), ixValidValue(i)] = ...
                    implementSet(this, request, value{i}, requestArg{:});
            end
            
            % Report invalid requests.
            if any(~ixValidRequest)
                throw( exception.Base('GetterSetter:INVALID_SET_REQUEST', 'error'), ...
                    class(this), usrRequest{~ixValidRequest} ); %#ok<GTARG>
            end
            
            % Report invalid requests.
            if any(~ixValidValue)
                throw( exception.Base('GetterSetter:INVALID_SET_VALUE', 'error'), ...
                    class(this), usrRequest{~ixValidValue} ); %#ok<GTARG>
            end            
        end        
    end
    

    methods (Hidden)
        function flag = chkConsistency(this)
            flag = ischar(this.Build);
        end
        
        
        function this = struct2obj(this, s)
            % struct2obj  Copy structure fields to object properties
            propList = shared.GetterSetter.getPropList(this);
            structList = shared.GetterSetter.getPropList(s);
            for i = 1 : length(propList)
                ix = strcmp(structList, propList{i});
                if ~any(ix)
                    ix = strcmpi(structList, propList{i});
                    if ~any(ix)
                        continue
                    end
                end
                pos = find(ix, 1, 'last');
                this = setp(this, propList{i}, s.(structList{pos}));
            end
        end
        
        
        function disp(this, varargin) %#ok<INUSD>
        end
    end
    
    
    methods (Access=protected, Hidden)
        function ccn = getClickableClassName(this)
            cn = class(this);
            if iris.get('DesktopStatus')
                ccn = sprintf('<a href="matlab: idoc %s">%s</a>', cn, cn);
            else
                ccn = cn; %#ok<UNRCH>
            end
        end
    end
    
    
    methods (Hidden)
        function this = setp(this, prop, value)
            this.(prop) = value;
        end
        
        
        function value = getp(this, prop)
            value = this.(prop);
        end
    end
    
    
    methods (Static, Hidden)
        function query = myalias(query)
        end
        
        
        function list = getPropList(obj)
            % getNPropList  List of all non-dependent non-constant properties of an object.
            if isstruct(obj)
                list = fieldnames(obj);
                return
            end
            if ischar(obj)
                mc = meta.class.fromName(obj);
            else
                mc = metaclass(obj);
            end
            ixDependent = [ mc.PropertyList.Dependent ];
            ixConstant = [ mc.PropertyList.Constant ];
            ixKeep = ~ixDependent & ~ixConstant;
            list = { mc.PropertyList(ixKeep).Name };
        end
    end
end
