classdef Wrapper ...
    < rephrase.Element ...
    & rephrase.Container

    methods
        function this = Wrapper(varargin)
            this = this@rephrase.Element(varargin{:});
        end%
    end
end

