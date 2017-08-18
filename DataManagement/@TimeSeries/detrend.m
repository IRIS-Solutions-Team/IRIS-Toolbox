function this = detrend(this, varargin)

assert( ...
    isnumeric(this.Data), ...
    'TimeSeries:detrend', ...
    'Cannot detrend other than numeric TimeSeries.' ...
);

if isnad(this.Start)
    return
end

range = Inf;
if nargin>1
    if isa(varargin{1}, 'Date') || isequal(varargin{1}, Inf)
        range = varargin{1};
        varargin(1) = [ ];
    end
end

from = min(range);
to = max(range);

missingValue = this.MissingValue;
missingTest = this.MissingTest;

sizeData = size(this.Data);

[newData, newStart] = getDataFromRange(this, from, to);
ixMissing = missingTest(newData);
nCol = prod(sizeData(2:end));
for iCol = 1 : nCol
    temp = newData(:, iCol);
    newData(:, iCol) = missingValue;
    first = find(~ixMissing(:, iCol), 1);
    last = find(~ixMissing(:, iCol), 1, 'last');
    if ~isempty(first) && ~isempty(last)
        newData(first:last, iCol) = detrend(temp(first:last), varargin{:});
    end
end

this.Data = newData;
this.Start = newStart;
this = trim(this);

end
