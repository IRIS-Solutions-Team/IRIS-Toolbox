function w = weekdayiso(d)
% weekdayiso  ISO 8601 day of the week number (Monday=1, etc.)
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

w = mod(fix(d)-3, 7) + 1;

end
