function flag = existsUserData(this, field)
% existsUserData  True if user data field exists
%{
% ## Syntax ##
%
%     flag = existsUserData(obj, field)
%
%
% ## Input Arguments ##
%
% __`obj`__ [ Model | Series | VAR | SVAR | DFM ] -
% IRIS object subclassed from UserDataContainer.
%
% __`field`__ [ char | string ] - 
% Field of the user data struct.
%
%
% ## Output Arguments ##
%
% __`flag`__ [ true | false ] - 
% True if the `field` exists in the user data struct.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if ~isempty(this.UserData) && ~isstruct(this.UserData)
    THIS_ERROR = { 'UserDataContainer:UserDataNotStruct'
                   'Cannot verify user data fields because the existing user data are not a struct' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

flag = isstruct(this.UserData) && isfield(this.UserData, field);

end%

