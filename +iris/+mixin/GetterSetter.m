% GetterSetter  Helper class implementing getters and setters
%
% Backend [IrisToolbox] class
% No help provided

% -[IrisToolbox] for Macroeconomic Modelingk
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

classdef GetterSetter
    properties (Hidden)
        Build = '' % [IrisToolbox] release in which object was constructed
    end
    
    
    methods
        function this = GetterSetter(varargin)
            persistent release
            if isempty(release)
                release = iris.get('Release');
            end
            this.Build = release;
        end%
    end
    
    
    methods
        function varargout = get(this, varargin)
            varargout = cell(size(varargin));
            numArgs = numel(varargin);
            inxValid = true(1, numArgs);
            inputQuery = varargin;
            for i = 1 : numArgs
                func = [ ];
                if ischar(inputQuery{i}) || isstring(inputQuery{i})
                    queryArgs = cell(1, 0);
                else
                    queryArgs = inputQuery{i}(2:end);
                    inputQuery{i} = inputQuery{i}{1};
                end
                query = strip(lower(inputQuery{i}));
                
                query = erase(query, "=");
                query = erase(query, "!");
                query = erase(query, " ");
                
                % Capture function calls inside queries
                tkn = regexp(query, '^(\w+)\((\w+)\)$', 'once', 'tokens');
                if ~isempty(tkn) && ~isempty(tkn{1})
                    func = tkn{1};
                    query = tkn{2};
                end
                
                % Call class implementation
                [varargout{i}, inxValid(i)] = implementGet(this, query, queryArgs{:});
                
                if ~isempty(func)
                    varargout{i} = feval(func, varargout{i});
                end
            end
            
            % Report invalid queries
            if any(~inxValid)
                throw( exception.Base('GetterSetter:INVALID_GET_QUERY', 'error'), ...
                    class(this), inputQuery{~inxValid} ); %#ok<GTARG>
            end
        end%
        
        
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
        end%
    end
    

    methods (Hidden)
        function flag = checkConsistency(this)
            flag = ischar(this.Build);
        end%
        

        function this = struct2obj(this, s)
            % struct2obj  Copy structure fields to object properties
            propList = iris.mixin.GetterSetter.getPropList(this);
            structList = iris.mixin.GetterSetter.getPropList(s);
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
        end%
    end
    
    
    methods (Hidden)
        function ccn = getClickableClassName(this)
            ccn = class(this);
        end%


        function this = setp(this, prop, value)
            this.(prop) = value;
        end%
        
        
        function value = getp(this, prop)
            value = this.(prop);
        end%
    end
    
    
    methods (Static, Hidden)
        function query = myalias(query)
        end%
        
        
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
        end%
    end
end

