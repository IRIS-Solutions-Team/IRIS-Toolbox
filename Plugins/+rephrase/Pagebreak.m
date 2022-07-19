classdef Pagebreak ...
    < rephrase.Terminal

    properties % (Constant)
        Type = rephrase.Type.PAGEBREAK
    end


    methods
        function this = Pagebreak(varargin)
            this = this@rephrase.Terminal(varargin{:});
            this.Content = NaN;
        end%
    end
end 

