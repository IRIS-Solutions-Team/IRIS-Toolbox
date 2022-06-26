classdef Section ...
    < rephrase.Container

    properties % (Constant)
        Type = rephrase.Type.SECTION
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            rephrase.Type.GRID
            rephrase.Type.TABLE
            rephrase.Type.CHART
            rephrase.Type.SERIESCHART
            rephrase.Type.CURVECHART
            rephrase.Type.MATRIX
            rephrase.Type.PAGER
            rephrase.Type.SECTION
        ]
    end


    methods
        function this = Section(title, varargin)
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
        end%
    end
end 
