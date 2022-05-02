%{

# databank.Chartpack

{== Create a new Chartpack object for plotting databank fields ==}


## Syntax

    ch = databank.Chartpack()


## Output Arguments

__`ch`__ [ databank.Chartpack ]
>
> New empty databank.Chartpack object
>

## Customizable properties

After creating a new Chartpack object, set the following properties to
customize the way the charts are produced and styled: 


### Customize visual aspects of individual charts

__`PlotFunc=@plot`__ [ `@plot` ]
>
>  Plot function used to create each of the charts.
>

__`Highlight=[]`__ [ Dater | cell | empty ]
>
> Date range, or a cell array of date ranges, that will be highlighted in
> each chart.
>

### Customize data plotted

__`Range=Inf`__ [ Dater | `Inf` ]
>
> Date range or horizontal axis range on which the charts will be created.
> `Range=Inf` means each chart will encompass the range necessary to
> accommodate the entire time series plotted.
>

__`Round=Inf`__ [ numeric ]
>
> Round the data to this number of decimal places before plotting them.
>

__`Transform=[]`__ [ function | empty ]
>
> Function that will be applied to each data input before it gets plotted,
> except input data entered with a "^" at the beginning of their expression
> string.
>

### Customize chart captions

__`CaptionFromComment=false`__  [ `true` | `false` ]
>
> If chart caption is missing, use the time series comments to create the
> captions.
>

__`Newline="//"`__ [ string ] 
>
> Separator between lines in the captions of the charts.
>

__`ShowFormulas=false`__ [ `true` | `false` ]
>
> Add formulas from the input strings to the chart captions; the formula is
> always used for the chart caption whenever the caption is not supplied in
> the input string and the time series does not have a non-empty comment
> (or `CaptionFromComment=false`).
>

__`ShowTransform=false`__ [ `true` | `false` ]
>
> Add the `Transform` function to the chart captions.
>

### Customize figure windows

__`Tiles=@auto`__ [ numeric | `@auto` ]
>
> Number of rows and columns of tiles within one figure window.
> `Tiles=@auto` means the layout will be determined automatically based on
> the total number of charts, respecting also the option
> `MaxTilesPerWindow`.
>

__`MaxTilesPerWindow=40`__ [ numeric ]
>
> Maximum number of tiles (charts) in each figure window.
>

__`ShowFigure=Inf`__ [ numeric ]
>
> After drawing all figures, switch to this one to be shown on top;
> `ShowFigure=Inf` means the last figure window plotted.
>

### Customize graphics objects

__`FigureSettings={}`__ [ cell ]
>
> Cell array of settings passed to the standard Matlab `figure` constructor.
>

__`AxesSettings={}`__ [ cell ]
>
> Cell array of settings passed to the standard Matlab `axes` constructor.
>

__`PlotSettings={}`__ [ cell ]
>
> Cell array of settings passed to the plot functions as extra input
> arguments at the end.
>

__`TitleSettings={}`__ [ cell ]
>
> Cell array of settings passed to the `title` constructor as extra input
> arguments at the end.
>
%}


classdef (CaseInsensitiveProperties=true) Chartpack < handle

    properties
        Charts (1, :) databank.chartpack.Chart = databank.chartpack.Chart.empty(1, 0)

        Range = Inf
        PlotFunc {validate.mustBeFunc} = @plot
        Extra = []
        Transform {validate.mustBeScalarOrEmpty} = []
        NewLine (1, 1) string = "//"
        CaptionFromComment (1, 1) logical = false
        ShowFormulas (1, 1) logical = false
        ShowTransform (1, 1) logical = false
        ShowFigure (1, 1) double = Inf
        Round (1, 1) double = Inf
        FigureTitle (1, :) string = string.empty(1, 0)

        Expansion (1, :) cell = cell.empty(1, 0)

        Highlight {local_validateHighlight} = double.empty(1, 0)
        XLine = cell.empty(1, 0)
        YLine = cell.empty(1, 0)

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

