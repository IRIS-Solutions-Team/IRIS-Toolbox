function flag = chkConsistency(this)
% chkConsistency  Check internal consistency of object properties
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

flag = chkConsistency@shared.GetterSetter(this) && ...
       chkConsistency@shared.UserDataContainer(this) && ...
       checkConsistency(this.Quantity);

end%

