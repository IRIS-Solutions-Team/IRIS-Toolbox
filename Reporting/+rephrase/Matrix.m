classdef Matrix ...
    < rephrase.Terminal ...
    & rephrase.DataMixin

    properties % (Constant)
        Type = string(rephrase.Type.MATRIX)
    end


    properties (Hidden)
        Settings_CellClasses (1, :) cell = cell.empty(1, 0)
        Settings_NumDecimals (1, :) double = NaN
        Settings_RowNames (1, :) string = string.empty(1, 0)
        Settings_ColumnNames (1, :) string = string.empty(1, 0)
    end


    methods
        function this = Matrix(title, input, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            if iscell(input)
                input = local_prepareCellForJson(input);
            end
            this.Content = input;
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

