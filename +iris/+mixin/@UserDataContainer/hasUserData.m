% hasUserData  True if user data field exists
%{
% ## Syntax ##
%
%     flag = hasUserData(obj, field)
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
% -Copyright (c) 2007-2022 IRIS Solutions Team

function flag = hasUserData(this, field)

flag = isstruct(this.UserData) && isscalar(this.UserData) && isfield(this.UserData, field);

end%

