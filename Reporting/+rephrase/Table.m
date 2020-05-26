classdef Table ...
    < rephrase.Element ...
    & rephrase.Container

    properties (Constant)
        Type = rephrase.Type.TABLE
        CanBeParentOf = [rephrase.Type.SERIES, rephrase.Type.HEADING]
    end


    methods
        function this = Table(varargin)
            dates = varargin{2};
            varargin(2) = [ ];
            this = this@rephrase.Element(varargin{:});
            this.Settings.Dates = DateWrapper.toIsoString(dates, "m");
            this.Content = cell.empty(1, 0);
        end%
    end
end 
