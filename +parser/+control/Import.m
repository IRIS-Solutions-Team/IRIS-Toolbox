classdef Import < parser.control.ExternalFile
    methods
        function this = Import(varargin)
            if isempty(varargin)
                return
            end
            this.FileName = varargin{1};
        end
        
        
        
        
        function c = writeFinal(this, p, varargin)
            import parser.Preparser;
            import parser.control.For;
            fileName = this.FileName;
            if ~isempty(p.StoreForCtrl) && ~isempty(strfind(fileName, '?'))
                fileName = For.substitute(fileName, p);
            end
            fileName = strtrim(fileName);
            if ~isempty(fileName)
                [c, ~, exportable, ctrlParameters] = ...
                    Preparser.parse(fileName, [ ], p.Assigned);
                add(p, ctrlParameters, exportable);
                % Reset file name back to caller file.
                exception.ParseTime.storeFileName(p.FileName);
            else
                c = '';
            end
        end
    end
end
