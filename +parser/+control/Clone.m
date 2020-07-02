classdef Clone < parser.control.ExternalFile
    properties
        CloneString = ''
    end


    methods
        function this = Clone(inBrackets)
            if nargin==0
                return
            end
            temp = split(inBrackets, ',');
            this.FileName = strtrim(temp{1});
            if numel(temp)>=2
                this.CloneString = strtrim(temp{2});
            end
        end%
        
        
        function c = writeFinal(this, p, varargin)
            import parser.Preparser;
            import parser.control.For;
            fileName = this.FileName;
            cloneString = this.CloneString;
            if ~isempty(p.StoreForCtrl) 
                if ~isempty(strfind(fileName, '?'))
                    fileName = For.substitute(fileName, p);
                end
                if ~isempty(strfind(cloneString, '?'))
                    cloneString = For.substitute(cloneString, p);
                end
            end
            fileName = strtrim(fileName);
            cloneString = strtrim(cloneString);
            if ~isempty(fileName)
                [c, ~, exportable, controls] = Preparser.parse(fileName, [ ], p);
                add(p, controls, exportable);
                % 
                % Reset file name back to caller file
                %
                exception.ParseTime.storeFileName(p.FileName);
            else
                c = '';
            end
        end%
    end
end
