classdef countOptional < irisinp.count
    methods
        function this = countOptional(Default,varargin)
            this = this@irisinp.count(varargin{:});
            this.Omitted = Default;
        end
    end
end
