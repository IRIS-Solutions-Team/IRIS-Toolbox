classdef Pagebreak ...
    < rephrase.Element

    properties (Constant)
        Type = rephrase.Type.PAGEBREAK
    end


    methods
        function this = Pagebreak(varargin)
            this = this@rephrase.Element(varargin{:});
            this.Content = NaN;
        end%
    end
end 
