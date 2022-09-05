
classdef Counter < handle
    properties
        Id = 0
    end

    methods
        function out = generateId(this)
            out = string(this.Id);
            this.Id = this.Id + 1;
        end%
    end
end

