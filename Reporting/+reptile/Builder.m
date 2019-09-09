classdef Builder < handle
    properties
        Report
        Figure
        Axes
        Series
    end


    methods
        function this = Builder( )
            this.Report = reptile.Report( );
            this.Figure = reptile.Null( );
            this.Axes = reptile.Null( );
            this.Series = reptile.Null( );
        end%
    end
end

