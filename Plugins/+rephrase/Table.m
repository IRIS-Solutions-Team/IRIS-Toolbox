classdef Table ...
    < rephrase.Element ...
    & rephrase.Container

    properties (Constant)
        Type = rephrase.Type.TABLE
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            rephrase.Type.SERIES
            rephrase.Type.DIFFSERIES
            rephrase.Type.HEADING
        ]
    end


    methods
        function this = Table(title, dates, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Settings.Dates = double(dates);
            this.Content = cell.empty(1, 0);
        end%


        function build(this, varargin)
            build@rephrase.Container(this, varargin{:});
            this.Settings.Dates = dater.toIsoString(this.Settings.Dates, "m");
        end%
    end
end 

