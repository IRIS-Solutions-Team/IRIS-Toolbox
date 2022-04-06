function flag = checkConsistency(this)
% checkConsistency  Check internal consistency of object properties
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2021 IRIS Solutions Team

%--------------------------------------------------------------------------

flag = checkConsistency@iris.mixin.GetterSetter(this) && ...
       checkConsistency@iris.mixin.UserDataContainer(this) && ...
       checkConsistency(this.Quantity) && ...
       checkConsistency(this.Equation) && ...
       model.component.Pairing.checkConsistency(this.Pairing, this.Quantity, this.Equation);

end%

