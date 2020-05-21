classdef Series ...
    < rephrase.Element

    properties (Constant)
        Type = rephrase.Type.SERIES
    end


    methods
        function this = Series(varargin)
            this = this@rephrase.Element(varargin{:});
        end%
    end
end 
