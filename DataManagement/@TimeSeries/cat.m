function this = cat(dim, varargin)

if numel(varargin)==1
    this = varargin{1};
    return
end

ixTimeSeries = cellfun('isclass', varargin, 'TimeSeries');
[range, varargin{ixTimeSeries}] = getDataFromAll('longRange', varargin{ixTimeSeries});
first = getFirst(range);
nRow = numel(range);

if nRow>1
    for i = find(~ixTimeSeries)
        if size(varargin{i}, 1)==1
            varargin{i} = repmat(varargin{i}, nRow, 1);
        end
    end
end

newData = cat(dim, varargin{:});

assert( ...
    (isnumeric(newData) || iscell(newData)) && size(newData, 1)==nRow, ...
    'TimeSeries:cat', ...
    'Concetenation of TimeSeries objects must produce numeric or cell array and preserve size in 1st dimension'...
);

this = TimeSeries( );
this.Start = first;
this.Data = newData;
this.ColumnNames = "";

end
