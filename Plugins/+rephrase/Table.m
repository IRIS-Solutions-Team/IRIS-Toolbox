classdef Table ...
    < rephrase.Container

    properties % (Constant)
        Type = rephrase.Type.TABLE
    end


    properties (Hidden)
        Settings_Dates
        Settings_DateFormat (1, 1) string = "YYYY:MM"
        Settings_NumDecimals (1, 1) double = 2
        Settings_RowTitles (1, 1) struct = struct()
        Settings_ShowRows (1, 1) struct = struct('Baseline', true, 'Alternative', true, 'Diff', true)
        Settings_FirstCell (1, 1) string = ""
        Settings_ShowUnits (1, :) logical = logical.empty(1, 0)
        Settings_UnitsHeading (1, 1) string = "Units"
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


        function finalize(this)
            finalize@rephrase.Container(this);
            if isempty(this.Settings_ShowUnits)
                showUnits = false;
                for i = 1 : numel(this.Content)
                    try
                        showUnits = showUnits || strlength(this.Content{i}.Settings_Units)>0;
                    end 
                    if showUnits
                        break
                    end
                end
                this.Settings.ShowUnits = showUnits;
            end
        end%


        function this = set.Settings_Dates(this, x)
            if isnumeric(x)
                x = dater.toIsoString(reshape(double(x), 1, []), "mid");
            end
            this.Settings_Dates = textual.stringify(x);
        end%
    end
end 

