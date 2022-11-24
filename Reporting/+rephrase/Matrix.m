classdef Matrix ...
    < rephrase.Terminal ...
    & rephrase.DataMixin

    properties % (Constant)
        Type = string(rephrase.Type.MATRIX)
    end


    properties (Hidden)
        Settings_CellClasses (1, :) cell = cell.empty(1, 0)
        Settings_NumDecimals (1, :) double = NaN
        Settings_RowNames (1, :) = string.empty(1, 0)
        Settings_ColumnNames (1, :) = string.empty(1, 0)
    end


    methods
        function this = Matrix(title, input, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Content = input;
        end%


        function this = finalize(this, varargin)
            finalize@rephrase.Terminal(this);
            if isnumeric(this.Content) && size(this.Content, 2)==1
                this.Content = num2cell(this.Content);
            end
            if iscell(this.Content)
                this.Content = local_prepareCellForJson(this.Content);
            elseif size(this.Content, 1)==1
                this.Content = {this.Content};
            end
            if isscalar(this.Settings.RowNames)
                this.Settings.RowNames = {this.Settings.RowNames};
            end
            if isscalar(this.Settings.ColumnNames)
                this.Settings.ColumnNames = {this.Settings.ColumnNames};
            end
        end%
    end
end 


function nested = local_prepareCellForJson(array)
    % Matlab incorrectly encodes N-dimensional cell arrays as 1-dimensional lists
    % Force Matlab to encode 2-D cell arrays as cell array of cell arrays
    %(
    array = array(:, :);
    [numRows, numColumns] = size(array);
    nested = cell(1, numRows);
    for i = 1 : numRows
        nested{i} = array(i, :);
    end
    %)
end%

