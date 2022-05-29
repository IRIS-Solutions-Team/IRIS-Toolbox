function [This,NewPos,NewChar] = copytoend(This,Pos)
% copytoend  [Not a public function] Copy given entry to end of storage.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

This.Store{end+1} = This.Store{Pos};
This.Open{end+1} = This.Open{Pos};
This.Close{end+1} = This.Close{Pos};

NewPos = length(This.Store);
NewChar = charcode(This);

end
