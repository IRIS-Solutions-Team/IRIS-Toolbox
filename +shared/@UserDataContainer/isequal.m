function flag = isequal(this, that)
% isequal  Compare shared.UserDataContainer objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

flag = isa(this,'shared.UserDataContainer') && isa(that,'shared.UserDataContainer') ...
     && isequal(this.UserData,that.UserData) ...
     && isequal(this.Caption,that.Caption);

end%

