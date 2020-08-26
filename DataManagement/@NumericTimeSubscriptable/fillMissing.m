% fillMissing  Fill missing time series observations
%{
% Syntax
%--------------------------------------------------------------------------
%
%     outputSeries = function(inputSeries, range, method)
%     outputSeries = function(inputSeries, range, method, specs)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`inputSeries`__ [ Series ]
%
%>    Input time series whose missing observations (lying within the
%>    `range`) will be filled with values determined by the `method`.
%
%
% __`range`__ [ DateWrapper | `Inf` ]
%
%>    Date range within which missing observations will be looked up in the
%>    `inputSeries` and filled with values determined by the `method`.
%
%
% __`method`__ [ string ]
%
%>    String specifying the method to obtain missing observations; the
%>    `method` can be any of the methods valid in the built-in
%>    `fillmissing()` function (see `help fillmissing`) or one of the
%>    regression methods provided by IrisT: `"regressConstant"`,
%>    `"regressTrend"` or `"regressLogTrend"` for a regression on a
%>    constant, a regression on a constant and a linear time trend, and
%>    a log-regression on a constant and a time trend, respectively.
%
%
% __`specs`__ [ * ]
%
%>    Some of the methods in the built-in `fillmissing()` function require
%>    addition specification (see `help fillmissing`).
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`outputSeries`__ [ ]
%
%>    Output time series whose missing observations found within the
%>    `range` have been filled with values determined by the `method`.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function [this, datesMissing] = fillMissing(this, range, varargin)

if isempty(this.Data)
    return
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('NumericTimeSubscriptable.fillMissing');
    addRequired(pp, 'inputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    addRequired(pp, 'range', @DateWrapper.validateRangeInput);
    addRequired(pp, 'method', @(x) ~isempty(x));
end
%)
opt = parse(pp, this, range, varargin);

%-------------------------------------------------------------------------- 

[startDate, endDate, inxRange] = locallyResolveDates(this, range);
data = getDataFromTo(this, startDate, endDate);

inxMissing = this.MissingTest(data) & inxRange;
if nargout>=2
    if any(inxMissing)
        datesMissing = dater.plus(startDate, find(inxMissing)-1);
        datesMissing = DateWrapper(datesMissing);
    else
        datesMissing = DateWrapper.empty(0, 1);
    end
end

if ~any(inxMissing(:))
    return
end

data = numeric.fillMissing(data, inxMissing, varargin{:});
this = fill(this, data, startDate);

end%

%
% Local Functions
%

function [startDate, endDate, inxRange] = locallyResolveDates(this, range)
    range = double(range);
    startMissing = range(1);
    endMissing = range(end);
    startDate = this.StartAsNumeric;
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

