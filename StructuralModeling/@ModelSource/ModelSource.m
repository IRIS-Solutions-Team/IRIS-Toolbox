classdef ModelSource ...
    < matlab.mixin.Copyable

    %#ok<*NASGU>
    %#ok<*GTARG>

    properties
        FileName (1, :) string = string.empty(1, 0)
        Code (1, :) char = char.empty(1, 0)
        Preparsed (1, 1) logical = false
        ClonePattern (1, 2) string = ["", ""]
    end


    properties (Constant, Hidden)
        UTF = char([239, 187, 191])
        PROTECTED_QUOTE_PATTERN = '%s__%g%s'
        PROTECTED_KEYWORDS = [
            "!transition-variables", "!transitionvariables"
            "!transition-shocks", "!transitionshocks"
            "!transition-equations", "!transitionequations"
            "!log-variables", "!logvariables"
            "!all-but", "!allbut"
            "!measurement-variables", "!measurementvariables"
            "!measurement-shocks", "!measurementshocks"
            "!measurement-equations", "!measurementequations"
        ];
        NAME_PATTERN = '(?<![!\?:])\<[A-Za-z]\w*\>(?!\()'
        CODE_SEPARATOR = string(repmat(char(newline()), 1, 2))
        FILE_NAME_WHEN_INPUT_STRING = "[input-string]"
    end


    methods
        function this = ModelSource(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'ModelSource')
                this = varargin{1};
                return
            end
            % Legacy syntax
            this = ModelSource.fromFile(varargin{:});
        end%


        function that = clone(this, clonePattern, varargin)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('@ModelSource/clone');
                addRequired(pp, 'modelFile', @(x) isa(x, 'ModelSource'))
                addRequired(pp, 'clonePattern', @(x) isstring(x) && isequal(size(x), [1, 2]));
                addParameter(pp, 'NamesToKeep', string.empty(1, 0), @validate.mustBeText);
            end
            opt = parse(pp, this, clonePattern, varargin{:});

            %
            % Make copy of this handle objects
            %
            that = copy(this);
            that.ClonePattern = clonePattern;

            %
            % Remove comment lines
            %
            that.Code = parser.Comment.parse(that.Code);

            code = that.Code;
            [code, quotes] = ModelSource.protectQuotes(code);
            code = ModelSource.protectKeywords(code);

            if isempty(opt.NamesToKeep)
                code = ModelSource.cloneAllNames(code, clonePattern);
            else
                namesToKeep = string(opt.NamesToKeep);
                code = ModelSource.cloneAllNames(code, @replaceFunction);
            end
            code = ModelSource.restoreQuotes(code, quotes);
            code = ModelSource.restoreKeywords(code);
            that.Code = code;
            return

                function x = replaceFunction(x)
                    if any(x==namesToKeep)
                        return
                    end
                    x = clonePattern(1) + string(x) + clonePattern(2);
                end%
        end%


        function cloneToFile(this, outputFileName, varargin)
            this = clone(this, varargin{:});
            save(this, outputFileName);
        end%


        function save(this, outputFileName)
            [outputPath, outputTitle, outputExt] = fileparts(string(outputFileName));
            for i = 1 : numel(this)
                clonePattern__ = this(i).ClonePattern;
                outputTitle__ = clonePattern__(1) + outputTitle + clonePattern__(2);
                outputFileName__ = fullfile(outputPath, outputTitle__ + outputExt);
                ModelSource.write(this(i).Code, outputFileName__);
            end
        end%


        function names = collectAllNames(this, test)
            names = regexp(string(this.Code), string(this.NAME_PATTERN), "match");
            if nargin<2
                return
            end
            names = names(test(names));
        end%


        function set.Code(this, value)
            this.Code = char(join(string(value), newline()));
        end%


        function this = preparse(this, varargin)
            this.Code = parser.Preparser.parse([], this.Code, varargin{:});
        end%
    end


    methods (Static)
        function this = fromFile(fileName, varargin)
            persistent pp
            if isempty(pp)
                pp = inputParser();
                pp.KeepUnmatched = true;
                pp.addParameter("Markdown", @auto);
            end
            pp.parse(varargin{:});
            opt = pp.Results;

            this = ModelSource();
            this.FileName = reshape(string(fileName), 1, []);
            this.Code = '';
            for n = this.FileName
                currCode = fileread(n);
                [~, ~, extension] = fileparts(string(n));
                currCode = ModelSource.removeUTF(currCode);
                currCode = ModelSource.convertEOL(currCode);
                currCode = ModelSource.addLineBreak(currCode);
                if isequal(opt.Markdown, true) || (isequal(opt.Markdown, @auto) && lower(extension)==".md")
                    currCode = mdown.backend.toMatlab(currCode);
                end
                this.Code = [this.Code, char(ModelSource.CODE_SEPARATOR), char(currCode)];
            end
        end%


        function this = fromString(inputString, varargin)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser();
                pp.KeepUnmatched = true;
                pp.addParameter("Markdown", @auto);
            end
            pp.parse(varargin{:});
            opt = pp.Results;

            this = ModelSource();
            this.FileName = ModelSource.FILE_NAME_WHEN_INPUT_STRING;
            this.Code = '';
            for code = textual.stringify(inputString)
                rawCode = code;
                if isequal(opt.Markdown, true) 
                    rawCode = mdown.backend.toMatlab(code);
                end
                this.Code = [this.Code, char(ModelSource.CODE_SEPARATOR), char(rawCode)];
            end
        end%


        function text = removeUTF(text)
            if strncmp(text, ModelSource.UTF, length(ModelSource.UTF))
                text = text(length(UTF)+1:end);
            end
        end%


        function text = convertEOL(text)
            text = strrep(text, sprintf('\r\n'), newline());
            text = strrep(text, sprintf('\r'), newline());
        end%


        function text = addLineBreak(text)
            br = newline();
            if isempty(text) || text(end)~=br
                text = [text, br];
            end
        end%


        function write(text, outputFileName)
            fid = fopen(outputFileName, 'w+');
            if fid==-1
                throw( exception.Base('ModelSource:CannotOpenTextFile', 'error'), ...
                       outputFileName );
            end
            text = join(string(text), newline());
            if strlength(text)>0
                text = extractBefore(text, strlength(text));
            end
            count = fwrite(fid, text, 'char');
            fclose(fid);
            if count~=strlength(text)
                throw( exception.Base('ModelSource:CannotWriteToTextFile', 'error'), ...
                       outputFileName );
            end
        end%


        function [code, quotes] = protectQuotes(code)
            quotes = string.empty(0, 2);
            replaceFunction = @storeAndReplace;
            code = regexprep(code, '([''"]).*?\1', '${replaceFunction($0, $1)}');
            return
                function x = storeAndReplace(s0, s1)
                    n = size(quotes, 1) + 1;
                    x = sprintf(ModelSource.PROTECTED_QUOTE_PATTERN, s1, n, s1);
                    quotes(end+1, :) = [string(s0), string(x)];
                end%
        end%


        function code = protectKeywords(code)
            % Workaround for Matlab bug in older versions
            % ModelSource.PROTECTED_KEYWORD(:,1) does not work properly
            protectedKeywords = ModelSource.PROTECTED_KEYWORDS;
            code = replace(code, protectedKeywords(:, 1), protectedKeywords(:, 2));
        end%


        function code = restoreQuotes(code, quotes)
            code = replace(code, quotes(:, 2), quotes(:, 1));
        end%


        function code = restoreKeywords(code)
            % Workaround for Matlab bug in older versions
            % ModelSource.PROTECTED_KEYWORD(:,1) does not work properly
            protectedKeywords = ModelSource.PROTECTED_KEYWORDS;
            code = replace(code, protectedKeywords(:, 2), protectedKeywords(:, 1));
        end%


        function code = cloneAllNames(code, replace)
            if isstring(replace)
                if any(strlength(replace)>0)
                    clonePattern = replace;
                    code = regexprep(code, ModelSource.NAME_PATTERN, clonePattern(1) + "$0" + clonePattern(2));
                end
            else
                replaceFunc = replace;
                code = regexprep(code, ModelSource.NAME_PATTERN, "${replaceFunc($0)}");
            end
        end%
    end
end

