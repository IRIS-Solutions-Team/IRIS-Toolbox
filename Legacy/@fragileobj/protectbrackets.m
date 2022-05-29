function [C,This] = protectbrackets(C,This)
% protectbrackets  [Not a public function] Replace top-level round and
% square brackets with replacement codes.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

while true
    % Find the first opening round or square bracket.
    open = find(C == '(' | C == '[',1);
    if isempty(open)
        break
    end
    % Find the matching closing bracket.
    close = textfun.matchbrk(C,open);
    % Store the content.
    This.Store{end+1} = C(open+1:close-1);
    This.Open{end+1} = C(open);
    This.Close{end+1} = C(close);
    % Replace the brackets with the current replacement charcode.
    C = [C(1:open-1),charcode(This),C(close+1:end)];
end

end
