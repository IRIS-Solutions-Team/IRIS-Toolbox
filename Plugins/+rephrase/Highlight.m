
classdef Highlight ...
    < rephrase.ColorMixin ...
    & rephrase.SettingsMixin

    properties
        StartDate (1, 1) 
        EndDate (1, 1)
    end


    methods
        function this = Highlight(startDate, endDate, varargin)
            this = this@rephrase.SettingsMixin();
            this.StartDate = startDate;
            this.EndDate = endDate;
            assignOwnSettings(this, varargin{:});
            populateSettingsStruct(this);
        end%


        function this = set.StartDate(this, value)
            if isequal(value, -Inf)
                this.StartDate = value;
                return
            end
            if isstring(value) || ischar(value)
                this.StartDate = string(value);
                return
            end
            this.StartDate = dater.toIsoString(value);
        end%


        function this = set.EndDate(this, value)
            if isequal(value, Inf)
                this.EndDate = value;
                return
            end
            if isstring(value) || ischar(value)
                this.EndDate = string(value);
                return
            end
            this.EndDate = dater.toIsoString(value);
        end%
    end

end

