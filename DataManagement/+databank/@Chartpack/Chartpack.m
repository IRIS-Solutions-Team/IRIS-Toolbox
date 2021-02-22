classdef (CaseInsensitiveProperties=true) Chartpack < handle

    properties
        Charts (1, :) databank.chartpack.Chart = databank.chartpack.Chart.empty(1, 0)

        Range {validate.mustBeRange} = Inf
        PlotFunc {validate.mustBeFunc} = @plot
        Highlight {locallyValidateHighlight} = double.empty(1, 0)
        Transform = []
        NewLine = "//"
        ShowFormulas = false
        ShowTransform = false
        
        Round = Inf
        Expand (1, :) cell = cell.empty(1, 0)

        Tiles = @auto
        MaxTilesPerWindow = 40

        FigureSettings (1, :) cell = cell.empty(1, 0)
        AxesSettings (1, :) cell = cell.empty(1, 0)
        PlotSettings (1, :) cell = cell.empty(1, 0)
        TitleSettings (1, :) cell = cell.empty(1, 0)
    end


    methods
        function this = Chartpack(varargin)
            for i = 1 : 2 : numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end
        end%
    end


    methods
        varargout = add(varargin)
        varargout = draw(varargin)

        function this = lt(this, varargin)
            this = add(this, varargin{:});
        end%
    end


    methods (Access=protected)
        function tiles = resolveTiles(this)
            if isnumeric(this.Tiles)
                tiles = this.Tiles;
                if isscalar(tiles)
                    tiles = [tiles, tiles];
                end
                return
            end
            numCharts = numel(this.Charts);
            [numRows, numColumns] = visual.backend.optimizeSubplot(min(numCharts, this.MaxTilesPerWindow));
            tiles = [numRows, numColumns];
        end%
    end
end

%
% Local Validators
%

function locallyValidateHighlight(x)
    %(
    if isempty(x)
        return
    end
    if validate.properRange(x)
        return
    end
    if iscell(x) && all(cellfun(@validate.properRange, x))
        return
    end
    error("Input value must be empty, a proper range, or a cell array of proper ranges.");
    %) 
end%

