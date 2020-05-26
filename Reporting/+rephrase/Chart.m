classdef Chart ...
    < rephrase.Element ...
    & rephrase.Container

    properties (Constant)
        Type = rephrase.Type.CHART
        CanBeParentOf = [rephrase.Type.SERIES]
    end


    methods
        function this = Chart(varargin)
            startDate = varargin{2};
            endDate = varargin{3};
            varargin(2:3) = [ ];
            this = this@rephrase.Element(varargin{:});
            this.Content = cell.empty(1, 0);
            this.Settings.StartDate = DateWrapper.toIsoString(startDate, "s");
            this.Settings.EndDate = DateWrapper.toIsoString(endDate, "e");
        end%
    end
end 
