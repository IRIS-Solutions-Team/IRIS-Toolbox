function [this, trend] = bpass(this, band, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    pp.KeepUnmatched = true;
    pp.addRequired('InputSeries', @(x) isa(x, 'Series'));
    pp.addRequired('Band', @(x) isnumeric(x) && numel(x)==2);
    pp.addOptional('Range', Inf, @validate.range);
end
parse(pp, this, band, varargin{:});
range = double(pp.Results.Range);
unmatched = pp.UnmatchedInCell;

%--------------------------------------------------------------------------

if isempty(range) || isnan(this.Start) || isempty(this.Data)
    this = this.empty(this);
    trend = this;
    return
end

[inputData, startDate] = getDataFromTo(this, range);

% Run the band-pass filter
[filterData, trendData] = series.bpass( ...
    inputData, band, ...
    'StartDate', startDate, ...
    unmatched{:} ...
);

% Output data
this.Data = filterData;
this.Start = startDate;
this = trim(this);

% Time trend data
if nargout>1
    trend = fill(this, trendData);
    trend = trim(trend);
end

end%

