function data = roc(data, shifts, power)
% roc  Gross rate of change
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

if nargin<2
    shifts = -1;
end

if isempty(shifts)
    data = numeric.empty(data, 2);
    return
end

%--------------------------------------------------------------------------

numShifts = numel(shifts);
data = repmat(data, 1, numShifts) ./ numeric.shift(data, shifts);
if nargin>=3 && power~=1
    data = data .^ power;
end

end%

