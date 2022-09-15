
classdef (Abstract) SettingsMixin ...
    < matlab.mixin.Copyable

    properties (Constant, Hidden)
        SETTINGS_PREFIX = "Settings_"
        EXCLUDE_SETTINS = ["Pass", ]
    end


    properties (Hidden)
        SettingNames (1, :) string = string.empty(1, 0)
        SettingsAssigned (1, :) string = string.empty(1, 0)
        SettingsInherited (1, :) string = string.empty(1, 0)
    end


    properties (Hidden)
        Settings_Class (1, 1) string = ""
        Settings_Pass (1, :) cell = cell.empty(1, 0)
        Settings_ShowTitle (1, 1) logical = true
    end


    properties
        Settings (1, 1) struct = struct()
    end


    methods
        function this = SettingsMixin(varargin)
            this.SettingNames = getSettingNames(this);
        end%


        function shortNames = getSettingNames(this)
            mc = metaclass(this);
            longNames = textual.stringify({mc.PropertyList.Name});
            longNames = longNames(startsWith(longNames, this.SETTINGS_PREFIX));
            shortNames = extractAfter(longNames, this.SETTINGS_PREFIX);
        end%


        function assignOwnSettings(this, varargin)
            inxAssigned = false(size(this.SettingNames));
            for i = 1 : 2 : numel(varargin)
                [flag, shortName] = isSetting(this, varargin{i});
                if flag
                    this.SettingsAssigned(1, end+1) = shortName;
                    this.(this.SETTINGS_PREFIX+shortName) = varargin{i+1};
                else
                    this.(varargin(i)) = varargin{i+1};
                end
            end
            this.SettingsAssigned = sort(unique(this.SettingsAssigned));
        end%


        function populateSettingsStruct(this)
            shortNames = this.SettingNames;
            shortNames = setdiff(shortNames, this.EXCLUDE_SETTINS);
            longNames = this.SETTINGS_PREFIX+shortNames;
            for i = 1 : numel(longNames)
                this.Settings.(shortNames(i)) = this.(longNames(i));
            end
        end%


        function assignParentSettings(this)
            parent = this.Parent;
            if isempty(parent) || ~isa(parent, 'rephrase.Element')
                return
            end
            for i = 1 : 2 : numel(parent.Settings_Pass)
                [flag, shortName] = isSetting(this, parent.Settings_Pass{i});
                if ~flag
                    continue
                end
                if beenAssigned(this, shortName)
                    continue
                end
                this.(this.SETTINGS_PREFIX+shortName) = parent.Settings_Pass{i+1};
                this.SettingsInherited = union(this.SettingsInherited, shortName, 'stable');
            end
            this.Settings_Pass = [parent.Settings_Pass, this.Settings_Pass];
        end%


        function flag = beenAssigned(this, shortName)
            flag = any(strcmpi(shortName, this.SettingsAssigned));
        end%


        function [flag, shortName] = isSetting(this, shortName)
            shortName = string(shortName);
            if startsWith(shortName, "display", "ignoreCase", true)
                shortName = "show" + extractAfter(shortName, strlength("display"));
            end
            inx = strcmpi(shortName, this.SettingNames);
            flag = any(inx);
            shortName = this.SettingNames(inx);
        end%
    end

end

