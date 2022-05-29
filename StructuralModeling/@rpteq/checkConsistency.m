function flag = checkConsistency(this)
% checkConsistency  Check internal consistency of object properties
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

flag = checkConsistency@iris.mixin.GetterSetter(this) ...
       && checkConsistency@iris.mixin.UserDataContainer(this);

end%

