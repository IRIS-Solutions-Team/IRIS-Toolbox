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
            if ~isempty(p.StoreForCtrl) && ~isempty(strfind(fileName, '?'))
                fileName = For.substitute(fileName, p);
            end
            fileName = strtrim(fileName);
            if ~isempty(fileName)
                [c, ~, exportable, ctrlParameters] = Preparser.parse( fileName, [ ], ...
                                                                      'Assigned=', p.Assigned, ...
                                                                      'CloneString=', this.CloneString );
                add(p, ctrlParameters, exportable);
                % Reset file name back to caller file.
                exception.ParseTime.storeFileName(p.FileName);
            else
                c = '';
            end
        end%
    end
end
