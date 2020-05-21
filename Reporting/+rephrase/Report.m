classdef Report ...
    < rephrase.Element

    properties (Constant)
        Type = rephrase.Type.REPORT
    end


    methods
        function this = Report(varargin)
            this = this@rephrase.Element(varargin{:});
            this.Content = cell.empty(1, 0);
        end%
    end
end 
