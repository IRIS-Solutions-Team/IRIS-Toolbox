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
% IRIS object subclassed from iris.mixin.CommentContainer.
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

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function varargout = comment(this, varargin)

if nargin==1
    varargout{1} = accessComment(this);
elseif nargin==2
    varargout{1} = assignComment(this, varargin{1});
end

end%

