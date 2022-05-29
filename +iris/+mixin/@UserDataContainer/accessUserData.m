function value = accessUserData(this, field)
% accessUserData  Access field in user data
%{
% Syntax
%--------------------------------------------------------------------------
%
%     value = accessUserData(obj, field)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`obj`__ [ Model | Series | VAR | SVAR | DFM ]
%
%>    An [IrisToolbox] object subclassed from UserDataContainer.
%
%
% __`field`__ [ string ]
%
%>    Field of the user data struct; if user data is empty, the field can
%>    be created.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`value`__ [ * ]  
%
%>    Current value of the requested field, `field`; if the field does not
%>    exist an error is raised.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

if ~isscalar(this.UserData) && ~isstruct(this.UserData)
   exception.error([
        "UserDataContainer:UserDataNotStruct"
        "Cannot access user data fields because the existing user data are not a scalar struct"
    ]);
end

if nargin<2
    value = this.UserData;
    return
end

field = iris.mixin.UserDataContainer.preprocessFieldName(field);

% Access user data field
if isstruct(this.UserData) && isfield(this.UserData, field)
    value = this.UserData.(field);
else
    throw(exception.Base([
        "UserDataContainer:FieldDoesNotExist"
        "This user data field does not exist: %s "
    ], 'error'), field);
end

end%

