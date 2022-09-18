
classdef (CaseInsensitiveProperties=true) Chartpack ...
    < matlab.mixin.Copyable

    properties
        Charts string = string.empty(1, 0)

        Range = Inf
        PlotFunc {validate.mustBeFunc} = @plot
        Transform {validate.mustBeScalarOrEmpty} = []
        NewLine (1, 1) string = "//"
        CaptionFromComment = []
        Autocaption (1, 1) logical = false
        ShowFormulas (1, 1) logical = false
        ShowTransform (1, 1) logical = false
        ShowFigure (1, 1) double = Inf
        Round (1, 1) double = Inf
        FigureTitle (1, :) string = string.empty(1, 0)

        Expansion (1, :) cell = cell.empty(1, 0)

        Grid (1, 2) logical = [true, true]
        Highlight {local_validateHighlight} = double.empty(1, 0)
        XLine = cell.empty(1, 0)
        YLine = cell.empty(1, 0)
        ClickToExpand (1, 1) logical = true

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


        function this = plus(this, varargin)
            this = add(this, varargin{:});
        end%


        function this = le(this, varargin)
            this = clear(this);
            this = add(this, varargin{:});
        end%


        function this = set.XLine(this, x)
            if ~iscell(x)
                x = {x};
            end
            this.XLine = x;
        end%


        function this = set.YLine(this, x)
            if ~iscell(x)
                x = {x};
            end
            this.YLine = x;
        end%


        function this = set.CaptionFromComment(this, x)
            this.Autocaption = x;
            this.CaptionFromComment = x;
        end%


        function this = set.Grid(this, x)
            if isscalar(x)
                this.Grid = [x, x];
            elseif numel(x)==2
                this.Grid = reshape(x, 1, []);
            end
        end%
    end


    methods (Access=protected)
        function tiles = resolveTiles(this, chartObjects)
            maxNumCharts = getMaxNumCharts(chartObjects);
            if isnumeric(this.Tiles) && ~any(isinf(this.Tiles))
                tiles = this.Tiles;
                if isscalar(tiles)
                    tiles = [tiles, tiles];
                end
                return
            end
            if isnumeric(this.Tiles) && numel(this.Tiles)==2 && isinf(this.Tiles(1))
                numColumns = this.Tiles(2);
                numRows = ceil(maxNumCharts/numColumns);
                tiles = [numRows, numColumns];
                return
            end
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
% Local validators
%

function local_validateHighlight(x)
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

