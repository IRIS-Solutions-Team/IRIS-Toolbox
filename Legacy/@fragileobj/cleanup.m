function C = cleanup(C,This)
% cleanup  [Not a public function] Remove all replacement codes belonging
% to a given fragileobj from a string.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isnan(This.Offset) || isempty(This.Store)
    return
end

for i = 1 : length(This)
    ptn = [This.OpenChar,dec2char(This,i),This.CloseChar];
    C = strrep(C,ptn,'');
end

end
