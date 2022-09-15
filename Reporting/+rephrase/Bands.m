
classdef Bands ...
    < rephrase.SettingsMixin ...
    & rephrase.DataMixin

    properties
        Type = string(rephrase.Type.BANDS)
        Title (1, 1) string
        Content struct
    end


    properties (Hidden)
        Lower Series
        Upper Series
        Relation (1, 1) string {ismember(Relation, ["relative", "absolute"])}
        Settings_ShowLegend (1, 1) logical = true
        Settings_Whitening (1, 1) double = 0
        Settings_Alpha (1, 1) double = 0.5
        Settings_LineWidth (1, 1) double = 0
        Settings_Fill = "tozerox"
    end


    methods
        function this = Bands(title, lower, upper, relation, varargin)
            this = this@rephrase.SettingsMixin();
            assignOwnSettings(this, varargin{:});
            this.Title = title;
            this.Lower = lower{:, 1};
            this.Upper = upper{:, 1};
            this.Relation = relation;
        end%


        function this = finalize(this, center, startDate, endDate)
            if this.Relation=="relative"
                this.Lower = center - this.Lower;
                this.Upper = center + this.Upper;
            end
            [lowerDates, lowerValues] = this.finalizeForChart(this.Lower, startDate, endDate);
            [upperDates, upperValues] = this.finalizeForChart(this.Upper, startDate, endDate);
            lowerValues = round(this, lowerValues);
            upperValues = round(this, upperValues);
            this.Content = struct();
            this.Content.Dates = [reshape(lowerDates, 1, []), fliplr(reshape(upperDates, 1, []))];
            this.Content.Values = [reshape(lowerValues, 1, []), fliplr(reshape(upperValues, 1, []))];

            populateSettingsStruct(this);
        end%
    end
end

