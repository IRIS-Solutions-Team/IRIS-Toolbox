classdef Preparser ...
    < ModelSource

    %#ok<*AGROW>

    properties
        UserComment (1, :) string = ""  % User comment line read from code
        White = char.empty(1, 0)  % Code with all labels whited out
        Assigned = struct.empty( ) % Database with control parameters

        % AngleBrackets  Angle brackets can be used as an alternative to enclose Matlab expressions
        AngleBrackets = true

        CloneTemplate (1, 2) string = ["", ""]  % Template to clone model names
        Export = iris.mixin.Export.empty(1, 0) % Files to be saved into working folder
        CtrlParameters (1, :) string = string.empty(1, 0) % List of parameter names occuring in control expressions and interpolations
        EvalWarning = parser.Preparser.EVAL_WARNING % List of if/elseif/switch/case conditions/expressions producing errors

        StoreForCtrl = string.empty(0, 2) % Store !for control variable replacements
        StoreSubstitutions = struct( ) % Store substitution names and bodies
    end




    properties (Constant)
        EVAL_WARNING = struct( ...
            'If', {{}}, ...
            'Switch', {{}}, ...
            'Case', {{}} ...
        )
    end




    methods
        function this = Preparser(modelSource, inputCode, opt)

            if nargin==0
                return
            end


            if ~isempty(inputCode) 
                this = parser.Preparser.fromInputCode(this, inputCode);
            else
                this = parser.Preparser.fromModelFile(this, modelSource);
            end


            for i = 1 : numel(this)
                this(i).Assigned = opt.Assigned;
                this(i).AngleBrackets = opt.AngleBrackets;
                this(i).CloneTemplate = opt.CloneTemplate;
            end

            for i = 1 : numel(this)
                currSource = this(i);

                % Store parsed file name
                exception.ParseTime.storeFileName(currSource.FileName);
                if isempty(currSource.Code)
                    continue
                end

                % Replace interpolation brackets $[...]$ with unicodes
                % before comments where the white code is created; this is
                % necessary because we're replacing two characters with
                % one, e.g. `$[` with `<`
                % currSource.Code = parser.Interp.replaceSquareBrackets(currSource.Code);

                %
                % Preparse individual components
                %
                if ~any(opt.Skip=="UserComment")
                    parser.UserComment.parse(currSource);
                end

                if ~any(opt.Skip=="Comment")
                    parser.Comment.parse(currSource);
                end

                if ~any(opt.Skip=="Control")
                    parser.control.Control.parse(currSource);
                end

                % Resolve interpolations *after* controls so that interpolated expressions
                % can refer to !for control variables. Interpolations between !for and
                % !do keywords are resolved separately within For.writeFinal( ) in the
                % previous step.

                if ~any(opt.Skip=="Interp")
                    currSource.Code = char(parser.Interp.parse(currSource));
                end

                if ~any(opt.Skip=="Substitution")
                    parser.Substitution.parse(currSource);
                end

                if ~any(opt.Skip=="Pseudofunc")
                    parser.Pseudofunc.parse(currSource);
                end

                if ~any(opt.Skip=="DoubleDot")
                    parser.DoubleDot.parse(currSource);
                end

                % Check leading and trailing empty lines
                fixEmptyLines(currSource);
                % Clone preparsed code
                if any(strlength(currSource.CloneTemplate)>0)
                    currSource.Code = ModelSource.cloneAllNames(currSource.Code, currSource.CloneTemplate);
                end
                throwEvalWarning(currSource);
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
            c = ModelSource.addLineBreak(c);
            this.Code = c;
        end%


        function c = createFinalCut(this)
            c = '';
            nThis = numel(this);
            for iThis = 1 : nThis
                c = [ c, this(iThis).Code ];
                if iThis<nThis
                    c = [c, char(ModelSource.CODE_SEPARATOR)];
                end
            end
        end%


        function c = applyFinalCutCommands(this, c) %#ok<INUSL>
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
        function this = fromInputCode(this, inputCode)
            %(
            % Input code from input string(s)
            inputCode = reshape(string(inputCode), 1, []);
            inputCode(inputCode=="") = [];
            inputCode = join(inputCode, ModelSource.CODE_SEPARATOR);
            % for n = inputCode
                % % Because Preparser is a handle class we need to create separate instances for
                % % each file name inside the for loop
                % add = parser.Preparser();
                % add.Code = char(n);
                % this(end+1) = add;
            % end
            this.Code = char(inputCode);
            %)
        end%


        function this = fromModelFile(this, modelSource)
            %(
            if ~isa(modelSource, 'ModelSource')
                % Remove model file names starting with a hat ^
                fileName = reshape(strip(string(modelSource)), 1, []);
                fileName(startsWith(fileName, "^")) = [];

                % Throw an error if there is no model file name to read
                if isempty(fileName) || all(strlength(fileName)==0)
                    exception.exception([
                        "Preparser:NoModelFileSpecified"
                        "No model source file specified"
                    ]);
                end
                % Combine all input model source files in one model
                % file; this is to make the substitutions global across
                % all source files
                modelSource = ModelSource(fileName);
            end
            this = this([]);
            for i = 1 : numel(modelSource)
                % Because Preparser is a handle class we need to create separate instances for
                % each file name inside the loop
                this = [this, parser.Preparser()];
                this(end).FileName = string(modelSource(i).FileName);
                code = modelSource(i).Code;
                if isa(code, 'string')
                    code = join(code, string(newline()));
                    code = char(code);
                end
                this(end).Code = code;
            end
            %)
        end%


        function ...
            [finalCut, fileNames, export, controls, comment, substitutions] ...
            = parse(modelSource, inputCode, varargin)

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
                addRequired(pp, 'modelSource', @(x) isempty(x) || ischar(x) || isstring(x) || iscellstr(x) || isa(x, 'ModelSource'));
                addRequired(pp, 'inputCode', @(x) isempty(x) || ischar(x) || isstring(x) || iscellstr(x));

                addParameter(pp, 'SaveAs', '', @(x) isempty(x) || ischar(x) || isstring(x));

                addParameter(pp, 'AngleBrackets', true, @validate.logicalScalar);
                addParameter(pp, {'Assigned', 'Assign'}, struct( ), @(x) isempty(x) || isstruct(x));
                addParameter(pp, {'CloneTemplate', 'CloneString'}, ["", ""], @(x) isstring(x) && isequal(size(x), [1, 2]));
                addParameter(pp, 'Skip', string.empty(1, 0), @isstring);
            end
            %)
            opt = parse(pp, modelSource, inputCode, varargin{:});
            opt.Skip = reshape(opt.Skip, 1, []);

            % Create @Preparser object and parse the components
            this = parser.Preparser(modelSource, inputCode, opt);

            % Store all file names in a string array
            fileNames = [this(:).FileName];

            % Compose final code
            finalCut = createFinalCut(this);

            % Resolve !list()
            finalCut = parser.List.parse(finalCut);

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
                parser.Preparser.saveAs(finalCut, opt.SaveAs, fileNames);
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

