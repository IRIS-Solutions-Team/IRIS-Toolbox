classdef Heading ...
    < rephrase.Element ...
    & rephrase.Terminus

    properties (Constant)
        Type = rephrase.Type.HEADING
    end


    methods
        function this = Heading(title, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = NaN;
        end%
    end
end 

