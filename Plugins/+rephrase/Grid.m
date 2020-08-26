classdef Grid ...
    < rephrase.Element ...
    & rephrase.Container

    properties (Constant)
        Type = rephrase.Type.GRID
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            rephrase.Type.TABLE
            rephrase.Type.CHART
            rephrase.Type.MATRIX
        ]
    end


    methods
        function this = Grid(title, numRows, numColumns, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = cell.empty(1, 0);
            this.Settings.NumRows = numRows;
            this.Settings.NumColumns = numColumns;
        end%
    end
end 
