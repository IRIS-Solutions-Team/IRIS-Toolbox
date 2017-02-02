classdef Base
    properties
        Identifier = ''
        ThrowAs = ''
        Message = ''
        NeedsHighlight = false
    end
    
    
    
    
    properties (Constant)
        IRIS_IDENTIFIER = 'IRIS:';
        HIGHLIGHT = '*** '
        BASE_ERROR_HEADER_FORMAT = 'IRIS Toolbox Error'
        BASE_WARNING_HEADER_FORMAT = 'IRIS Toolbox Warning'
        MAX_LEN = 30;
        CONTINUATION_CHAR_CODE = 8230;
        
        ALT2STR_FORMAT = '#%g';
        ALT2STR_FROM_TO_STRING = '-';
        ALT2STR_DEFAULT_LABEL = 'Parameter Variant(s) ';        
    end
    
    
    
    
    methods
        function this = Base(identifier, throwAs)
            if nargin==0
                return
            end
            this.ThrowAs = throwAs;
            [this.Identifier, this.Message] = ...
                exception.Base.lookupException(identifier);
            this.Identifier = [this.IRIS_IDENTIFIER, this.Identifier];
            this.NeedsHighlight = true;
        end
        
        
        
        
        function throw(this, varargin)
            header = createHeader(this);
            message = this.Message;
            if true % ##### MOSW
                message = strrep(message, '$ENGINE$', 'Matlab');
            else
                message = strrep(message, '$ENGINE$', 'Octave'); %#ok<UNRCH>
            end
            if this.NeedsHighlight
                message = [this.HIGHLIGHT, message];
            end
            if ~isempty(varargin)
                % Look for shared arguments %1, %2, ...
                for i = 1 : length(varargin)
                    c = ['%', sprintf('%g', i)];
                    pos = strfind(message, c);
                    if isempty(pos)
                        break
                    end
                    message = strrep(message, c, varargin{1});
                    varargin(1) = [ ];
                end
                message = sprintf([message, '\n'], varargin{:});
                message(end) = '';
            end
            if ~isempty(header)
                message = [header, sprintf('\n'), message];
            end
            if ~strcmpi(get(0, 'FormatSpacing'), 'Compact')
                message = [message, sprintf('\n')];
            end
            switch this.ThrowAs
                case 'error'
                    exception.Base.throwAsError(this.Identifier, message);
                case 'warning'
                    exception.Base.throwAsWarning(this.Identifier, message);
            end
        end
        
        
        
        
        function header = createHeader(this)
            switch this.ThrowAs
                case 'error'
                    header = this.BASE_ERROR_HEADER_FORMAT;
                case 'warning'
                    header = this.BASE_WARNING_HEADER_FORMAT;
            end
        end
        
        
        
        
        function throwCode(this, varargin)
            BR = sprintf('\n');
            varargin = strrep(varargin, BR, ' '); % Replace line breaks with spaces.
            varargin = regexprep(varargin, '[ ]{2,}', ' '); % Replace multiple spaces with one space.
            for i = 1 : length(varargin)
                if length(varargin{i})>this.MAX_LEN
                    varargin{i} = [ ...
                        varargin{i}(1:this.MAX_LEN), ...
                        char(this.CONTINUATION_CHAR_CODE), ...
                        ];
                end
            end
            varargin = strtrim(varargin);
            throw(this, varargin{:});
        end
    end
    
    
    
    
    methods (Static)
        function [stack, n] = reduceStack(adj)
            stack = dbstack('-completenames');
            [~, irisFolder] = fileparts( irisget('irisroot') );
            irisFolder = lower(irisFolder);
            testFolder = fullfile(irisFolder, '^iristest');
            n = length(stack);
            x = [ stack(:).file ];
            if ~isempty( strfind(x, '^iristest') ) ...
                    || isequal(getappdata(0, 'IRIS_REDUCE_DBSTACK'), false)
                return
            end
            while n > 0 && (...
                    isempty(strfind(lower(stack(n).file), irisFolder)) ...
                    || ~isempty(strfind(lower(stack(n).file), testFolder)) ...
                    )
                n = n - 1;
            end
            n = n + adj;
            stack = stack(n:end);
        end
        
        
        
        
        function throwAsError(identifier, message)
            stack = exception.Base.reduceStack(0);
            errorStruct = struct( ...
                'identifier', identifier, ...
                'message', message, ...
                'stack', stack ...
                );
            error(errorStruct);
        end
        
        
        
        
        function throwAsWarning(identifier, message)
            q = warning('query');
            warning('off', 'backtrace');
            warning(identifier, message);
            warning(q);
            w = warning('query', identifier);
            if strcmp(w.state, 'on')
                [~, n] = exception.Base.reduceStack(-1);
                dbstack(n);
            end
        end
        
        
        
        
        function s = alt2str(altVec, label)
            % Convert vector of alternative param numbers to string.
            try
                label; %#ok<VUNUS>
            catch
                label = exception.Base.ALT2STR_DEFAULT_LABEL;
            end

            if islogical(altVec)
                altVec = find(altVec);
            end
            altVec = altVec(:).';
            
            s = '';
            if isempty(altVec)
                return
            end
            
            n = length(altVec);
            c = cell(1,n);
            for i = 1 : n
                c{i} = sprintf([' ', exception.Base.ALT2STR_FORMAT ], altVec(i));
            end
            
            % Find continuous ranges; these will be replace with FROM-TO.
            ixDiff = diff(altVec)==1;
            ixDiff1 = [false, ixDiff];
            ixDiff2 = [ixDiff, false];
            inx = ixDiff1 & ixDiff2;
            c(inx) = {'-'};
            s = [c{:}];
            s = regexprep(s, '-+ ', exception.Base.ALT2STR_FROM_TO_STRING);
            
            % [P#1 #5-#10 #100].
            s = [ '[', label, strtrim(s), ']' ];
        end
        
        
        
        
        function [id, msg] = lookupException(id)
            persistent LOOKUP_TABLE;
            if ~isa(LOOKUP_TABLE, 'table')
                pathToHere = fileparts(mfilename('fullpath'));
                fileName = fullfile(pathToHere, 'LookupTable.csv');
                LOOKUP_TABLE = readtable( ...
                    fileName, ...
                    'Delimiter', ',', ...
                    'ReadVariableNames', true, ...
                    'ReadRowNames', true ...
                    );
            end
            id = exception.Base.underscore2capital(id);
            msg = LOOKUP_TABLE{id, :}{1};
        end
        
        
        
        
        function id = underscore2capital(id)        
            posLast = find(id==':', 1, 'last');
            c = id(posLast+1:end);
            if any(c=='_')
                % Change AAA_BBB to AaaBbb.
                c = ['_', lower(c)];
                pos = find(c=='_');
                c(pos+1) = upper(c(pos+1));
                c(pos) = '';
                id = [id(1:posLast), c];
            end
        end
    end
end
