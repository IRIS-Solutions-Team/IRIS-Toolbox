function varargout = userdatafield(This,Field,varargin)
% userdatafield  Getting and setting fields in struct userdata.
%
% Syntax for getting userdata field
% ==================================
%
%     X = userdatafield(Obj,Field)
%
% Syntax for assigning userdata field
% ====================================
%
%     Obj = userdatafield(Obj,Field,X)
%
% Input arguments
% ================
%
% * `Obj` [ model | tseries | VAR | SVAR | FAVAR | sstate ] -
% One of the IRIS objects.
%
% * `Field` [ char ] - Field of the userdata struct; if userdata is empty,
% the field can be created.
%
% * `X` [ ... ] - Data that will be stored in field `Field` of the userdata
% struct.
%
% Output arguments
% =================
%
% * `X` [ ... ] - Field `Field` of the userdata struct that are currently
% attached to the object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Remove dots, equal signs, etc.
Field = regexp(Field,'\w+','match','once');

if isempty(varargin)
    % Get user data field.
    u = This.UserData;
    if isa(u,'struct') && isfield(u,Field)
        varargout{1} = u.(Field);
    else
        utils.error('userdata', ...
            ['User data is not a struct, ', ...
            'or the field ''%s'' does not exist.'], ...
            Field);
    end
else
    % Set user data field.
    u = This.UserData;
    if isempty(u) || isstruct(u)
        This.UserData.(Field) = varargin{1};
    else
        utils.error('userdata', ...
            'User data is non-empty and not a struct .');
    end
    varargout{1} = This;
end

end