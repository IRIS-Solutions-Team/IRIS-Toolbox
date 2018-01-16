function data = pct(data, shifts, power)
% pct  Percent rate of change in numeric data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2017 IRIS Solutions Team

if nargin<2
    shifts = -1;
end

if nargin<3
    power = 1;
end

if isempty(shifts)
    data = numeric.empty(data, 2);
    return
end

%--------------------------------------------------------------------------

numShifts = numel(shifts);
data = repmat(data, 1, numShifts) ./ numeric.shift(data, shifts);
if power~=1
    data = data .^ power;
end
data = 100*(data - 1);

end
