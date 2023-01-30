
classdef Bands ...
    < rephrase.SettingsMixin ...
    & rephrase.DataMixin

    properties
        Type = string(rephrase.Type.BANDS)
        Title (1, 1) string
        Content struct
    end


    properties (Hidden)
        Parent
        Lower Series
        Upper Series
        Relation (1, 1) string {ismember(Relation, ["relative", "absolute"])}
        Settings_ShowLegend (1, 1) logical = true
        Settings_Whitening (1, 1) double = 0
        Settings_Alpha (1, 1) double = 0.5
        Settings_LineWidth (1, 1) double = 0
        Settings_LineDash (1, 1) string = "solid"
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


        function this = finalize(this, center)
            if this.Relation=="relative"
                this.Lower = center - this.Lower;
                this.Upper = center + this.Upper;
            end
            lowerContent = this.finalizeSeriesData(this.Lower);
            upperContent = this.finalizeSeriesData(this.Upper);
            this.Content = struct();
            this.Content.Dates = [reshape(lowerContent.Dates, 1, []), fliplr(reshape(upperContent.Dates, 1, []))];
            this.Content.Values = [reshape(lowerContent.Values, 1, []), fliplr(reshape(upperContent.Values, 1, []))];
            populateSettingsStruct(this);
        end%
    end
end

