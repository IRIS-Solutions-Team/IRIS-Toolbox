% genericobj  Generic report object
%
% Backend IRIS class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team
    
classdef genericobj < handle
    properties
        parent = [ ];
        children = { };
        childof = { };
        caption = '';
        options = struct( );
        default = { };
        
        hInfo = [ ]; % Store a handle object to carry global information.
    end
    
    properties (Dependent)
        title
        subtitle
    end
    
    methods
        
        
        function This = genericobj(varargin)
            This.default = [This.default,{ ...
                'captiontypeface',{'\large\bfseries',''}, ...
                @(x) ischar(x) || ...
                (iscell(x) && length(x)==2 ...
                && (ischar(x{1}) || isequal(x{1},Inf)) ...
                && (ischar(x{2}) || isequal(x{2},Inf))), ...
                true, ...
                'footnote','',@ischar,false, ...
                'inputformat','plain', ...
                @(x) any(strcmpi(x,{'plain','latex'})),true,...
                'saveas','',@ischar,false, ...
                }];
            if ~isempty(varargin)
                This.caption = varargin{1};
            end
        end % genericobj( )
        
        
        function [This,varargin] = specargin(This,varargin)
        end % specargin( )
        
        
        function This = setoptions(This,ParentOpt,varargin)
            % setoptions( ) is called from within add( ).
            try
                % Convert argins to struct.
                userName = varargin(1:2:end);
                userValue = varargin(2:2:end);
                % Make option names lower-case and remove equal signs.
                userName = lower(userName);
                userName = strrep(userName,'=','');
            catch Error
                utils.error('report:genericobj:genericobj',...
                    ['Invalid structure of optional input arguments.\n', ...
                    'MATLAB says: %s'],...
                    Error.message);
            end
            % First, pool parent's and user-supplied options; some of them may not
            % apply to this object, but can be inherited by children.
            This.options = ParentOpt;
            for i = 1 : length(userName)
                This.options.(userName{i}) = userValue{i};
            end
            Default = This.default;
            % Process the object-specific options.
            for i = 1 : 4 : length(Default)
                match = regexp(Default{i},'\w+','match');
                primaryName = match{1};
                defValue = Default{i+1};
                validFunc = Default{i+2};
                isInheritable = Default{i+3};
                % First, assign default under the primary name.
                This.options.(primaryName) = defValue;
                % Cycle over alternative option names.
                for j = length(match) : -1 : 1
                    optName = match{j};
                    % Then, inherit the value from the parent object if it is inheritable and
                    % is available from parent options.
                    if isInheritable && isfield(ParentOpt,optName)
                        This.options.(primaryName) = ParentOpt.(optName);
                    end
                    % Last, get it from current user options if supplied.
                    invalid = { };
                    ix = strcmpi(optName,userName);
                    if any(ix)
                        pos = find(ix);
                        ok = feval(validFunc,userValue{pos});
                        if ok
                            This.options.(primaryName) = userValue{pos};
                        else
                            invalid{end+1} = optName; %#ok<AGROW>
                            invalid{end+1} = func2str(validFunc); %#ok<AGROW>
                        end
                        % Report values that do not pass validation.
                        if ~isempty(invalid)
                            utils.error('report:genericobj:genericobj',...
                                ['Value assigned to option %s= ', ...
                                'fails validation %s.'],...
                                invalid{:});
                        end
                    end
                end
            end
        end % setoptions( )
        
        
        varargout = copy(varargin)
        varargout = disp(varargin)
        varargout = display(varargin)
        varargout = findall(varargin)
        
    end
    
    methods (Access=protected)
        varargout = interpret(varargin)
        varargout = latexcode(varargin)
        varargout = root(varargin)
        varargout = speclatexcode(varargin)
        varargout = shortclass(varargin)
        varargout = printcaption(varargin)
    end
    
    methods
        
        
        function Title = get.title(This)
            % This.caption can be one of the following:
            % * 'title'
            % * @auto
            % * {'title','subtitle'}
            % * {@auto,'subtitle'}
            Title = This.caption;
            if ischar(Title)
                return
            end
            % {Title,Subtitle}
            if iscell(Title)
                try
                    Title = Title{1};
                catch
                    Title = '';
                    return
                end
            end
            % @auto or {@auto,Subtitle}
            if isequal(Title,@auto)
                try
                    if isa(This.data{1}, 'Series')
                        x = comment(This.data{1});
                        Title = x{1};
                    end
                catch
                    try
                        ch = This.children{1};
                        if isa(ch.data{1}, 'Series')
                            x = comment(ch.data{1});
                            Title = x{1};
                        end
                    catch
                        Title = '';
                        return
                    end
                end
            end
            % Return empty string if everything else fails.
            if ~ischar(Title)
                Title = '';
            end
        end % get.title( )
        
        
        function Sub = get.subtitle(This)
            Sub = '';
            if iscell(This.caption) ...
                    && length(This.caption) > 1 ...
                    && ischar(This.caption{2})
                Sub = This.caption{2};
            end
        end % get.subtitle( )
        
        
    end
    
    methods (Access=protected,Hidden)
        
        
        function C = mytitletypeface(This)
            if iscell(This.options.captiontypeface)
                C = This.options.captiontypeface{1};
            else
                C = This.options.captiontypeface;
            end
            if isinf(C)
                C = '\large\bfseries';
            end
        end % mytitletypeface( )
        
        
        function C = mysubtitletypeface(This)
            if iscell(This.options.captiontypeface)
                C = This.options.captiontypeface{2};
            else
                C = '';
            end
            if isinf(C)
                C = '';
            end
        end % mysubtitletypeface( )
        
        
        % When adding a new object, we find the right place by checking two things:
        % first, we match the child's childof list, and second, we ask the parent
        % if it accepts new childs. The latter test is true for all parents except
        % align objects with no more room.
        function Flag = accepts(This) %#ok<MANU>
            Flag = true;
        end % accepts( )
                
        
        % User-supplied typeface
        %------------------------
        function c = begintypeface(this)
            c = '';
            if isfield(this.options,'typeface') ...
                    && ~isempty(this.options.typeface)
                br = sprintf('\n');
                c = [c, '{', br, this.options.typeface, br];
            end
        end
        
        
        
        
        function c = endtypeface(this)
            c = '';
            if isfield(this.options,'typeface') ...
                    && ~isempty(this.options.typeface)
                br = sprintf('\n');
                c = [c, '}', br];
            end
        end
        
        
        
        
        % hInfo methods
        %---------------
        function addtempfile(this, newTempFile)
            if ischar(newTempFile)
                newTempFile = {newTempFile};
            end
            tempFile = this.hInfo.tempFile;
            tempFile = [tempFile, newTempFile];
            this.hInfo.tempFile = tempFile;
        end 
        
        
        
        
        function addfigurehandle(this, newFigureHandle)
            figureHandle = this.hInfo.figureHandle;
            figureHandle = [figureHandle, newFigureHandle];
            this.hInfo.figureHandle = figureHandle;
        end

        
        
        
        function c = footnotemark(this, text)
            try
                text; %#ok<VUNUS>
            catch
                try
                    text = this.options.footnote;
                catch
                    text = '';
                end
            end
            if isempty(text)
                c = '';
                return
            end
            br = sprintf('\n');
            number = sprintf('%g', footnotenumber(this));
            text = interpret(this, text);
            c = ['\footnotemark[', number, ']'];
            this.hInfo.footnote{end+1} = [ ...
                br, '\footnotetext[', number, ']{', text, '}', ...
                ];
        end
        
        
        
        
        function c = footnotetext(this)
            footnote = this.hInfo.footnote;
            if isempty(footnote)
                c = '';
                return
            end
            c = [ footnote{:} ];
            footnote = { };
            this.hInfo.footnote = footnote;
        end 
        
        
        
        
        function n = footnotenumber(this)
            n = this.hInfo.footnoteCount;
            n = n + 1;
            this.hInfo.footnoteCount = n;
        end
    end
    
    
    methods (Static, Hidden)
        function c = makebox(text, format, colW, pos, color)
            c = ['{', text, '}'];
            if ~isempty(format)
                c = ['{', format, c, '}'];
            end
            if ~isnan(colW)
                c = ['\makebox[', sprintf('%g', colW),'em]', ...
                    '[', pos, ']{', c, '}'];
            end
            if ~isempty(color)
                c = ['\colorbox{', color, '}{', c, '}'];
            end
        end
        
        
        
        
        function c = sprintf(value, format, opt)
            if ~isempty(opt.purezero) && value==0
                c = opt.purezero;
                return
            end
            if isnan(value)
                c = opt.nan;
                return
            end
            if isinf(value)
                c = opt.inf;
                return
            end
            d = sprintf(format,value);
            if ~isempty(opt.printedzero) && isequal(sscanf(d, '%g'), 0)
                d = opt.printedzero;
            end
            c = ['\ensuremath{', d, '}'];
        end
        
        
        
        
        function c = turnbox(c, angle)
            try
                if islogical(angle)
                    angle = '90';
                else
                    angle = sprintf('%g', angle);
                end
            catch %#ok<CTCH>
                angle = '90';
            end
            c = ['\settowidth{\tableColNameHeight}{', c, ' }',...
                '\rule{0pt}{\tableColNameHeight}',...
                '\turnbox{', angle, '}{', c, '}'];
        end
        
        
        
        
        function isValid = validatecolstruct(colStruct)
            isnumericscalar = @(x) isnumeric(x) && isscalar(x);
            isValid = true;
            for i = 1 : length(colStruct)
                c = colStruct(i);
                if ~(ischar(c.name) ...
                        || ( ...
                        iscell(c.name) && length(c.name)==2 ...
                        && (ischar(c.name{1}) || isequaln(c.name{1},NaN)) ...
                        && (ischar(c.name{2}) || isequaln(c.name{2},NaN)) ...
                        ))
                    isValid = false;
                end
                if ~isempty(c.func) ...
                        && isa(c,'function_handle')
                    isValid = false;
                end
                if ~isempty(c.date) ...
                        && ~isnumericscalar(c.date)
                    isValid = false;
                end
            end
        end
    end
end
