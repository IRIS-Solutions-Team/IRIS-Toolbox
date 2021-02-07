classdef Clone < parser.control.ExternalFile
    properties
        CloneString = ''
    end


    methods
        function this = Clone(inBrackets)
            if nargin==0
                return
            end
            temp = string(split(inBrackets, ","));
            this.FileName = strip(temp(1));
            if numel(temp)>=2
                this.CloneString = strip(temp(2));
            end
        end%
        
        
        function c = writeFinal(this, p, varargin)
            import parser.Preparser;
            import parser.control.For;
            fileName = string(this.FileName);
            cloneString = this.CloneString;
            if ~isempty(p.StoreForCtrl) 
                if contains(fileName, "?")
                    fileName = For.substitute(fileName, p);
                end
                if contains(cloneString, "?")
                    cloneString = For.substitute(cloneString, p);
                end
            end
            fileName = strip(fileName);
            cloneString = strip(cloneString);
            if ~isempty(fileName) && any(strlength(fileName)>0)
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
