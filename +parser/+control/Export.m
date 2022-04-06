classdef Export < parser.control.ExternalFile
    properties
        Body
    end


    methods
        function this = Export(varargin)
            if isempty(varargin)
                return
            end
            c = varargin{1};
            sh = varargin{2};
            construct(this, c, sh);
        end%


        function c = writeFinal(this, p, varargin)
            import parser.control.For;
            c = '';
            fileName = this.FileName;
            if ~isempty(p.StoreForCtrl) && any(contains(fileName, '?'))
                fileName = For.substitute(fileName, p);
            end
            fileName = strip(fileName);
            contents = writeFinal(this.Body, p, varargin{:});
            contents = textfun.removeltel(contents);
            contents = completeFileContents(this, contents);
            addExport = iris.mixin.Export(fileName, contents);
            p.Export = [p.Export, addExport];
        end%


        function construct(this, c, sh)
            import parser.control.*;
            c0 = c;
            key = Keyword.EXPORT;
            [fileName, c, sh] = this.getBracketArg(key, c, sh);
            if isempty(fileName)
                throwCode ( ...
                    exception.ParseTime('Preparser:CTRL_MISSING_FILE_NAME', 'error'), ...
                    c0 ...
                    );
            end
            this.FileName = string(fileName);
            this.Body = CodeSegments(c, [ ], sh);
        end%


        function c = completeFileContents(this, c) %#ok<INUSL>
        end%
    end
end
