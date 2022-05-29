function this = assignUserData(this, varargin)
% assignUserData  Assign field in user data
%{
% ## Syntax ##
%
%     obj = assignUserData(obj, field, newValue)
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
% __`obj`__ [ * ] - 
% Object with its user data field newly created or assigned.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

if ~isempty(this.UserData) && ~isstruct(this.UserData)
    THIS_ERROR = { 'UserDataContainer:UserDataNotStruct'
                   'Cannot assign user data fields because the existing user data are not a struct' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

% Create struct if needed
if ~isstruct(this.UserData)
    this.UserData = struct( );
end

for i = 1 : 2 : numel(varargin)
    field = varargin{i};

    % Remove dots, equal signs, etc from the field name
    field = iris.mixin.UserDataContainer.preprocessFieldName(field);

    % Assign user data field
    this.UserData.(field) = varargin{i+1};
end

end%

