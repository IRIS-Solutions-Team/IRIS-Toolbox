classdef Preparser ...
    < model.File

    %#ok<*AGROW>

    properties
        UserComment (1, :) string = ""  % User comment line read from code
        White = char.empty(1, 0)  % Code with all labels whited out
        Assigned = struct.empty( ) % Database with control parameters

        % AngleBrackets  Angle brackets can be used as an alternative to enclose Matlab expressions
        AngleBrackets = true

        CloneTemplate (1, 2) string = ["", ""]  % Template to clone model names
        Export = shared.Export.empty(1, 0) % Files to be saved into working folder
        CtrlParameters (1, :) string = string.empty(1, 0) % List of parameter names occuring in control expressions and interpolations
        EvalWarning = parser.Preparser.EVAL_WARNING % List of if/elseif/switch/case conditions/expressions producing errors

        StoreForCtrl = string.empty(0, 2) % Store !for control variable replacements
        StoreSubstitutions = struct( ) % Store substitution names and bodies
    end




    properties (Constant)
        EVAL_DBASE_PREFIX = 'varargin{2}.'
        EVAL_TEMP_PREFIX = '?.'

        EVAL_WARNING = struct( ...
            'If',{{}}, ...
            'Switch',{{}}, ...
            'Case',{{}} ...
        )

        CODE_SEPARATOR = sprintf('\n\n');
        FILE_NAME_SEPARATOR = ' & ';
    end




    methods
        function this = Preparser( ...
            modelFile, inputCode, assigned ...
            , cloneTemplate, angleBrackets, skip ...
        )

            import parser.Preparser

            if nargin==0
                return
            end

            try, angleBrackets; %#ok<VUNUS>
                catch, angleBrackets = false; end

            try, skip; %#ok<VUNUS>
                catch, skip = string.empty(1, 0); end

            if ~isempty(inputCode) && any(strlength(inputCode)>0)
                % Input code from input string(s)
                inputCode = reshape(string(inputCode), 1, []);
                inputCode(inputCode=="") = [];
                for n = inputCode
                    % Because Preparser is a handle class we need to create separate instances for
                    % each file name inside the for loop
                    add = parser.Preparser();
                    add.Code = char(n);
                    this(end+1) = add;
                end                
            else
                if ~isa(modelFile, 'model.File')
                    % Remove model file names starting with a hat ^
                    fileName = reshape(strip(string(modelFile)), 1, []);
                    fileName(startsWith(fileName, "^")) = [];

                    % Throw an error if there is no model file name to read
                    if isempty(fileName)
                        exception.exception([
                            "Preparser:NoModelFileSpecified"
                            "No model source file specified"
                        ]);
                    end

                    % Create an array of model.File objects
                    % modelFile = model.File.empty(1, 0);
                    % for n = fileName
                        % modelFile = [modelFile, model.File(n)];
                    % end

                    % Combine all input model source files in one model
                    % file; this is to make the substitutions global across
                    % all source files
                    modelFile = model.File(fileName);
                end

                for i = 1 : numel(modelFile)
                    % Because Preparser is a handle class we need to create separate instances for
                    % each file name inside the loop
                    this(i) = parser.Preparser( );
                    this(i).FileName = string(modelFile(i).FileName);
                    code = modelFile(i).Code;
                    if isa(code, 'string')
                        code = join(code, newline( ));
                        code = char(code);
                    end
                    this(i).Code = code;
                end
            end

            for i = 1 : numel(this)
                this(i).Assigned = assigned;
                this(i).AngleBrackets = angleBrackets;
                this(i).CloneTemplate = cloneTemplate;
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


                % Resolve interpolations *after* controls so that interpolated expressions
                % can refer to !for control variables. Interpolations between !for and
                % !do keywords are resolved separately within For.writeFinal( ) in the
                % previous step.

                if ~any(skip=="Interp")
                    this__.Code = char(parser.Interp.parse(this__));
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
                if any(strlength(this__.CloneTemplate)>0)
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


        function c = createFinalCut(this)
            import parser.Preparser;
            c = '';
            nThis = numel(this);
            for iThis = 1 : nThis
                c = [ c, this(iThis).Code ];
                if iThis<nThis
                    c = [ c, Preparser.CODE_SEPARATOR ];
                end
            end
        end%


        function c = applyFinalCutCommands(this, c) %#ok<INUSL>
            c = parser.List.parse(c);
        end%


        function d = createCtrlDatabase(this)
            assigned = this(1).Assigned;
            d = struct( );
            for n = [this(:).CtrlParameters]
                try %#ok<TRYNC>
                    % Only create the field if it exists in input database
                    d.(n) = assigned.(n);
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
            if ~isstring(add)
                add = string(add);
            end
            this.CtrlParameters = [this.CtrlParameters, reshape(add, 1, [ ])];
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
            substitutions = struct();
            for i = 1 : numel(this)
                list = fieldnames(this(i).StoreSubstitutions);
                for j = 1 : numel(list)
                    substitutions.(list{j}) = this(i).StoreSubstitutions.(list{j});
                end
            end
        end%
    end


    methods (Static)
        function [finalCut, fileNames, export, controls, comment, substitutions] ...
            = parse(modelFile, inputCode, varargin)

            import parser.Preparser

            if ~isempty(varargin) && isa(varargin{1}, "parser.Preparser")
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
                addRequired(pp, 'modelFile', @(x) isempty(x) || ischar(x) || isstring(x) || iscellstr(x) || isa(x, 'model.File'));
                addRequired(pp, 'inputCode', @(x) isempty(x) || ischar(x) || isstring(x) || iscellstr(x));

                addParameter(pp, 'SaveAs', '', @(x) isempty(x) || ischar(x) || isstring(x));

                addParameter(pp, 'AngleBrackets', true, @validate.logicalScalar);
                addParameter(pp, {'Assigned', 'Assign'}, struct( ), @(x) isempty(x) || isstruct(x));
                addParameter(pp, {'CloneTemplate', 'CloneString'}, ["", ""], @(x) isstring(x) && isequal(size(x), [1, 2]));
                addParameter(pp, 'Skip', string.empty(1, 0), @isstring);
            end
            %)
            opt = parse(pp, modelFile, inputCode, varargin{:});

            % Create @Preparser object and parse the components
            this = parser.Preparser( ...
                modelFile, inputCode, ...
                opt.Assigned, opt.CloneTemplate, opt.AngleBrackets, reshape(opt.Skip, 1, [ ]) ...
            );

            % Store all file names in a string array
            fileNames = [this(:).FileName];

            % Compose final code
            finalCut = createFinalCut(this);
            % Apply preparsing commands to the final cut
            finalCut = applyFinalCutCommands(this, finalCut);
            % Return list of control parameters
            controls = unique([this(:).CtrlParameters]);
            % Merge all exported files
            export = [ this(:).Export ];
            % First-line comment from the first file
            comment = [ this(:).UserComment ];
            % Return database of substitutions
            substitutions = mergeSubstitutions(this);
            % Save preparsed code to disk file if requested
            if ~isempty(opt.SaveAs)
                Preparser.saveAs(finalCut, opt.SaveAs, fileNames);
            end
        end%




        function c = convertEols(c)
            % convertEols - Convert any style EOLs to Unix style.
            % Windows:
            c = replace(c, sprintf('\r\n'), newline( ));
            % Mac:
            c = replace(c, sprintf('\r'), newline( ));            
        end%


        function varargout = eval(varargin)
            if isempty(regexp(varargin{1}, "[A-Za-z]", "once"))
                % No letters means no variables, evaluate right away
                varargout{1} = eval(varargin{1});
            else
                parser.Preparser.evalPopulateWorkspace(varargin{:});
                varargout{1} = eval(varargin{1});
            end
        end%


        function evalPopulateWorkspace(expression, assigned, p)
            expression = char(expression);
            shadowExpression = parser.White.whiteOutLabels(expression);
            shadowExpression = replace(shadowExpression, "!", "");
            namesAssigned = reshape(string(fieldnames(assigned)), 1, [ ]);
            namesWithinExpression = regexp( ...
                string(shadowExpression) ...
                , "(?<!\.)\<[a-zA-Z]\w*\>(?![\.])" ...
                , "match" ...
            );
            inxControl = false(size(namesAssigned));
            for n = reshape(namesWithinExpression, 1, [ ])
                inx = n==namesAssigned;
                if any(inx)
                    assignin('caller', n, assigned.(n));
                    inxControl = inxControl | inx;
                end
            end
            if nargin>2 && any(inxControl)
                addCtrlParameter(p, namesAssigned(inxControl));
            end
        end%


        function saveAs(code, fileName, sourceFiles)
            if isempty(fileName) || all(strlength(fileName)==0)
                return
            end

            HEADER = "% [IrisToolbox] autogenerated preparsed model source code " + string(datestr(now()));

            code = string(code);

            % Replace multiple spaces on line with a single space
            code = regexprep(code, "(?<=\S)[ ]+(?=\S)", " ");

            % Replace more than two blank lines with a single one
            code = regexprep(code, "\n *\n *\n( *\n)+", "\n\n\n");

            joinedFiles = "";
            if ~isempty(sourceFiles) && any(strlength(sourceFiles)>0)
                joinedFiles = ...
                    sprintf("\n%%") ...
                    + sprintf("\n%% * %s", sourceFiles(strlength(sourceFiles)>0));
            end

            % Add the header and list of model source files
            codeToSave = HEADER ...
                + joinedFiles ...
                + sprintf("\n\n\n") ...
                + code;

            % Convert to char for older Matlab compatibility and save to
            % text file
            textual.write(codeToSave, fileName);
        end%


        function code = removeInsignificantWhs(code)
            code = strtrim(code);
            code = regexprep(code,'\s+',' ');
        end%
    end
end

