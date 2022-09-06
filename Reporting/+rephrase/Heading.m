
classdef Heading ...
    < rephrase.Terminal ...

    properties % (Constant)
        Type = string(rephrase.Type.HEADING)
    end


    methods
        function this = Heading(title, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Content = NaN;
        end%
    end
end 

