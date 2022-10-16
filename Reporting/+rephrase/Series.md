---
title: rephrase.Series
---

# `rephrase.Series` ^^(+rephrase)^^

{== Create a Series object for rephrase reports ==}


## Syntax 

    output = rephrase.Series(title, input, varargin)


## Input arguments 

__`title`__ [ string ]
> 
> Legend text for the series.
> 

__`input`__ [ Series ]
> 
> Series type of object which contains the data to be displayed
> 

## Output arguments 

__`output`__ [ Series ]
> 
> Series type object with the assigned arguements to be
> passed into the rephrase objects.
> 

## Options 

__`Units=`__ [ string ]
> 
> Description
> 

__`Bands=`__ [ Bands ]
> 
> Bands type object to be displayed. See `+rephrase/Bands` for
> more information.
> 

__`ShowLegend=true`__ [ `true*` | `false` ]
> 
> Flag which enables the graph legend by default and can be set
> to false.
> 

__`LineWidth=2`__ [ numeric ]
> 
> The option sets the linewidth.
>

__`Type='scatter'`__ [ string `'scatter*'` | `'Bar'` ]
> 
> The option sets the type of the graph to be displayed. It
> is set by default as `'scatter'` but can be change to `'Bar'`.
>

__`Markers=`__ [ struct ]
> 
> The option sets the markers to be displayed.
>

__`StackGroup=`__ [ string ]
> 
> The option sets the stack groups for type `'Bar'`.
>

__`Fill='none'`__ [ string ]
> 
> Description
>

__`Text=`__ [ string ]
> 
> Description
>

__`Color=`__ [ string ]
> 
> The option sets the color by using the RGB hex code of the
> displayed Series.
>

__`FillColor=`__ [ string ]
> 
> The option sets the fill color by using the RGB hex code of
> the displayed Series.
>

## Possible children

None

## Description 

The function `+rephrase/Series` returns the Series object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/SeriesChart`.

The object requires the child to be defined either via a standalone object or a class function `fromMultivariate`. See the example below.

## Examples

```matlab

    % Using standalone Series object
    chart1 = rephrase.SeriesChart("Chart 1", startDate:endDate) ...
        + rephrase.Series("Series X", d.x);

    % Using fromMultivariate class function
    roundNames = ["Series X1", "Series X2"]
    chart1 = rephrase.SeriesChart("Chart 1", startDate:endDate) ...
        + rephrase.fromMultivariate([roundNames(1),roundNames(2)], d.x);

```
