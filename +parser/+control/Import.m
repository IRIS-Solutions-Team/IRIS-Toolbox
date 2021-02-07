classdef Import < parser.control.ExternalFile
    methods
        function this = Import(varargin)
            if isempty(varargin)
                return
            end
            this.FileName = string(varargin{1});
        end%
        
        
        function c = writeFinal(this, p, varargin)
            import parser.Preparser
            import parser.control.For
            fileName = this.FileName;
            if ~isempty(p.StoreForCtrl) && contains(fileName, "?")
                fileName = For.substitute(fileName, p);
            end
            fileName = strip(fileName);
            if ~isempty(fileName)
                [c, ~, exportable, controls] = Preparser.parse(fileName, [ ], p);
                add(p, controls, exportable);

                % Reset file name back to caller file
                exception.ParseTime.storeFileName(p.FileName);
            else
                c = '';
            end
        end%
    end
end
