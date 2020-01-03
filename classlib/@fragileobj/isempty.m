function Flag = isempty(This)
% isempty  [Not a public function] Is-empty test for fragileobj class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isnan(This.Offset) || isempty(This.Store);

end