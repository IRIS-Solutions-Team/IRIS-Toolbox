function varargout = userdata(This,varargin)
% userdata  Get or set user data in an IRIS object.
%
% Syntax for getting user data
% =============================
%
%     X = userdata(Obj)
%
% Syntax for assigning user data
% ===============================
%
%     OBJ = userdata(Obj,X)
%
% Input arguments
% ================
%
% * `Obj` [ model | tseries | VAR | SVAR | FAVAR ] - One of the IRIS
% objects with access to user data functions.
%
% * `X` [ ... ] - Any kind of data that will be attached to, and stored
% within, the object `OBJ`.
%
% Output arguments
% =================
%
% * `X` [ ... ] - User data that are currently attached to the
% object.
%
% * `Obj` [ model | tseries | VAR | SVAR | FAVAR ] - The object with its
% user data updated.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(varargin)
    varargout{1} = This.UserData;
else
    This.UserData = varargin{1};
    varargout{1} = This;
end

end
