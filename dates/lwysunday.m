function L = lwysunday(Year)
% lwysunday  [Not a public function] Matlab serial date number for Sunday
% in the last week of the year.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

f = fwymonday(Year+1);
L = f - 1;

end
