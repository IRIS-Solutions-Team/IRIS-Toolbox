
classdef (Abstract) Terminal ...
    < rephrase.Element

    methods
        function this = finalize(this, varargin)
            assignParentSettings(this);
            populateSettingsStruct(this);
        end%
    end
end

