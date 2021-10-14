classdef Pager ...
    < rephrase.Element ...
    & rephrase.Container

    properties % (Constant)
        Type = rephrase.Type.PAGER
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            rephrase.Type.GRID
            rephrase.Type.TABLE
            rephrase.Type.CHART
            rephrase.Type.MATRIX
        ]
    end


    methods
        function this = Pager(title, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = cell.empty(1, 0);
        end%
    end
end 
