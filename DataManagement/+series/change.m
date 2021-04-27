function data = change(data, func, shift)
% change  Calculate change in time series values between periods
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

if isempty(data)
    return
end

if nargin<3
    shift = -1;
end

if isempty(shift) 
    data = numeric.empty(data, 2);
    return
end

%--------------------------------------------------------------------------

numPeriods = size(data, 1);
rows = (1 : numPeriods) + shift;
inxValidRows = rows>=1 & rows<=numPeriods;
dataShifted = nan(size(data));
dataShifted(inxValidRows, :) = data(rows(inxValidRows), :);

% /////////////////////////////////////////////////////////////////////////
data = func(data, dataShifted);
% /////////////////////////////////////////////////////////////////////////

end%

