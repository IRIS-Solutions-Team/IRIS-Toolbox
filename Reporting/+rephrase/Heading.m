classdef Heading ...
    < rephrase.Element

    properties (Constant)
        Type = rephrase.Type.HEADING
    end


    methods
        function this = Heading(varargin)
            this = this@rephrase.Element(varargin{:});
            this.Content = NaN;
        end%
    end
end 
