function [YXE, inxBaseRangeColumns, extendedRange, maxLag, maxLead] = getPlainData(this, inputDatabank, range)
% getPlainData  Get matrix of time series for LHS and RHS names
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

range = double(range);
startDate = range(1);
endDate = range(end);
maxLag = min(0, this.MaxLag);
maxLead = max(0, this.MaxLead);
extendedStartDate = startDate + maxLag;
extendedEndDate = endDate + maxLead;
extendedRange = (round(100*extendedStartDate) : 100 : round(100*extendedEndDate))/100; 

requiredNames = this.ExplanatoryNamesInDatabank;
optionalNames = this.ErrorNamesInDatabank;
allNames = [requiredNames, optionalNames];
databankInfo = checkInputDatabank(this, inputDatabank, extendedRange, requiredNames, optionalNames);
YXE = requestData(this, databankInfo, inputDatabank, extendedRange, allNames);

numExtendedPeriods = numel(extendedRange);
inxBaseRangeColumns = true(1, numExtendedPeriods);
inxBaseRangeColumns(1:abs(maxLag)) = false;
inxBaseRangeColumns = fliplr(inxBaseRangeColumns);
inxBaseRangeColumns(1:abs(maxLead)) = false;
inxBaseRangeColumns = fliplr(inxBaseRangeColumns);

end%

