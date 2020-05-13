function data = change(data, func, shifts, rows)
% change  Calculate change in time series values between periods
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

if isempty(data)
    return
end

if nargin<3
    shifts = -1;
end

if nargin<4
    rows = [ ];
end

if isempty(shifts) && isempty(rows)
    data = numeric.empty(data, 2);
    return
end

%--------------------------------------------------------------------------

if ~isempty(shifts)
    dataShifted = numeric.shift(data, shifts);
    data = repmat(data, 1, numel(shifts));
else
    inxValidRows = isfinite(rows);
    dataShifted = nan(size(data));
    dataShifted(inxValidRows, :) = data(rows(inxValidRows), :);
end

data = func(data, dataShifted);

end%

