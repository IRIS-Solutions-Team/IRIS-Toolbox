function Flag = isequal(This,That)
% isequal  [Not a public function] Compare shared.UserDataContainer objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isa(This,'shared.UserDataContainer') && isa(That,'shared.UserDataContainer') ...
    && isequal(This.Comment,That.Comment) ...
    && isequal(This.UserData,That.UserData) ...
    && isequal(This.Caption,That.Caption);

end
