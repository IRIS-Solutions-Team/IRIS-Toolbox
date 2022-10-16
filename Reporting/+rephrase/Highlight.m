
classdef Highlight ...
    < rephrase.SettingsMixin ...
    & rephrase.ColorMixin

    properties
        Type = string(rephrase.Type.HIGHLIGHT)
        StartDate (1, 1) 
        EndDate (1, 1)
    end


    properties (Hidden)
        Settings_Shape (1, 1) struct = struct()
        Settings_Line (1, 1) struct = struct()
    end


    methods
        function this = Highlight(startDate, endDate, varargin)
            this = this@rephrase.SettingsMixin();
            assignOwnSettings(this, varargin{:});
            populateSettingsStruct(this);
            this.StartDate = startDate; %local_assignDate(startDate, "start");
            this.EndDate = endDate; % local_assignDate(endDate, "end");
        end%


%         function this = set.StartDate(this, value)
%             if isequal(value, -Inf)
%                 this.StartDate = value;
%                 return
%             end
%             if isstring(value) || ischar(value)
%                 this.StartDate = string(value);
%                 return
%             end
%             this.StartDate = dater.toIsoString(value, "start");
%         end%
% 
% 
%         function this = set.EndDate(this, value)
%             if isequal(value, Inf)
%                 this.EndDate = value;
%                 return
%             end
%             if isstring(value) || ischar(value)
%                 this.EndDate = string(value);
%                 return
%             end
%             this.EndDate = dater.toIsoString(value, "end");
%         end%


        function this = set.Settings_Shape(this, x)
            this.Settings_Shape = rephrase.lowerFields(x);
        end%


        function [startDate, endDate] = resolveHighlightDates(this, parent)
            startDate = parent.resolveStartDate(this.StartDate);
            endDate = parent.resolveEndDate(this.EndDate);
        end%
    end

end

