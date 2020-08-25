classdef Chart ...
    < rephrase.Element ...
    & rephrase.Container

    properties (Constant)
        Type = rephrase.Type.CHART
    end


    properties (Constant, Hidden)
        PossibleChildren = [ 
            rephrase.Type.SERIES
        ]
    end


    methods
        function this = Chart(title, startDate, endDate, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = cell.empty(1, 0);
            this.Settings.StartDate = double(startDate);
            this.Settings.EndDate = double(endDate);
        end%


        function build(this, varargin)
            build@rephrase.Container(this, varargin{:});
            this.Settings.StartDate = dater.toIsoString(this.Settings.StartDate, "m");
            this.Settings.EndDate = dater.toIsoString(this.Settings.EndDate, "m");
        end%
    end
end 
