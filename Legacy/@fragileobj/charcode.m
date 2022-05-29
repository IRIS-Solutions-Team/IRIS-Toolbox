function C = charcode(This)
% charcode  [Not a public function] Get replacement code for last entry in storage.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = [This.OpenChar,dec2char(This,length(This)),This.CloseChar];

end
