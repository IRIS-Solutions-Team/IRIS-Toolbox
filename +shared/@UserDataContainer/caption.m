function varargout = caption(This,varargin)
% caption  Get or set user captions in an IRIS object.
%
% Syntax for getting user captions
% =================================
%
%     Cpt = caption(Obj)
%
% Syntax for assigning user captions
% ===================================
%
%     Obj = comment(Obj,Cpt)
%
% Input arguments
% ================
%
% * `Obj` [ model | tseries | VAR | SVAR | FAVAR | sstate ] -
% One of the IRIS objects.
%
% * `Cpt` [ char ] - User caption that will be attached to the object.
%
% Output arguments
% =================
%
% * `Cpt` [ char ] - User caption that are currently attached to the
% object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ~isempty(varargin)
    Cpt = varargin{1};
    pp = inputParser( );
    pp.addRequired('Cpt',@ischar);
    pp.parse(Cpt);
end

%--------------------------------------------------------------------------

if isempty(varargin)
    varargout{1} = This.Caption;
else
    This.Caption = Cpt;
    varargout{1} = This;
end

end