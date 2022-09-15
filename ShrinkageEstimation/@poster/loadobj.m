function This = loadobj(This)
% loadobj  [Not a public function] Prepare poster object for use in workspace and handle bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isstruct(This)
    This = poster(This);
end

end
