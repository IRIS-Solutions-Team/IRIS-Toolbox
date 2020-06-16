classdef Grid ...
    < rephrase.Element ...
    & rephrase.Container

    properties (Constant)
        Type = rephrase.Type.GRID
        CanBeParentOf = [rephrase.Type.TABLE, rephrase.Type.CHART]
    end


    properties (Constant, Hidden)
        DEFAULT_GRID_SETTINGS = databank.merge( ...
            @replace, rephrase.Element.DEFAULT_ELEMENT_SETTINGS ...
            , struct("NumRows", 1, "NumColumns", 1) ...
        );
    end


    methods
        function this = Grid(varargin)
            this = this@rephrase.Element(varargin{[1, 3:end]});
            this.Content = cell.empty(1, 0);
            this.Settings.NumRows = varargin{2}(1);
            this.Settings.NumColumns = varargin{2}(2);
        end%
    end
end 
