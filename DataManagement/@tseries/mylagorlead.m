function [This,S,Shift] = mylagorlead(This,S)
% mylagorlead  [Not a public function] Shift time series by a lag or lead.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(S) >= 1 ...
        && strcmp(S(1).type,'{}') ...
        && length(S(1).subs) == 1 ...
        && isintscalar(S(1).subs{1}) ...
        && isfinite(S(1).subs{1})
    
    Shift = S(1).subs{1};
    This.start = This.start - Shift;
    S(1) = [ ];
else
    Shift = 0;
end

end
