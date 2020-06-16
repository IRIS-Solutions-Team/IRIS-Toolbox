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
            if isfield(this.Settings, "Highlight")
                for i=1:numel(this.Settings.Highlight)
                    if isfield(this.Settings.Highlight{i},"StartDate")
                        this.Settings.Highlight{i}.StartDate = DateWrapper.toIsoString(this.Settings.Highlight{i}.StartDate, "s");
                    end
                    if isfield(this.Settings.Highlight{i},"EndDate")
                        this.Settings.Highlight{i}.EndDate = DateWrapper.toIsoString(this.Settings.Highlight{i}.EndDate, "e");
                    end
                end
            end
        end%
    end
end 
