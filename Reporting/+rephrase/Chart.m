classdef Chart ...
    < rephrase.Element

    properties (Constant)
        Type = rephrase.Type.CHART
    end


    methods
        function this = Chart(varargin)
            this = this@rephrase.Element(varargin{:});
            this.Content = cell.empty(1, 0);
        end%
    end
end 
