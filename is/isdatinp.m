function Flag = isdatinp(X)
% isdatinp  [Not a public function] True for date vector or text inputs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isnumeric(X) || isequal(X,@all) ...
    || ...
    ( ischar(X) && ~isempty(X) && any(isstrprop(X,'alpha')) ...
    && any(isstrprop(X,'digit')) && ~any(X=='=') );

end
