function this = setData(this, subs, rhs)

time = subs{1};

if isa(rhs, 'TimeSeries')
    rhs = getData(rhs, time);
end

sizeData = size(this.Data);
ndimsData = numel(sizeData);
missingValue = this.MissingValue;

switch subsCase(this, time)
case 'Date_:'
    rowPositionsToAssign = ':';
    numRowsToAssign = sizeData(1);
case {'Date_[]', 'NaD_[]', 'Date_NaD', 'NaD_NaD', 'NaD_:', 'Empty_[]', 'Empty_:', 'Empty_NaD'}
    rowPositionsToAssign = int64.empty(0, 1);
    numRowsToAssign = 0;
case 'NaD_Date'
    [rowPositionsToAssign, this.Start] = positionOf(time);
    maxPosition = max(rowPositionsToAssign);
    numRowsToAssign = numel(rowPositionsToAssign);
    this.Data = repmat(missingValue, [maxPosition, sizeData(2:end)]);
case 'Empty_Date'
    assert( ...
        validate(this.Start, time), ...
        'TimeSeries:setData', ...
        'Invalid date frequency in subscripted assignment to TimeSeries.' ...
    );
    this.Start = getMinMax(time);
    [rowPositionsToAssign, this.Start] = positionOf(time);
    this.Data = repmat(missingValue, [max(rowPositionsToAssign), sizeData(2:end)]);
    numRowsToAssign = numel(rowPositionsToAssign);
case 'Date_Date'
    assert( ...
        validate(this.Start, time), ...
        'TimeSeries:setData', ...
        'Invalid date frequency in subscripted assignment to TimeSeries.' ...
    );
    rowPositionsToAssign = positionOf(time, this.Start);
    minPos = min(rowPositionsToAssign);
    maxPos = max(rowPositionsToAssign);
    if minPos<1
        this.Start = addTo(this.Start, minPos-1);
        insert = repmat(missingValue, [1-minPos, sizeData(2:end)]);
        this.Data = [insert; this.Data];
        rowPositionsToAssign = rowPositionsToAssign - minPos + 1;
    end
    if maxPos>sizeData(1)
        insert = repmat(missingValue, [maxPos-sizeData(1), sizeData(2:end)]);
        this.Data = [this.Data; insert];
    end
    numRowsToAssign = numel(rowPositionsToAssign);
otherwise
    error( ...
        'TimeSeries:setData', ...
        'Invalid subscripted assignment to TimeSeries.' ...
    );
end

if isempty(rhs)
    rhs = missingValue;
end
sizeRhs = size(rhs);
if sizeRhs(1)==1 && numRowsToAssign>1 && isequal(sizeRhs(2:end), sizeData(2:end))
    rhs = rhs(ones(1, numRowsToAssign), :);
end

s = struct( );
s.type = '()';
if numel(subs)==1
    s.subs = cell(1, ndimsData);
    s.subs{1} = rowPositionsToAssign;
    s.subs(2:end) = {':'};
else
    s.subs = [ {rowPositionsToAssign}, subs(2:end) ];
end

this.Data = builtin('subsasgn', this.Data, s, rhs);

newSizeData = size(this.Data);
assert( ...
    prod(newSizeData(2:end))<=prod(sizeData(2:end)), ...
    'TimeSeries:setData:SizeOrDimensionExpansion', ...
    'Cannot grow TimeSeries data array along 2nd or higher dimension.' ...
);

end
