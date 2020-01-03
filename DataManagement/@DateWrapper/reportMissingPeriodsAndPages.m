function report = reportMissingPeriodsAndPages(dates, inxMissing, pre, post)
% reportMissingPeriodsAndPages  Prepare report of missing periods and pages
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

if nargin<3
    pre = [ ];
end

if nargin<4
    post = [ ];
end

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
    report__ = {i, sprintf('%s ', c{:})};
    if ~isempty(pre)
        report__ = [{pre}, report__];
    end
    if ~isempty(post)
        report__ = [report__, {post}];
    end
    report = [report, report__];
end

end%

