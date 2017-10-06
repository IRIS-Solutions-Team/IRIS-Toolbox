classdef Preparser < handle
    properties
        FileName = char.empty(1, 0)  % Input file name.
        UserComment = char.empty(1, 0)  % User comment line read from code.
        Code = char.empty(1, 0)  % Code being preparsed.
        White = char.empty(1, 0)  % Code with all labels whited out.
        Assigned = struct.empty( ) % Database with control parameters.
        CloneTemplate = char.empty(1, 0)  % Template to clone model names.
        Export = shared.Export.empty(1, 0) % Files to be saved into working folder.
        CtrlParameters = cell(1, 0) % List of parameter names occuring in control expressions and interpolations.
        EvalWarning = parser.Preparser.EVAL_WARNING % List of if/elseif/switch/case conditions/expressions producing errors.
        
        StoreForCtrl = cell.empty(0, 2) % Store !for control variable replacements.
    end
    
    
    
    
    properties (Constant)
        EVAL_DBASE_PREFIX = 'varargin{2}.';
        EVAL_TEMP_PREFIX = '?.';
        CLONE_PATTERN = '(?<!!)\<([A-Za-z]\w*)\>(?!\()';
        
        EVAL_WARNING = struct( ...
            'If',{{ }}, ...
            'Switch',{{ }}, ...
            'Case',{{ }} ...
        )
        
        CODE_SEPARATOR = sprintf('\n\n');
        FILE_NAME_SEPARATOR = ' & ';
        OBSOLETE_SYNTAX = {
            '\$\[', '<'
            '\]\$', '>'
        };
    end
    
    
    methods
        function this = Preparser(fileName, inpCode, assigned, cloneTemplate)
            import parser.Preparser;
            if nargin==0
                return
            end
            if ~isempty(fileName)
                fileName = cellstr(fileName);
                for iThis = 1 : numel(fileName)
                    % Because Preparser is a handle class we need to create separate instances for
                    % each file name inside the for loop.
                    this(iThis) = parser.Preparser( ); %#ok<AGROW>
                    this(iThis).FileName = fileName{iThis}; %#ok<AGROW>
                    readCodeFromFile( this(iThis) );
                    this(iThis).Assigned = assigned; %#ok<AGROW>
                    this(iThis).CloneTemplate = cloneTemplate; %#ok<AGROW>
                end
            else
                % Input code from input string(s) (char or cellstr).
                inpCode = cellstr(inpCode);
                for iThis = 1 : numel(inpCode)
                    % Because Preparser is a handle class we need to create separate instances for
                    % each file name inside the for loop.
                    this(iThis) = parser.Preparser( ); %#ok<AGROW>
                    this(iThis).Code = inpCode{iThis}; %#ok<AGROW>
                    this(iThis).Assigned = assigned; %#ok<AGROW>
                    this(iThis).CloneTemplate = cloneTemplate; %#ok<AGROW>
                end
            end
            nThis = length(this);
            for iThis = 1 : nThis
                p = this(iThis);
                % Store parsed file name.
                exception.ParseTime.storeFileName(p.FileName);
                if isempty(p.Code)
                    continue
                end
                
                % Handle obsolete syntax.
                obsoleteSyntax(p);
                % Preparse individual components.
                parser.UserComment.parse(p);
                parser.Comment.parse(p);
                parser.control.Control.parse(p);
                % Resolve interpolations *after* controls so that interpolated expressions
                % can refer to !for control variables. Interpolations between !for and
                % !do keywords are resolved separately within For.writeFinal( ) in the
                % previous step.
                parser.Interp.parse(p);
                parser.substitution.Substitution.parse(p);
                parser.pseudofunc.Pseudofunc.parse(p);
                parser.doubledot.DoubleDot.parse(p);
                % Check leading and trailing empty lines.
                fixEmptyLines(p);
                % Clone preparsed code.
                if ~isempty(cloneTemplate)
                    p.Code = cloneAllNames(p.Code, p.CloneTemplate);
                end
                throwEvalWarning(p);
            end     
            % Reset parsed file name.
            exception.ParseTime.storeFileName( );            
        end
        
        
        function readCodeFromFile(this)
            import parser.Preparser;
            fileName = this.FileName;
            fid = fopen(fileName,'r');
            if fid==-1
                if ~utils.exist(fileName,'file')
                    throw( exception.ParseTime('Preparser:CANNOT_FIND_FILE', 'error'), ...
                        fileName ); %#ok<GTARG>
                else
                    throw( exception.ParseTime('Preparser:CANNOT_READ_FILE', 'error'), ...
                        fileName ); %#ok<GTARG>
                end
            end
            c = char(fread(fid,'char').');
            if fclose(fid)==-1
                throw( exception.ParseTime('Preparser:CANNOT_CLOSE_FILE', 'warning'), ...
                    fileName ); %#ok<GTARG>
            end
            c = Preparser.convertEols(c);
            c = Preparser.addLineBreak(c);
            this.Code = c;
        end
        
        
        function fixEmptyLines(this)
            c = this.Code;
            % Remove leading and trailing empty lines.
            c = regexprep(c, '^\s*\n', '');
            c = regexprep(c, '\n\s*$', '');
            % Add line break at the end of the preparsed code.
            c = parser.Preparser.addLineBreak(c);
            this.Code = c;            
        end
        
        
        function f = getFileName(this)
            import parser.Preparser;            
            f = '';
            nThis = length(this);
            for iThis = 1 : nThis
                f = [ f, this(iThis).FileName ]; %#ok<AGROW>
                if iThis<nThis
                    f = [ f, Preparser.FILE_NAME_SEPARATOR ]; %#ok<AGROW>
                end
            end 
        end
        
        
        function c = createFinalCut(this)
            import parser.Preparser;
            c = '';
            nThis = length(this);
            for iThis = 1 : nThis
                c = [ c, this(iThis).Code ]; %#ok<AGROW>
                if iThis<nThis
                    c = [ c, Preparser.CODE_SEPARATOR ]; %#ok<AGROW>
                end
            end
        end
        
        
        function c = applyFinalCutCommands(this, c) %#ok<INUSL>
            c = parser.List.parse(c);
        end
        
        
        
        function d = createCtrlDatabase(this)
            ctrlParameters = [ this(:).CtrlParameters ];
            assigned = this(1).Assigned;
            d = struct( );
            for i = 1 : length(ctrlParameters)
                name = ctrlParameters{i};
                try %#ok<TRYNC>
                    % Only create the field if it exists in input database.
                    d.(name) = assigned.(name);
                end
            end
        end
        
        
        function throwEvalWarning(this)
            if ~isempty(this.EvalWarning.If)
                throwCode( ...
                    exception.ParseTime('Preparser:CTRL_EVAL_IF_FAILED', 'warning'), ...
                    this.EvalWarning.If{:} ...
                    );
            end
            if ~isempty(this.EvalWarning.Switch)
                throwCode( ...
                    exception.ParseTime('Preparser:CTRL_EVAL_SWITCH_FAILED', 'warning'), ...
                    this.EvalWarning.Switch{:} ...
                    );
            end
            if ~isempty(this.EvalWarning.Case)
                throwCode( ...
                    exception.ParseTime('Preparser:CTRL_EVAL_CASE_FAILED', 'warning'), ...
                    this.EvalWarning.Case{:} ...
                    );
            end
        end
        
        
        function add(this, ctrlDatabase, export)
            addCtrlParameter(this, ctrlDatabase);
            this.Export = [this.Export, export];
        end
        
        
        function addCtrlParameter(this, add)
            if ischar(add)
                add = { add };
            end
            this.CtrlParameters = [ this.CtrlParameters, add ];
        end
        
        
        function addEvalWarning(type, this, message)
            if isa(message,'parser.Preparser')
                add = message.EvalWarning;
                this.EvalWarning = [this.EvalWarning, add];
                return
            end
            this.EvalWarning.(type){end+1} = message;
        end


        function obsoleteSyntax(this)
            n = size(parser.Preparser.OBSOLETE_SYNTAX, 1);
            for i = 1 : n
                old = parser.Preparser.OBSOLETE_SYNTAX{i, 1};
                new = parser.Preparser.OBSOLETE_SYNTAX{i, 2};
                this.Code = regexprep(this.Code, old, new); 
            end
        end
    end
    
    
    methods (Static)
        function [finalCut, fileName, export, ctrlParameters, userComment] ...
                = parse(fileName, inpCode, assigned, saveAs, cloneStr)
            import parser.Preparser;
            
            try, assigned; catch, assigned = struct( ); end %#ok<NOCOM,VUNUS>
            try, saveAs; catch, saveAs = ''; end %#ok<NOCOM,VUNUS>
            try, cloneStr; catch, cloneStr = ''; end %#ok<NOCOM,VUNUS>
            
            this = parser.Preparser(fileName, inpCode, assigned, cloneStr);
            % Combine file names.
            fileName = getFileName(this); 
            % Compose final code.
            finalCut = createFinalCut(this);
            % Apply preparsing commands to the final cut.
            finalCut = applyFinalCutCommands(this, finalCut);
            % Return list of control parameters.
            ctrlParameters = unique( [ this(:).CtrlParameters ] );
            % Merge all exported files.
            export = [ this(:).Export ];
            % First-line comment from the first file.
            userComment = this(1).UserComment;
            % Save preparsed code to disk file if requested.
            if ~isempty(saveAs)
                Preparser.saveAs(finalCut, saveAs);
            end
        end    
        
        
        function c = convertEols(c)
            % convertEols - Convert any style EOLs to Unix style.
            % Windows:
            c = strrep(c, sprintf('\r\n'), sprintf('\n'));
            % Mac:
            c = strrep(c, sprintf('\r'), sprintf('\n'));            
        end
        
        
        function c = addLineBreak(c)
            BR = sprintf('\n');
            if isempty(c) || c(end)~=BR
                c = [c,BR];
            end        
        end
        
        
        function varargout = eval(varargin)
            if isempty(regexp(varargin{1}, '[A-Za-z_\?]', 'once'))
                varargout{1} = eval(varargin{1});
            else
                parser.Preparser.evalPopulateWorkspace(varargin{:});
                varargout{1} = eval(varargin{1});
            end
        end
        
        
        function evalPopulateWorkspace(expn, assigned, p)
            import parser.White;
            shadowExpn = White.whiteOutLabel(expn);
            shadowExpn = strrep(shadowExpn, '!', '');
            lsAssigned = fieldnames(assigned);
            lsAssigned = lsAssigned(:).';
            lsExpn = regexp( ...
                shadowExpn, ...
                '(?<!\.)\<[a-zA-Z]\w*\>(?![\(\.])', ...
                'match');
            ixControl = false(size(lsAssigned));
            for i = 1 : length(lsExpn)
                name = lsExpn{i};
                ix = strcmp(name, lsAssigned);
                if any(ix)
                    assignin('caller', name, assigned.(name));
                    ixControl = ixControl | ix;
                end
            end
            if nargin>2 && any(ixControl)
                addCtrlParameter(p, lsAssigned(ixControl));
            end
        end
        
        
        function flag = chkCloneString(c)
            flag = ~isempty( strfind(c, '?') ) && ...
                isvarname( strrep(c, '?', 'x') );
        end
        
        
        function code = cloneAllNames(code, cloneStr)
            import parser.Preparser;
            if ~Preparser.chkCloneString(cloneStr)
                throw( ...
                    exception.ParseTime('Preparser:CLONE_STRING_INVALID', 'error'), ...
                    cloneStr); %#ok<GTARG>
            end
            cloneStr = strrep(cloneStr, '?', '$1');
            code = regexprep( ...
                code, ...
                Preparser.CLONE_PATTERN, ...
                cloneStr ...
                );
        end

        
        function saveAs(codeToSave, fileName)
            if ~isempty(fileName)
                try
                    char2file(codeToSave, fileName);
                catch
                    throw( ...
                        exception.ParseTime('Preparser:CANNOT_SAVE', 'error'), ...
                        fileName ); %#ok<GTARG>
                end
            end
        end
        
        
        function code = removeInsignificantWhs(code)
            code = strtrim(code);
            code = regexprep(code,'\s+',' ');
        end
    end
end
