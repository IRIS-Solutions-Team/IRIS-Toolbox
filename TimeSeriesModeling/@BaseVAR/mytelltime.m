function [Range,NPer] = mytelltime(Time)
% mytelltime  [Not a public function] Tell if Time is Range or NPer.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(Time) == 1 && round(Time) == Time && Time > 0
    Range = 1 : Time;
else
    Range = Time(1) : Time(end);
end
NPer = length(Range);

end
