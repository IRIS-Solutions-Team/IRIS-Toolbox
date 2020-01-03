function flag = checkConsistency(this)
% checkConsistency  Check internal consistency of object properties
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

flag = checkConsistency@shared.GetterSetter(this) ...
       && checkConsistency@shared.UserDataContainer(this);

end%

