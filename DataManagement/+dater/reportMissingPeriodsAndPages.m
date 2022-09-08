% reportMissingPeriodsAndPages  Prepare report of missing periods and pages
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function report = reportMissingPeriodsAndPages(dates, inxMissing, pre, post)

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
    [~, s] = dater.reportConsecutive(missingDates);
    report__ = {i, join(s, " ")};
    if ~isempty(pre)
        report__ = [{pre}, report__];
    end
    if ~isempty(post)
        report__ = [report__, {post}];
    end
    report = [report, report__];
end

end%

