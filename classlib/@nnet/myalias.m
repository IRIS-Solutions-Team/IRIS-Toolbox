function Query = myalias(Query)
% myalias  [Not a public function] Aliasing get and set queries for shared.GetterSetter subclasses.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

Query = regexprep(Query,'=','') ;

end