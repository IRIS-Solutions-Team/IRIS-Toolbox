classdef CommentContainer
    properties
        % Comment  User comment attached to the object
        Comment (1, :) string = ""
    end


    methods
        function this = CommentContainer(varargin)
            if isempty(varargin)
                return
            end
            if isa(varargin{1}, 'iris.mixin.CommentContainer')
                this = varargin{1};
            else
                this.Comment = string(varargin{1});
            end
        end%
    end


    methods
        varargout = assignComment(varargin)
        varargout = accessComment(varargin)
        varargout = comment(varargin)
    end


    methods (Access=protected, Hidden)
        function implementDisp(this, varargin)
            dispIndent = string(iris.get("DispIndent"));
            comment = """" + this.Comment + """";
            fprintf(dispIndent);
            if isempty(comment)
                fprintf("Comment: empty\n")
            elseif isscalar(comment)
                fprintf("Comment: %s\n", comment);
            else
                fprintf("Comment: [%s]\n", join(comment, ", "));
            end
        end%
    end
end

