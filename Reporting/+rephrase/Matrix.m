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
            if ~iscell(this.Content) 
                this.Content = num2cell(this.Content);
            end
            this.Content = this.Content(:, :);
            [numRows, numColumns] = size(this.Content);
            nested = cell(1, numRows);
            for i = 1 : numRows
                nested{i} = this.Content(i, :);
            end
            this.Content = nested;
            if isscalar(this.Settings.RowNames)
                this.Settings.RowNames = {this.Settings.RowNames};
            end
            if isscalar(this.Settings.ColumnNames)
                this.Settings.ColumnNames = {this.Settings.ColumnNames};
            end
        end%
    end
end 

