function varargout = comment(This,varargin)
% comment  Get or set user comments in an IRIS object.
%
% Syntax for getting user comments
% =================================
%
%     Cmt = comment(Obj)
%
% Syntax for assigning user comments
% ===================================
%
%     Obj = comment(Obj,Cmt)
%
% Input arguments
% ================
%
% * `Obj` [ model | tseries | VAR | SVAR | FAVAR | sstate ] -
% One of the IRIS objects.
%
% * `Cmt` [ char ] - User comment that will be attached to the object.
%
% Output arguments
% =================
%
% * `Cmt` [ char ] - User comment that are currently attached to the
% object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if ~isempty(varargin)
    Cmt = varargin{1};
    pp = inputParser( );
    pp.addRequired('Cmt',@ischar);
    pp.parse(Cmt);
end

%--------------------------------------------------------------------------

if isempty(varargin)
    varargout{1} = This.Comment;
else
    This.Comment = Cmt;
    varargout{1} = This;
end

end