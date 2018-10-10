function [this, newRange] = resize(this, range)
% resize  Clip time series range
%
% __Syntax__
%
%     X = resize(X, Range)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input time series whose date range will be clipped.
%
% * `Range` [ numeric ] - New date range to which the input tseries object
% will be resized; the range can be specified as a `[startDate, endDate]`
% vector where `-Inf` and `Inf` can be used for the dates.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Output tseries object with its date range clipped to
% `Range`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

isDateWrapper = isa(range, 'DateWrapper');

if isempty(range) || isnan(this.Start)
    this = this.empty(this);
    if isDateWrapper
        newRange = DateWrapper.empty(1, 0);
    else
        newRange = double.empty(1, 0);
    end
    return
end

if isa(range, 'DateWrapper')
    rangeFirst = getFirst(range);
    rangeLast = getLast(range);
else
    rangeFirst = range(1);
    rangeLast = range(end);
end

[this, newStart, newEnd] = clip(this, rangeFirst, rangeLast);
newRange = newStart : newEnd;

end%

