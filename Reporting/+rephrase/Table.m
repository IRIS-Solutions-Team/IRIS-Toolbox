classdef Table ...
    < rephrase.Element

    properties (Constant)
        Type = rephrase.Type.TABLE
    end


    methods
        function this = Table(varargin)
            this = this@rephrase.Element(varargin{:});
            this.Content = cell.empty(1, 0);
        end%
    end
end 
