function report = reportMissingPeriodsAndPages(dates, inxMissing)
% reportMissingPeriodsAndPages  Prepare report of missing periods and pages
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

inxMissing = any(inxMissing, 1);
numPeriods = size(inxMissing, 2);
numPages = size(inxMissing);
report = cell.empty(1, 0);
for i = 1 : numPages
    if ~any(inxMissing(1, :, i))
        continue
    end
    missingDates = dates(inxMissing(1, :, i));
    [~, c] = DateWrapper.reportConsecutive(missingDates);
    report = [report, {i, sprintf('%s ', c{:})}];
end

end%

