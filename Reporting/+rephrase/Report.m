classdef Report ...
    < rephrase.Element ...
    & rephrase.Container

    properties (Constant)
        Type = rephrase.Type.REPORT
        CanBeParentOf = [rephrase.Type.GRID, rephrase.Type.TABLE, rephrase.Type.CHART]
    end


    methods
        function this = Report(varargin)
            this = this@rephrase.Element(varargin{:});
            this.Content = cell.empty(1, 0);
        end%
    end
end 
