function P = regexppattern(This)
% regexppattern  [Not a public function] Regexp list of all replacement codes.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This)
    P = '';
    return
end

n = length(This);
P = dec2char(This,1);
for i = 2 : n
    P = [P,'|',dec2char(This,i)]; %#ok<AGROW>
end
P = [This.OpenChar,'(?:',P,')',This.CloseChar];

end
