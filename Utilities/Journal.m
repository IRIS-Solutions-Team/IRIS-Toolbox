classdef Journal ...
    < handle

    properties
        Prefix (1, 1) string = ""
        FileId = []
        Level = 0
    end


    properties (Dependent)
        IsActive
    end


    methods
        function this = Journal(fileId, prefix)
            if nargin==0 || isempty(fileId) || isequal(fileId, false)
                return
            end
            if isequal(fileId, @screen) || isequal(fileId, 1) || isequal(fileId, true)
                fileId = 1;
            end
            if isstring(fileId) || ischar(fileId)
                fileId = string(fileId);
                f = fopen(fileId, "w+t");
                fclose(f);
            end
            this.FileId = fileId;
            if nargin<=1
                return
            end
            this.Prefix = prefix;
        end%


        function write(this, message)
            if isempty(this.FileId)
                return
            end
            if this.Level>0
                indent = string(repmat(' ', 1, 4*this.Level));
                message = indent + message;
            end
            if strlength(this.Prefix)>0
                message = this.Prefix + ": " + message;
            end
            if isstring(this.FileId)
                f = fopen(this.FileId, "at");
            else
                f = this.FileId;
            end
            fprintf(f, "%s\n", message);
            if isstring(this.FileId);
                fclose(f);
            end
        end%


        function indent(this, message)
            if isempty(this.FileId)
                return
            end
            if nargin>=2
                write(this, message);
            end
            this.Level = this.Level + 1;
        end%


        function deindent(this, message)
            if isempty(this.FileId)
                return
            end
            if nargin>=2
                write(this, message);
            end
            this.Level = max(0, this.Level - 1);
        end%


        function value = get.IsActive(this)
            value = ~isempty(this.FileId);
        end%
    end
end

