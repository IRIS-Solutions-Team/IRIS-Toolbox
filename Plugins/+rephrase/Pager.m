
classdef Pager ...
    < rephrase.Container

    properties % (Constant)
        Type = rephrase.Type.PAGER
    end


    properties (Hidden)
        Settings_StartPage = 0
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            rephrase.Type.GRID
            rephrase.Type.TABLE
            rephrase.Type.CHART
            rephrase.Type.SERIESCHART
            rephrase.Type.CURVECHART
            rephrase.Type.MATRIX
        ]
    end


    methods
        function this = Pager(title, varargin)
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
        end%
    end
end 

