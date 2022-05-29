% change  Calculate change in time series values between periods
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function data = change(data, func, shift)

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

numPeriods = size(data, 1);
rows = (1 : numPeriods) + shift;
inxValidRows = rows>=1 & rows<=numPeriods;
dataShifted = nan(size(data));
dataShifted(inxValidRows, :) = data(rows(inxValidRows), :);

%
% Keep the value unchanged if shift==0; this is used in diff(x, "tty")
%
inxKeep = shift==0;
if numel(inxKeep)==1 && numPeriods~=1
    inxKeep = repmat(inxKeep, 1, numPeriods);
end
if any(inxKeep)
    keepData = data(inxKeep, :);
end


%==========================================================================
data = func(data, dataShifted);
%==========================================================================


if any(inxKeep)
    data(inxKeep, :) = keepData;
end

end%

