classdef Section ...
    < rephrase.Container

    properties % (Constant)
        Type = string(rephrase.Type.SECTION)
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            string(rephrase.Type.CHART)
            string(rephrase.Type.CURVECHART)
            string(rephrase.Type.GRID)
            string(rephrase.Type.MATRIX)
            string(rephrase.Type.PAGER)
            string(rephrase.Type.SECTION)
            string(rephrase.Type.SERIESCHART)
            string(rephrase.Type.TABLE)
        ]
    end


    methods
        function this = Section(title, varargin)
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
        end%
    end
end 
