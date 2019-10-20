classdef Preparser < model.File
    properties
        UserComment = char.empty(1, 0)  % User comment line read from code
        White = char.empty(1, 0)  % Code with all labels whited out
        Assigned = struct.empty( ) % Database with control parameters
        CloneTemplate = char.empty(1, 0)  % Template to clone model names
        Export = shared.Export.empty(1, 0) % Files to be saved into working folder
        CtrlParameters = cell(1, 0) % List of parameter names occuring in control expressions and interpolations
        EvalWarning = parser.Preparser.EVAL_WARNING % List of if/elseif/switch/case conditions/expressions producing errors
        
        StoreForCtrl = cell.empty(0, 2) % Store !for control variable replacements
        StoreSubstitutions = struct( ) % Store substitution names and bodies
    end
    
    
    
    
    properties (Constant)
        EVAL_DBASE_PREFIX = 'varargin{2}.'
        EVAL_TEMP_PREFIX = '?.'
        
        EVAL_WARNING = struct( 'If',{{ }}, ...
                               'Switch',{{ }}, ...
                               'Case',{{ }} )
        
        CODE_SEPARATOR = sprintf('\n\n');
        FILE_NAME_SEPARATOR = ' & ';
        OBSOLETE_SYNTAX = { '\$\[', '<'
                            '\]\$', '>' }
    end
    
    
    methods
        function this = Preparser(modelFile, inpCode, assigned, cloneTemplate)
            import parser.Preparser
            if nargin==0
                return
            end
            if ~isempty(modelFile)
                if ~isa(modelFile, 'model.File')
                    fileName = strtrim(cellstr(modelFile));
                    %
                    % Remove model file names starting with a hat ^
                    %
                    inxToRemove = cellfun(@(x) strncmp(x, '^', 1), fileName);
                    fileName(inxToRemove) = [ ];

                    %
                    % Throw an error if there is no model file name to read
                    %
                    numModelFiles = numel(fileName);
                    if numModelFiles==0
                        thisError = { 'Preparser:NoModelFileEntered'
                                      'No model file specified' };
                        throw( exception.ParseTime(thisError, 'error') );
                    end

                    %
                    % Create an array of model.File objects
                    %
                    modelFile = model.File.empty(1, 0);
                    for i = 1 : numModelFiles
                        modelFile = [modelFile, model.File(fileName{i})];
                    end
                end
                for i = 1 : numel(modelFile)
                    % Because Preparser is a handle class we need to create separate instances for
                    % each file name inside the loop
                    this(i) = parser.Preparser( ); %#ok<AGROW>
                    this(i).FileName = modelFile(i).FileName;
                    this(i).Code = modelFile(i).Code;
                end
            else
                % Input code from input string(s) (char or cellstr)
                inpCode = cellstr(inpCode);
                for i = 1 : numel(inpCode)
                    % Because Preparser is a handle class we need to create separate instances for
                    % each file name inside the for loop
                    this(i) = parser.Preparser( ); %#ok<AGROW>
                    this(i).Code = inpCode{i}; %#ok<AGROW>
                end
            end

            for i = 1 : numel(this)
                this(i).Assigned = assigned; %#ok<AGROW>
                this(i).CloneTemplate = cloneTemplate; %#ok<AGROW>
            end

            for i = 1 : numel(this)
                p = this(i);
                % Store parsed file name
                exception.ParseTime.storeFileName(p.FileName);
                if isempty(p.Code)
                    continue
                end
                
                % Handle obsolete syntax
                obsoleteSyntax(p);
                % Preparse individual components
                parser.UserComment.parse(p);
                parser.Comment.parse(p);
                parser.control.Control.parse(p);
                % Resolve interpolations *after* controls so that interpolated expressions
                % can refer to !for control variables. Interpolations between !for and
                % !do keywords are resolved separately within For.writeFinal( ) in the
                % previous step.
                parser.Interp.parse(p);
                parser.Substitution.parse(p);
                parser.Pseudofunc.parse(p);
                parser.DoubleDot.parse(p);
                % Check leading and trailing empty lines
                fixEmptyLines(p);
                % Clone preparsed code
                if ~isempty(cloneTemplate)
                    p.Code = model.File.cloneAllNames(p.Code, p.CloneTemplate);
                end
                throwEvalWarning(p);
            end     
            % Reset parsed file name
            exception.ParseTime.storeFileName( );            
        end%
        
        
        function fixEmptyLines(this)
            c = this.Code;
            % Remove leading and trailing empty lines
            c = regexprep(c, '^\s*\n', '');
            c = regexprep(c, '\n\s*$', '');
            % Add line break at the end if there is none
            c = model.File.addLineBreak(c);
            this.Code = c;            
        end%
        
        
        function f = getFileName(this)
            import parser.Preparser
            f = '';
            nThis = length(this);
            for iThis = 1 : nThis
                f = [ f, this(iThis).FileName ]; %#ok<AGROW>
                if iThis<nThis
                    f = [ f, Preparser.FILE_NAME_SEPARATOR ]; %#ok<AGROW>
                end
            end 
        end%
        
        
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
        end%
        
        
        function c = applyFinalCutCommands(this, c) %#ok<INUSL>
            c = parser.List.parse(c);
        end%
        
        
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
        end%
        
        
        function throwEvalWarning(this)
            if ~isempty(this.EvalWarning.If)
                throwCode( exception.ParseTime('Preparser:CTRL_EVAL_IF_FAILED', 'warning'), ...
                           this.EvalWarning.If{:} );
            end
            if ~isempty(this.EvalWarning.Switch)
                throwCode( exception.ParseTime('Preparser:CTRL_EVAL_SWITCH_FAILED', 'warning'), ...
                           this.EvalWarning.Switch{:} );
            end
            if ~isempty(this.EvalWarning.Case)
                throwCode( exception.ParseTime('Preparser:CTRL_EVAL_CASE_FAILED', 'warning'), ...
                           this.EvalWarning.Case{:} );
            end
        end%
        
        
        function add(this, ctrlDatabase, export)
            addCtrlParameter(this, ctrlDatabase);
            this.Export = [this.Export, export];
        end%
        
        
        function addCtrlParameter(this, add)
            if ischar(add)
                add = { add };
            end
            this.CtrlParameters = [ this.CtrlParameters, add ];
        end%
        
        
        function addEvalWarning(type, this, message)
            if isa(message,'parser.Preparser')
                add = message.EvalWarning;
                this.EvalWarning = [this.EvalWarning, add];
                return
            end
            this.EvalWarning.(type){end+1} = message;
        end%


        function obsoleteSyntax(this)
            n = size(parser.Preparser.OBSOLETE_SYNTAX, 1);
            for i = 1 : n
                old = parser.Preparser.OBSOLETE_SYNTAX{i, 1};
                new = parser.Preparser.OBSOLETE_SYNTAX{i, 2};
                this.Code = regexprep(this.Code, old, new); 
            end
        end%


        function substitutions = mergeSubstitutions(this)
            substitutions = struct( );
            for i = 1 : numel(this)
                list = fieldnames(this(i).StoreSubstitutions);
                for j = 1 : numel(list)
                    substitutions.(list{j}) = this(i).StoreSubstitutions.(list{j});
                end
            end
        end%
    end
    
    
    methods (Static)
        function [ finalCut, ...
                   fileName, ...
                   export, ...
                   ctrlParameters, ...
                   userComment, ...
                   substitutions ] = parse(modelFile, inpCode, varargin)

            import parser.Preparser

            persistent inputParser
            if isempty(inputParser)
                inputParser = extend.InputParser('Preparser.parse');
                inputParser.addRequired('ModelFile', @(x) isempty(x) || ischar(x) || isa(x, 'string') || iscellstr(x) || isa(x, 'model.File'));
                inputParser.addRequired('InputCode', @(x) isempty(x) || ischar(x) || isa(x, 'string') || iscellstr(x));
                inputParser.addParameter('Assigned', struct( ), @(x) isempty(x) || isstruct(x));
                inputParser.addParameter('SaveAs', '', @(x) isempty(x) || ischar(x) || isa(x, 'string'));
                inputParser.addParameter('CloneString', '', @(x) isempty(x) || ischar(x) || isa(x, 'string')); 
            end
            inputParser.parse(modelFile, inpCode, varargin{:});
            assigned = inputParser.Results.Assigned;
            saveAs = inputParser.Results.SaveAs;
            cloneString = inputParser.Results.CloneString;
            
            this = parser.Preparser(modelFile, inpCode, assigned, cloneString);
            % Combine file names
            fileName = getFileName(this); 
            % Compose final code
            finalCut = createFinalCut(this);
            % Apply preparsing commands to the final cut
            finalCut = applyFinalCutCommands(this, finalCut);
            % Return list of control parameters
            ctrlParameters = unique( [ this(:).CtrlParameters ] );
            % Merge all exported files
            export = [ this(:).Export ];
            % First-line comment from the first file
            userComment = this(1).UserComment;
            % Return database of substitutions
            substitutions = mergeSubstitutions(this);
            % Save preparsed code to disk file if requested
            if ~isempty(saveAs)
                Preparser.saveAs(finalCut, saveAs);
            end
        end%
        
        
        function c = convertEols(c)
            % convertEols - Convert any style EOLs to Unix style.
            % Windows:
            c = strrep(c, sprintf('\r\n'), sprintf('\n'));
            % Mac:
            c = strrep(c, sprintf('\r'), sprintf('\n'));            
        end%
        
        
        function varargout = eval(varargin)
            if isempty(regexp(varargin{1}, '[A-Za-z_\?]', 'once'))
                varargout{1} = eval(varargin{1});
            else
                parser.Preparser.evalPopulateWorkspace(varargin{:});
                varargout{1} = eval(varargin{1});
            end
        end%
        
        
        function evalPopulateWorkspace(expn, assigned, p)
            import parser.White;
            shadowExpn = White.whiteOutLabel(expn);
            shadowExpn = strrep(shadowExpn, '!', '');
            lsAssigned = fieldnames(assigned);
            lsAssigned = lsAssigned(:).';
            lsExpn = regexp( shadowExpn, ...
                             '(?<!\.)\<[a-zA-Z]\w*\>(?![\(\.])', ...
                             'match' );
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
        end%
        
        
        function saveAs(codeToSave, fileName)
            if ~isempty(fileName)
                try
                    char2file(codeToSave, fileName);
                catch
                    throw( exception.ParseTime('Preparser:CANNOT_SAVE', 'error'), ...
                           fileName ); %#ok<GTARG>
                end
            end
        end%
        
        
        function code = removeInsignificantWhs(code)
            code = strtrim(code);
            code = regexprep(code,'\s+',' ');
        end%
    end
end
