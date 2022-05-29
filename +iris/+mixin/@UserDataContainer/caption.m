function varargout = caption(this, varargin)
% caption  Get or set user captions in an IRIS object
%
% Syntax for getting user captions
% =================================
%
%     newCaption = caption(obj)
%
% Syntax for assigning user captions
% ===================================
%
%     obj = caption(obj, newCaption)
%
% Input arguments
% ================
%
% * `obj` [ model | tseries | VAR | SVAR | FAVAR | sstate ] -
% One of the IRIS objects.
%
% * `newCaption` [ char ] - User caption that will be attached to the object.
%
% Output arguments
% =================
%
% * `newCaption` [ char ] - User caption that are currently attached to the
% object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

if ~isempty(varargin)
    newCaption = varargin{1};
    parser = extend.InputParser('UserDataContainer.caption');
    parser.addRequired('Object', @(x) isa(x, 'UserDataContainer'));
    parser.addRequired('NewCaption', @ischar);
    parser.parse(newCaption);
end

%--------------------------------------------------------------------------

if isempty(varargin)
    varargout{1} = this.Caption;
else
    this.Caption = newCaption;
    varargout{1} = this;
end

end%

