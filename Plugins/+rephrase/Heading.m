
classdef Heading ...
    < rephrase.Terminal ...

    properties % (Constant)
        Type = rephrase.Type.HEADING
    end


    methods
        function this = Heading(title, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Content = NaN;
        end%
    end
end 

