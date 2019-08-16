classdef CommentContainer
    properties
        % Comment  User comment attached to the object
        Comment = ''
    end


    methods
        function this = CommentContainer(varargin)
            if isempty(varargin)
                return
            end
            if isa(varargin{1}, 'shared.CommentContainer')
                this = varargin{1};
            else
                this.Comment = varargin{1};
            end
        end%
    end


    methods
        varargout = comment(varargin)
    end


    methods (Access=protected, Hidden)
        function implementDisp(this, varargin)
            dispIndent = iris.get('DispIndent');
            fprintf(dispIndent);
            fprintf('Comment: %s\n', this.Comment);
        end%
    end
end
