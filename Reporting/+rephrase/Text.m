classdef Text ...
    < rephrase.Element

    properties (Constant)
        Type = rephrase.Type.TEXT
    end


    methods
        function this = Text(varargin)
            this = this@rephrase.Element(varargin{:});
        end%
    end
end 
