classdef Grid ...
    < rephrase.Element ...
    & rephrase.Container

    properties % (Constant)
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


        function build(this, varargin)
            build@rephrase.Container(this, varargin{:});
            if isempty(this.Settings.NumRows)
                numChildren = numel(this.Content);
                this.Settings.NumRows = ceil(numChildren / this.Settings.NumColumns);
            end
        end%
    end
end 
