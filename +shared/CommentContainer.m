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
        function varargout = comment(this, varargin)
        % comment  Get or set user comments in IRIS object
        %
        % __Syntax for Getting User Comments__
        %
        %     c = comment(obj)
        %
        %
        % __Syntax for Assigning User Comments__
        %
        %     obj = comment(obj, newComment)
        %
        %
        % __Input Arguments__
        %
        % * `obj` [ model | tseries | VAR | SVAR | FAVAR | sstate ] -
        % IRIS object subclassed from shared.CommentContainer.
        %
        % * `newComment` [ char | string ] - New user comment that will be
        % attached to the object.
        %
        %
        % __Output Arguments__
        %
        % * `c` [ char ] - User comment that is currently attached to the
        % object.
        %
        %
        % __Description__
        %
        %
        % __Example__
        %

        % -IRIS Macroeconomic Modeling Toolbox
        % -Copyright (c) 2007-2019 IRIS Solutions Team

        if ~isempty(varargin)
            newComment = varargin{1};
            parser = inputParser( );
            parser.addRequired('NewComment', @ischar);
            parser.parse(newComment);
        end

        %--------------------------------------------------------------------------

        if isempty(varargin)
            varargout{1} = this.Comment;
        else
            this.Comment = newComment;
            varargout{1} = this;
        end

        end

        function disp(this, varargin)
            fprintf('\tComment: %s\n', this.Comment);
            if isempty(varargin)
                textual.looseLine( );
            end
        end%
    end
end
