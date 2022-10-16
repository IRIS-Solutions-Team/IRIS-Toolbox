classdef Table ...
    < rephrase.Container

    properties % (Constant)
        Type = string(rephrase.Type.TABLE)
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
            string(rephrase.Type.SERIES)
            string(rephrase.Type.DIFFSERIES)
            string(rephrase.Type.HEADING)
        ]
    end


    methods
        function this = Table(title, dates, varargin)
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
            this.Settings_Dates = dates;
        end%


        function finalize(this, varargin)
            finalize@rephrase.Container(this, varargin{:});
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
            this.Settings.Dates = textual.stringify(dater.toIsoString(this.Settings_Dates, "mid"));
            % this.Settings.Dates = double.empty(1, 0);
            % for i = 1 : getNumSegments(this)
                % dates = getSegmentDates(this, i);
                % if isnumeric(dates)
                    % this.Settings.Dates = [this.Settings.Dates, textual.stringify(dater.toIsoString(dates, "mid"))];
                % end
            % end
        end%


        function this = set.Settings_Dates(this, dates)
%             if ~iscell(dates)
%                 dates = {dates};
%             end
            this.Settings_Dates = dates;
        end%


        function out = getNumSegments(this)
            out = numel(this.Settings_Dates);
        end%


        function out = getSegmentDates(this, i)
            out = this.Settings_Dates{i};
        end%
    end
end 

