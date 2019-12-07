function outputTable = table(this, varargin)

data = double(this);
if nargin>=2
    data = data(:, :, varargin{:});
end
sizeData = size(data);
ref = num2cell(sizeData);
ref{2} = ones(1, sizeData(2));
temp = mat2cell(data, ref{:});
outputTable = table(temp{:}, 'VariableNames', this.ColumnNames, 'RowNames', this.RowNames);

end%
