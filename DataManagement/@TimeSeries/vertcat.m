function this = vertcat(varargin)

startEnd = cell(size(varargin));
ixNad = false(size(varargin));
for i = 1 : nargin
    startEnd{i} = varargin{i}.Start;
    ixNad(i) = isnad(startEnd{i});
end

if all(ixNad)
    this = varargin{1};
    return
end

varargin(ixNad) = [ ];
startEnd(ixNad) = [ ];
assert( ...
    validate(startEnd{:}), ...
    'TimeSeries:vertcast', ...
    'Inputs to vertical concatenation of TimeSeries objects must have the same date frequency.' ...
);

data = cell(size(varargin));
[newRange, data{:}] = getDataFromAll('longRange', varargin{:});
newStart = getFirst(newRange);
sizeData = cellfun(@size, data, 'UniformOutput', false);
sizeData1 = sizeData{1};
assert( ...
    all( cellfun(@(x) isequal(x, sizeData1), sizeData(2:end)) ), ...
    'TimeSeries:vertcat', ...
    'Incompatible size of TimeSeries objects vertically concatenated.' ...
);

this = varargin{1};
missingTest = this.MissingTest;
sizeData1 = size(data{1});
for i = 2 : numel(varargin)
    ixMissing = missingTest(data{i});
    data{1}(~ixMissing) = data{i}(~ixMissing);
end

this.Start = newStart;
this.Data = data{1};
this = trim(this);

end
