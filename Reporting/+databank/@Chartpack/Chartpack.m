classdef (CaseInsensitiveProperties=true) Chartpack < handle

    properties
        Charts (1, :) databank.chartpack.Chart = databank.chartpack.Chart.empty(1, 0)

        Range = Inf
        PlotFunc {validate.mustBeFunc} = @plot
        Highlight {locallyValidateHighlight} = double.empty(1, 0)
        Extra = []
        Transform {validate.mustBeScalarOrEmpty} = []
        NewLine (1, 1) string = "//"
        CaptionFromComment (1, 1) logical = false
        ShowFormulas (1, 1) logical = false
        ShowTransform (1, 1) logical = false
        ShowFigure (1, 1) double = Inf

        Round (1, 1) double = Inf
        Expansion (1, :) cell = cell.empty(1, 0)

        Tiles = @auto
        MaxTilesPerWindow (1, 1) double {mustBeInteger, mustBePositive} = 40

        FigureSettings (1, :) cell = cell.empty(1, 0)
        AxesSettings (1, :) cell = cell.empty(1, 0)
        PlotSettings (1, :) cell = cell.empty(1, 0)
        TitleSettings (1, :) cell = cell.empty(1, 0)
        SubtitleSettings (1, :) cell = cell.empty(1, 0)
        Interpreter (1, 1) string {mustBeMember(Interpreter, ["none", "tex" "latex"])} = "none"

        FigureExtras (1, :) cell = cell.empty(1, 0)
        AxesExtras (1, :) cell = cell.empty(1, 0)
        PlotExtras (1, :) cell = cell.empty(1, 0)
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
        varargout = clear(varargin)
        varargout = draw(varargin)


        function this = lt(this, varargin)
            this = add(this, varargin{:});
        end%


        function this = le(this, varargin)
            this = clear(this);
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
            maxNumCharts = getMaxNumCharts(this.Charts);
            [numRows, numColumns] = visual.backend.optimizeSubplot(min(maxNumCharts, this.MaxTilesPerWindow));
            tiles = [numRows, numColumns];
        end%


        function runFigureExtras(this, figureHandle)
            %(
            for i = 1 : numel(this.FigureExtras)
                this.FigureExtras{i}(figureHandle);
            end
            %)
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

