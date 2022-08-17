classdef Base
    properties
        Identifier = ''
        ThrowAs (1, 1) string = ""
        Message = ''
        NeedsHighlight = false
    end


    properties (Constant)
        IRIS_IDENTIFIER = "IrisToolbox";
        HIGHLIGHT = '*** '
        BASE_ERROR_HEADER_FORMAT = '[IrisToolbox] Error'
        BASE_WARNING_HEADER_FORMAT = '[IrisToolbox] Warning'
        MAX_LEN = 40
        ELLIPSIS = char(8230)

        ALT2STR_FORMAT = '#%g';
        ALT2STR_FROM_TO_STRING = '-';
        ALT2STR_DEFAULT_LABEL = 'Variant:';
    end


    methods
        function this = Base(specs, throwAs)
            if nargin==0
                return
            end
            if nargin==1
                throwAs = "error";
            end
            if strcmpi(throwAs, "silent")
                return
            end
            this.ThrowAs = throwAs;
            if iscellstr(specs)
                this.Identifier = specs{1};
                this.Message = [specs{2:end}];
                this.NeedsHighlight = true;
            elseif isstring(specs)
                this.Identifier = char(specs(1));
                lenHighlight = strlength(this.HIGHLIGHT);
                specs = specs(2:end);
                specs(1) = string(this.HIGHLIGHT) + specs(1);
                specs(2:end) = strcat(string(repmat(' ', 1, strlength(this.HIGHLIGHT))), specs(2:end));
                this.Message = char(join(specs, newline()));
                this.NeedsHighlight = false;
            else
                [this.Identifier, this.Message] = exception.Base.lookupException(specs);
                this.NeedsHighlight = true;
            end
            this.Identifier = join([this.IRIS_IDENTIFIER, string(this.Identifier)], ":");
        end%


        function assert(condition, this, varargin)
            if ~condition
                raise(this, varargin{:});
            end
        end%


        function throw(this, varargin)
            raise(this, varargin{:});
        end%


        function raise(this, varargin)
            EMPTY_HIGHLIGHT = this.HIGHLIGHT;
            EMPTY_HIGHLIGHT(:) = ' ';
            header = createHeader(this);
            message = this.Message;
            needsHighlight = this.NeedsHighlight;
            message = strrep(message, '$ENGINE$', 'Matlab');
            if needsHighlight
                message = [this.HIGHLIGHT, message];
            end
            message = strrep(message, '\H', sprintf('\n%s', EMPTY_HIGHLIGHT));
            message = strrep(message, '\h', EMPTY_HIGHLIGHT);
            if ~isempty(varargin)
                % Look for shared arguments %1, %2, ...
                for i = 1 : numel(varargin)
                    c = ['%', sprintf('%g', i)];
                    pos = strfind(message, c);
                    if isempty(pos)
                        break
                    end
                    message = strrep(message, c, char(varargin{1}));
                    varargin(1) = [ ];
                end
                message = sprintf([message, '\n'], varargin{:});
                message = char(message);
                message(end) = '';
            end
            if ~isempty(header)
                message = [header, sprintf('\n'), message];
            end
            if ~strcmpi(get(0, 'FormatSpacing'), 'Compact')
                message = [message, sprintf('\n')];
            end
            if this.ThrowAs=="error"
                exception.Base.throwAsError(this.Identifier, message);
            elseif this.ThrowAs=="warning"
                exception.Base.throwAsWarning(this.Identifier, message);
            end
        end%




        function header = createHeader(this)
            if this.ThrowAs=="error"
                header = this.BASE_ERROR_HEADER_FORMAT;
            elseif this.ThrowAs=="warning"
                header = this.BASE_WARNING_HEADER_FORMAT;
            else
                header = '';
            end
        end%




        function throwCode(this, varargin)
            BR = sprintf('\n');
            varargin = strrep(varargin, BR, ' '); % Replace line breaks with spaces.
            varargin = regexprep(varargin, '[ ]{2, }', ' '); % Replace multiple spaces with one space.
            for i = 1 : numel(varargin)
                if numel(varargin{i})>this.MAX_LEN
                    varargin{i} = [varargin{i}(1:this.MAX_LEN), char(this.ELLIPSIS)];
                end
            end
            varargin = strtrim(varargin);
            raise(this, varargin{:});
        end%


        function this = set.ThrowAs(this, value)
            this.ThrowAs = lower(string(value));
        end%
    end




    methods (Static)
        function stack = getStack()
            try
                error("IrisToolbox:Exception", "Stack Reduction");
            catch exc
                stack = exc.stack;
            end
            stack = stack(2:end);
        end%


        function stack = reduceStack(adj)
            stack = exception.Base.getStack();
            [~, irisFolder] = fileparts(iris.get('irisRoot'));
            irisFolder = lower(irisFolder);
            inxIris = cellfun(@(x) ~isempty(strfind(lower(x), irisFolder)), {stack.file});
            lastIris = find(inxIris, 1, 'last');
            lastIris = lastIris+adj;
            lenStack = numel(stack);
            if lastIris<=lenStack
                stack = stack(lastIris:end);
            else
                stack = stack([ ]);
            end
        end%


        function throwAsError(identifier, message)
            stack = exception.Base.reduceStack(0);
            errorStruct = struct( ...
                'identifier', identifier, ...
                'message', message, ...
                'stack', stack ...
            );
            error(errorStruct);
        end%


        function throwAsWarning(identifier, message)
            q = warning('query');
            warning('off', 'backtrace');
            warning(identifier, message);
            warning(q);
            w = warning('query', identifier);
            if strcmp(w.state, 'on')
                stack = exception.Base.reduceStack(1);
                for i = 1 : numel(stack)
                    if i==1
                        fprintf('> ');
                    else
                        fprintf('  ');
                    end
                    ithFile = stack(i).file;
                    fprintf('In %s', ithFile);
                    [~, ithTitle] = fileparts(ithFile);
                    ithName = stack(i).name;
                    if ~strcmp(ithTitle, ithName) && ~isempty(ithName)
                        fprintf('>%s', ithName);
                    end
                    fprintf(' (line %g)\n', stack(i).line);
                end
                fprintf('\n');
            end
        end%




        function s = alt2str(altVec, label, numberFormat)
            % alt2str  Convert vector of alternative param numbers to string
            try
                label; %#ok<VUNUS>
            catch
                label = exception.Base.ALT2STR_DEFAULT_LABEL;
            end

            try
                numberFormat;
            catch
                numberFormat = exception.Base.ALT2STR_FORMAT;
            end

            if islogical(altVec)
                altVec = find(altVec);
            end
            altVec = altVec(:).';

            s = '';
            if isempty(altVec)
                return
            end

            n = numel(altVec);
            c = cell(1, n);
            for i = 1 : n
                c{i} = sprintf([' ',  numberFormat], altVec(i));
            end

            % Find continuous ranges; these will be replace with FROM-TO
            ixDiff = diff(altVec)==1;
            ixDiff1 = [false, ixDiff];
            ixDiff2 = [ixDiff, false];
            inx = ixDiff1 & ixDiff2;
            c(inx) = {'-'};
            s = [c{:}];
            s = regexprep(s, '-+ ', exception.Base.ALT2STR_FROM_TO_STRING);

            % [P#1 #5-#10 #100].
            s = [ '[', label, strtrim(s), ']' ];
        end%




        function [id, msg] = lookupException(id)
            exceptionLookupTable = getappdata(0, 'IRIS_ExceptionLookupTable');
            if ~isa(exceptionLookupTable, 'table')
                exceptionLookupTable = exception.Base.resetLookupTable();
            end
            id = exception.Base.underscore2capital(id);
            inx  = strcmpi(exceptionLookupTable(:, 1), id);
            if nnz(inx)~=1
                inx = 1;
            end
            msg = exceptionLookupTable{inx, 2};
        end%




        function exceptionLookupTable = resetLookupTable()
            pathToHere = fileparts(mfilename('fullpath'));
            fileName = fullfile(pathToHere, 'LookupTable.csv');
            exceptionLookupTable = exception.readLookupTable();
            setappdata(0, 'IRIS_ExceptionLookupTable', exceptionLookupTable);
        end%




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
        end%
    end
end
