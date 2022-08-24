
classdef Highlight ...
    < rephrase.SettingsMixin ...
    & rephrase.ColorMixin

    properties
        Type = string(rephrase.Type.HIGHLIGHT)
    end


    properties
        StartDate (1, 1) 
        EndDate (1, 1)
    end


    properties (Hidden)
        Settings_Shape (1, 1) struct = struct()
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


        function this = set.Settings_Shape(this, x)
            this.Settings_Shape = rephrase.lowerFields(x);
        end%
    end

end

