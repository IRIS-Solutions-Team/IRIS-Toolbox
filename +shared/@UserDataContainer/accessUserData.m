function value = accessUserData(this, field)
% accessUserData  Access field in user data
%{
% ## Syntax ##
%
%     value = accessUserData(obj, field)
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
%
% ## Output Arguments ##
%
% __`value`__ [ * ] - 
% Current value of the requested field, `field`; if the field does not
% exist an error is raised.
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

%--------------------------------------------------------------------------

if ~isempty(this.UserData) && ~isstruct(this.UserData)
    THIS_ERROR = { 'UserDataContainer:UserDataNotStruct'
                   'Cannot access user data fields because the existing user data are not a struct' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

field = shared.UserDataContainer.preprocessFieldName(field);

% Access user data field
if isstruct(this.UserData) && isfield(this.UserData, field)
    value = this.UserData.(field);
else
    THIS_ERROR = { 'UserDataContainer:FieldDoesNotExist'
                   'This user data field does not exist: %s ' };
    throw(exception.Base(THIS_ERROR, 'error'), field);
end

end%

