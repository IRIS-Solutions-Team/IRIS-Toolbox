classdef Preparser ...
    < model.File

    properties
        UserComment = char.empty(1, 0)  % User comment line read from code
        White = char.empty(1, 0)  % Code with all labels whited out
        Assigned = struct.empty( ) % Database with control parameters

        % AngleBrackets  Angle brackets can be used as an alternative to enclose Matlab expressions
        AngleBrackets = true

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
    end


    
    
    methods
        function this = Preparser( ...
            modelFile, inpCode, assigned ...
            , cloneTemplate, angleBrackets, skip ...
        )

            import parser.Preparser

            if nargin==0
                return
            end

            try, angleBrackets;
                catch, angleBrackets = false; end

            try, skip;
                catch, skip = string.empty(1, 0); end

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
                    code = modelFile(i).Code;
                    if isa(code, 'string')
                        code = join(code, newline( ));
                        code = char(code);
                    end
                    this(i).Code = code;
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
                this(i).AngleBrackets = angleBrackets;
                this(i).CloneTemplate = cloneTemplate; %#ok<AGROW>
            end

            for i = 1 : numel(this)
                this__ = this(i);

                % Store parsed file name
                exception.ParseTime.storeFileName(this__.FileName);
                if isempty(this__.Code)
                    continue
                end

                % Replace interpolation brackets $[...]$ with unicodes
                % before comments where the white code is created; this is
                % necessary because we're replacing two characters with
                % one, e.g. `$[` with `<`
                % this__.Code = parser.Interp.replaceSquareBrackets(this__.Code);
                
                %
                % Preparse individual components
                %
                if ~any(skip=="UserComment")
                    parser.UserComment.parse(this__);
                end

                if ~any(skip=="Comment")
                    parser.Comment.parse(this__);
                end

                if ~any(skip=="Control")
                    parser.control.Control.parse(this__);
                end

                %
                % Resolve interpolations *after* controls so that interpolated expressions
                % can refer to !for control variables. Interpolations between !for and
                % !do keywords are resolved separately within For.writeFinal( ) in the
                % previous step.
                %
                if ~any(skip=="Interp")
                    parser.Interp.parse(this__);
                end

                if ~any(skip=="Substitution")
                    parser.Substitution.parse(this__);
                end

                if ~any(skip=="Pseudofunc")
                    parser.Pseudofunc.parse(this__);
                end

                if ~any(skip=="DoubleDot")
                    parser.DoubleDot.parse(this__);
                end

                % Check leading and trailing empty lines
                fixEmptyLines(this__);
                % Clone preparsed code
                if ~isempty(cloneTemplate)
                    this__.Code = model.File.cloneAllNames(this__.Code, this__.CloneTemplate);
                end
                throwEvalWarning(this__);
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
            n = numel(this);
            for i = 1 : n
                f = [ f, char(this(i).FileName) ]; %#ok<AGROW>
                if i<n
                    f = [ f, Preparser.FILE_NAME_SEPARATOR ]; %#ok<AGROW>
                end
            end 
        end%
        
        
        function c = createFinalCut(this)
            import parser.Preparser;
            c = '';
            nThis = numel(this);
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
        function [ ...
            finalCut, fileName, export ...
            , ctrlParameters, userComment, substitutions ...
        ] = parse(modelFile, inpCode, varargin)

            import parser.Preparser

            if ~isempty(varargin) && isa(varargin{1}, 'parser.Preparser')
                temp = struct( );
                temp.AngleBrackets = varargin{1}.AngleBrackets;
                temp.Assigned = varargin{1}.Assigned;
                temp.Clone = varargin{1}.CloneTemplate;
                varargin{1} = temp;
            end

            %( Input parser
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('@Preparser/parse');
                pp.KeepUnmatched = true;
                addRequired(pp, 'modelFile', @(x) isempty(x) || ischar(x) || isa(x, 'string') || iscellstr(x) || isa(x, 'model.File'));
                addRequired(pp, 'inputCode', @(x) isempty(x) || ischar(x) || isa(x, 'string') || iscellstr(x));

                addParameter(pp, 'SaveAs', '', @(x) isempty(x) || ischar(x) || isa(x, 'string'));

                addParameter(pp, 'AngleBrackets', true, @validate.logicalScalar);
                addParameter(pp, {'Assigned', 'Assign'}, struct( ), @(x) isempty(x) || isstruct(x));
                addParameter(pp, {'CloneTemplate', 'CloneString'}, '', @(x) isempty(x) || ischar(x) || isstring(x)); 
                addParameter(pp, 'Skip', string.empty(1, 0), @isstring);
            end
            %)
            opt = parse(pp, modelFile, inpCode, varargin{:});
            
            %
            % Create @Preparser object and parse the components
            %
            this = parser.Preparser( ...
                modelFile, inpCode, ...
                opt.Assigned, opt.CloneTemplate, opt.AngleBrackets, reshape(opt.Skip, 1, [ ]) ...
            );

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
            if ~isempty(opt.SaveAs)
                Preparser.saveAs(finalCut, opt.SaveAs);
            end
        end%
        


        
        function c = convertEols(c)
            % convertEols - Convert any style EOLs to Unix style.
            % Windows:
            c = strrep(c, sprintf('\r\n'), newline( ));
            % Mac:
            c = strrep(c, sprintf('\r'), newline( ));            
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
            import parser.White
            shadowExpn = White.whiteOutLabel(expn);
            shadowExpn = strrep(shadowExpn, '!', '');
            listAssigned = fieldnames(assigned);
            listAssigned = listAssigned(:).';
            listExpn = regexp( shadowExpn, ...
                             '(?<!\.)\<[a-zA-Z]\w*\>(?![\(\.])', ...
                             'match' );
            ixControl = false(size(listAssigned));
            for i = 1 : length(listExpn)
                name = listExpn{i};
                ix = strcmp(name, listAssigned);
                if any(ix)
                    assignin('caller', name, assigned.(name));
                    ixControl = ixControl | ix;
                end
            end
            if nargin>2 && any(ixControl)
                addCtrlParameter(p, listAssigned(ixControl));
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
