function varargout = userdatafield(this, field, varargin)
% userdatafield  Accessing or assigning fields in user data
%{
% ## Syntax for Accessing User Data Field ##
%
%     value = user datafield(obj, field)
%
%
% ## Syntax for Assigning User Data Field ##
%
%     obj = user datafield(obj, field, newValue)
%
%
% ## Input Arguments ##
%
% __`obj`__ [ Model | Series | VAR | SVAR | DFM ] -
% IRIS object subclassed from UserDataContainer.
%
% __`field`__ [ char | string ] - 
% Field of the user data struct; if user data is empty, the field can be
% created.
%
% __`newValue`__ [ * ] - 
% Data that will be stored in the `field` in the user data struct.
%
%
% ## Output Arguments ##
%
% __`value`__ [ * ] - 
% Value of the `field` in the user data struct that are currently
% assigned in the object `obj`.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

u = this.UserData;
if ~isempty(u) && ~isstruct(u)
    THIS_ERROR = { 'UserDataContainer:UserDataIsNotStruct'
                   'Cannot access or assign a user data field because the existing user data are not a struct' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

% Remove dots, equal signs, etc from the field name
field = regexp(field, '\w+', 'match', 'once');

if isempty(varargin)
    varargout{1} = accessUserData(this, field);
else
    % Assign user data field
    varargout{1} = assignUserData(this, field, varargin{:});
end

end%

