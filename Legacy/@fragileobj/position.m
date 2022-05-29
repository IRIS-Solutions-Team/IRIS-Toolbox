function Pos = position(This,C)
% position  [Not a public function] Position of replacement string in the storage.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------


Pos = round(char2dec(This,C) - This.Offset);

if Pos < 1 || Pos > length(This.Store)
    utils.error('fragileobj:position', ...
        'Replacement code not found in the fragileobj object.');
end

end
