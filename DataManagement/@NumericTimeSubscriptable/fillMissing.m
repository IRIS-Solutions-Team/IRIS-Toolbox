% >=R2019b
%(
function [this, datesMissing] = fillMissing(this, range, method)

arguments
    this NumericTimeSubscriptable
    range { validate.mustBeRange(range) }
end

arguments (Repeating)
    method
end
%)
% >=R2019b


% <=R2019a
%{
function [this, datesMissing] = fillMissing(this, range, varargin)

%( Input parser
if isempty(this.Data)
    return
end

persistent pp
if isempty(pp)
    pp = extend.InputParser("NumericTimeSubscriptable/fillMissing");
    addRequired(pp, "inputSeries", @(x) isa(x, "NumericTimeSubscriptable"));
    addRequired(pp, "range", @validate.range);
    addRequired(pp, "method", @mustBeNonempty);
end
%)
opt = parse(pp, this, range, varargin);
method = pp.Results.method;
%}
% <=R2019a


% Return immediately if the range is empty

if isempty(range)
    datesMissing = Dater.empty(1, 0);
    return
end


% Resolve dates depending on the input time series

[startDate, endDate, inxRange] = locallyResolveDates(this, range);
data = getDataFromTo(this, startDate, endDate);


% Look up missing observations within the input range

inxMissing = this.MissingTest(data) & inxRange;
if nargout>=2
    if any(inxMissing)
        datesMissing = dater.plus(startDate, find(inxMissing)-1);
        datesMissing = Dater(datesMissing);
    else
        datesMissing = Dater.empty(0, 1);
    end
end

if nnz(inxMissing)==0
    return
end

if numel(method)==1 && isa(method{1}, "NumericTimeSubscriptable")
    data = locallyReplaceData(data, startDate, endDate, inxMissing, method{1});
else
    data = numeric.fillMissing(data, inxMissing, method{:});
end

this = fill(this, data, startDate);

end%

%
% Local Functions
%

function [startDate, endDate, inxRange] = locallyResolveDates(this, range)
    range = double(range);
    startMissing = range(1);
    endMissing = range(end);
    startDate = double(this.Start);
    endDate = this.EndAsNumeric;
    if isinf(startMissing)
        startMissing = startDate;
    elseif isnan(startDate)
        startDate = startMissing;
    elseif startMissing<startDate
        startDate = startMissing;
    end
    if isinf(endMissing)
        endMissing = endDate;
    elseif isnan(endDate)
        endDate = endMissing;
    elseif endMissing>endDate
        endDate = endMissing;
    end
    numPeriods = round(endDate - startDate + 1);
    inxRange = false(numPeriods, 1);
    posStartMissing = round(startMissing - startDate + 1);
    posEndMissing = round(endMissing - startDate + 1);
    inxRange(posStartMissing:posEndMissing) = true;
end%


function data = locallyReplaceData(data, startDate, endDate, inxMissing, method)
    replaceWith = getDataFromTo(method, startDate, endDate);
    sizeData = size(data);
    sizeReplaceWith = size(replaceWith);
    if prod(sizeData(2:end))>1 && prod(sizeReplaceWith(2:end))==1
        replaceWith = repmat(replaceWith, [1, sizeData(2:end)]);
    end
    if ~isequal(size(replaceWith), sizeData)
        exception.error([
            "Inconsistent dimensions of the input time series "
            "and the replacement time series."
        ]);
    end
    data(inxMissing) = replaceWith(inxMissing);
end%

