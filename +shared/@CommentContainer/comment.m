function varargout = comment(this, varargin)
% comment  Inquire about or assign user comments in IRIS object
%{
% ## Syntax for Getting User Comments ##
%
%     currentComment = comment(obj)
%
%
% ## Syntax for Assigning User Comments ##
%
%     obj = comment(obj, newComment)
%
%
% ## Input Arguments ##
%
% **`obj`** [ model | tseries | VAR | SVAR | FAVAR | sstate ] -
% IRIS object subclassed from shared.CommentContainer.
%
% **`newComment`** [ char | string ] -
% New user comment that will be attached to the object.
%
%
% ## Output Arguments ##
%
% **`currentComment`** [ char ] -
% User comment that is currently attached to the object.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

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

end%

