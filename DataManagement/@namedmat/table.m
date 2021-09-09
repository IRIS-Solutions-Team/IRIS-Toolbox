function outputTable = table(this, varargin)

data = double(this);

if ~isempty(varargin)
    data = data(:, :, varargin{:});
end

outputTable = array2table( ...
    data ...
    , "VariableNames", this.ColumnNames ...
    , "RowNames", this.RowNames ...
);

end%

