classdef File ...
    < handle

    properties
        FileName = char.empty(1, 0)
        Code = char.empty(1, 0)
        Preparsed = false
    end


    properties (Constant)
        UTF = char([239, 187, 191])
        PROTECTED_QUOTE_PATTERN = '%s__%g%s'
        CLONE_PATTERN = '(?<![!\?])\<[A-Za-z]\w*\>(?!\()'
    end


    methods
        function this = File(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'model.File')
                this = varargin{1};
                return
            end
            this.FileName = varargin{1};
            this.Code = fileread(this.FileName);
            this.Code = model.File.removeUTF(this.Code);
            this.Code = model.File.convertEOL(this.Code);
            this.Code = model.File.addLineBreak(this.Code);
        end%

            
        function clone(this, cloneString, varargin)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('model.File.clone');
                addRequired(pp, 'ModelFile', @(x) isa(x, 'model.File'))
                addRequired(pp, 'CloneString', @(x) ischar(x) || isa(x, 'string') || isnumeric(x));
                addParameter(pp, 'NamesToClone', cell.empty(1, 0), @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
                addParameter(pp, 'NamesToKeep', cell.empty(1, 0), @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
            end
            parse(pp, this, cloneString, varargin{:});
            opt = pp.Options;
            this.Code = parser.Comment.parse(this.Code);
            [code, quotes] = model.File.protectQuotes(this.Code);
            if isempty(opt.NamesToClone) && isempty(opt.NamesToKeep)
                code = model.File.cloneAllNames(code, cloneString);
            else
                namesToClone = cellstr(opt.NamesToClone);
                namesToKeep = cellstr(opt.NamesToKeep);
                code = model.File.cloneAllNames(code, cloneString, @replaceFunction);
            end
            this.Code = model.File.restoreQuotes(code, quotes);
            return
                function x = replaceFunction(x, cloneString)
                    if ( ~isempty(namesToClone) && any(strcmp(namesToClone, x)) ) ...
                       || ( ~isempty(namesToKeep) && ~any(strcmp(namesToKeep, x)) )
                        x = strrep(cloneString, '$', x);
                    end
                end%
        end%


        function cloneToFile(this, outputFileName, varargin)
            this = clone(this, varargin{:});
            model.File.write(this.Code, outputFileName);
        end%
    end


    methods (Static)
        function text = removeUTF(text)
            if strncmp(text, model.File.UTF, length(model.File.UTF))
                text = text(length(UTF)+1:end);
            end
        end%


        function text = convertEOL(text)
            text = strrep(text, sprintf('\r\n'), sprintf('\n'));
            text = strrep(text, sprintf('\r'), sprintf('\n'));
        end%


        function text = addLineBreak(text)
            br = sprintf('\n');
            if isempty(text) || text(end)~=br
                text = [text, br];
            end        
        end%
        

        function write(text, outputFileName)
            fid = fopen(outputFileName, 'w+');
            if fid==-1
                throw( exception.Base('Model:File:CannotOpenTextFile', 'error'), ...
                       outputFileName );
            end
            if iscellstr(text)
                text = sprintf('%s\n', text{:});
                if ~isempty(text)
                    text(end) = '';
                end
            end
            count = fwrite(fid, text, 'char');
            fclose(fid);
            if count~=length(text)
                throw( exception.Base('Model:File:CannotWriteToTextFile', 'error'), ...
                       outputFileName );
            end
        end%


        function [code, quotes] = protectQuotes(code)
            quotes = cell.empty(0, 2);
            replaceFunction = @storeAndReplace;
            code = regexprep(code, '([''"])[^\1]*\1', '${replaceFunction($0, $1)}');  
            return
                function x = storeAndReplace(s0, s1)
                    n = size(quotes, 1) + 1;
                    x = sprintf(model.File.PROTECTED_QUOTE_PATTERN, s1, n, s1);
                    quotes = [quotes; {s0, x}];
                end%
        end%


        function code = restoreQuotes(code, quotes)
            for i = 1 : size(quotes, 1)
                code = strrep(code, quotes{i, 2}, quotes{i, 1});
            end
        end%


        function code = cloneAllNames(code, cloneString, replaceFunction)
            if ~model.File.checkCloneString(cloneString)
                if isnumeric(cloneString)
                    cloneString = sprintf('%g', cloneString);
                else
                    cloneString = char(cloneString);
                end
                cloneString = ['$_', cloneString];
            end
            if nargin<3
                cloneString = strrep(cloneString, '$', '$0');
                cloneString = strrep(cloneString, '?', '$0');
                code = regexprep(code, model.File.CLONE_PATTERN, cloneString);
            else
                replace = sprintf('${replaceFunction($0, ''%s'')}', cloneString);
                code = regexprep(code, model.File.CLONE_PATTERN, replace);
            end
        end%


        function flag = checkCloneString(c)
            if ~ischar(c) && ~isa(c, 'string')
                flag = false;
                return
            end
            if ~isempty(strfind(c, '$'))
                flag = isvarname(strrep(c, '$', 'x'));
                return
            elseif ~isempty(strfind(c, '?'))
                flag = isvarname(strrep(c, '$', 'x'));
                return
            else
                flag = false;
                return
            end
        end%
    end
end

