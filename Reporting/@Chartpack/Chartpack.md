---
title: Chartpack
---

# `Chartpack`

{== Create a new Chartpack object for plotting databank fields ==}


## Syntax

    ch = Chartpack()


## Output Arguments

__`ch`__ [ Chartpack ]
>
> New empty Chartpack object
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

__`Autocaption=false`__  [ `true` | `false` ]
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
> (or `Autocaption=false`).
>

__`ShowTransform=false`__ [ `true` | `false` ]
>
> Add the `Transform` function to the chart captions.
>

### Customize figure windows

__`Tiles=@auto`__ [ numeric | `@auto` ]
>
> Number of rows and columns of tiles within one figure window. Two special
> cases are allowed for this setting:
> 
> * `Tiles=@auto` - the layout will be determined optimally based on the
>   total number of charts (respecting the option `MaxTilesPerWindow`).
>
> * `Tiles=[Inf, numColumns]` - the layout will be determined automatically
>   based on the total number of charts within a figure (respecting
>   `MaxTilesPerWindow`) with the number of columns being `numColumns`.
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

