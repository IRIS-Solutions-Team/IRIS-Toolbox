classdef Table ...
    < rephrase.Container

    properties % (Constant)
        Type = rephrase.Type.TABLE
    end


    properties (Hidden)
        Settings_Dates (1, :) string = string.empty(1, 0)
        Settings_DateFormat (1, 1) string = "YYYY:MM"
        Settings_NumDecimals (1, 1) double = 2
        Settings_RowTitles (1, 1) struct = struct()
        Settings_ShowRows (1, 1) struct = struct('Baseline', true, 'Alternative', true, 'Diff', true)
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            rephrase.Type.SERIES
            rephrase.Type.DIFFSERIES
            rephrase.Type.HEADING
        ]
    end


    methods
        function this = Table(title, dates, varargin)
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
            this.Settings_Dates = dates;
        end%


        function this = set.Settings_Dates(this, x)
            if isnumeric(x)
                x = dater.toIsoString(reshape(double(x), 1, []), "mid");
            end
            this.Settings_Dates = textual.stringify(x);
        end%
    end
end 

