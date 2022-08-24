
function [this, tt, ts] = trend(this, varargin)

if ~isempty(varargin) && validate.range(varargin{1})
    range = double(varargin{1});
    varargin(1) = [ ];
else
    range = Inf;
end

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    pp.KeepUnmatched = true;
    pp.addRequired('InputSeries', @(x) isa(x, 'Series'));
    pp.addOptional('Range', Inf, @validate.range);
end
parse(pp, this, varargin{:});
trendOpt = pp.UnmatchedInCell;

    [data, ~, ~, range] = getDataFromTo(this, range);

    if isempty(range)
        this = this.empty(this);
        return
    end
    startDate = range(1);

    sizeData = size(data);
    ndimsData = ndims(data);
    data = data(:, :);

    [data, tt, ts] = series.trend(data, 'StartDate', startDate, trendOpt{:});

    if ndimsData>2
        data = reshape(data, sizeData);
        tt = reshape(tt, sizeData);
        ts = reshape(ts, sizeData);
    end

    % Output data
    this = replace(this, data, range(1));
    this = trim(this);
    if nargout>1
        tt = replace(this, tt, range(1));
        if nargout>2
            ts = replace(this, ts, range(1));
        end
    end

end%

