
classdef Grid ...
    < rephrase.Container

    properties % (Constant)
        Type = string(rephrase.Type.GRID)
    end


    properties (Hidden)
        Settings_NumRows (1, 1) double = Inf
        Settings_NumColumns (1, 1) double
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            string(rephrase.Type.TABLE)
            string(rephrase.Type.CHART)
            string(rephrase.Type.SERIESCHART)
            string(rephrase.Type.CURVECHART)
            string(rephrase.Type.MATRIX)
        ]
    end


    methods
        function this = Grid(title, numRows, numColumns, varargin)
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
            % this.Settings_NumRows = double(numRows);
            this.Settings_NumColumns = double(numColumns);
        end%


        function finalize(this, varargin)
            finalize@rephrase.Container(this, varargin{:});
        end%
    end
end 
