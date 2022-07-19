
classdef Grid ...
    < rephrase.Container

    properties % (Constant)
        Type = rephrase.Type.GRID
    end


    properties (Hidden)
        Settings_NumRows (1, 1) double = Inf
        Settings_NumColumns (1, 1) double
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            rephrase.Type.TABLE
            rephrase.Type.CHART
            rephrase.Type.SERIESCHART
            rephrase.Type.CURVECHART
            rephrase.Type.MATRIX
        ]
    end


    methods
        function this = Grid(title, numRows, numColumns, varargin)
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
            % this.Settings_NumRows = double(numRows);
            this.Settings_NumColumns = double(numColumns);
        end%


        function finalize(this)
            finalize@rephrase.Container(this);
        end%
    end
end 
