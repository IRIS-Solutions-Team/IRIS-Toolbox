---
title: rephrase.Bands
---

# `rephrase.Bands` ^^(+rephrase)^^

{== Create a Bands object for rephrase reports ==}


## Syntax 

    output = rephrase.Bands(title, lower, upper, relation, varargin)


## Input arguments 

__`title`__ [ string ]
> 
> Title text for bands which will be passed to the SeriesChart
> object to be displayed as a legend.
> 

__`Lower`__ [ Series ]
> 
> Series type of data which will be passed to the SeriesChart
> object to be displayed as the lower part of the shaded area.
> In case of the `absolute` relation, a lower part of
> percentiles needs to be passed. In case of the `relative`
> relation, a sigma value needs to be passed.
> 

__`Lower`__ [ Series ]
> 
> Series type of data which will be passed to the SeriesChart
> object to be displayed as the lower part of the shaded area.
> In case of the `absolute` relation, a upper part of
> percentiles needs to be passed. In case of the `relative`
> relation, a sigma value needs to be passed.
> 

__`Relation`__ [ string `relative` | `absolute` ]
> 
> The bands can be either `relative` or `absolute`. The
> `absolute` relation directly takes the percentile Series type
> of data a draws shaded areas. The `relative` relation take the
> value of sigma and calculates the areas.
> 

## Output arguments 

__`output`__ [ Bands ]
> 
> Bands type object with the assigned arguements to be passed
> into the rephrase objects.
> 

## Options 

__`ShowLegend=true`__ [ `true*` | `false` ]
> 
> Flag which enables the graph legend by default and can be set
> to false.
> 

__`Whitening=0`__ [ numeric ]
> 
> The option sets the level of whitening happening in the
> shaded area.
> 

__`Alpha=0.5`__ [ numeric ]
> 
> The option sets the RGB opacity of the shaded area. The
> value can be set between 1 and 0 where 1 means the same color
> as the mid point line and 0 means white.
> 

__`LineWidth=0`__ [ numeric ]
> 
> The option sets the linewidth of shaded area's edges.
> 

__`Class=`__ [ string ]
> 
> Description
> 

__`Pass=`__ [ cell ]
> 
> Description
> 

__`ShowTitle=true`__ [ `true*` | `false` ]
> 
> Flag which enables the graph title by default and can be set
> to false.
> 

## Possible children

None

## Description 

The function `+rephrase/Bands` returns the Bands object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Series` (itself a child of `+rephrase/SeriesChart`).

## Examples

```matlab

    % Creating Bands objects
    b1 = rephrase.Bands("25th to 75th percentile", d.x_5_25_75_95{:,2}, d.x_5_25_75_95{:,3}, "absolute", "alpha", 0.50);
    b2 = rephrase.Bands("5th to 95th percentile", d.x_5_25_75_95{:,1}, d.x_5_25_75_95{:,4}, "absolute", "alpha", 0.30);

    % Using absolute relation
    chart1 = rephrase.SeriesChart("Chart 1", startDate:endDate) ...
        + rephrase.Series("Series X", d.x, "bands", {b1, b2});

    % Using relative relation
    b1 = rephrase.Bands("+/– sigma", d.y_std, d.y_std, "relative", "alpha", 0.30);
    chart2 = rephrase.SeriesChart("Chart 2", startDate:endDate) ...
        + rephrase.Series("Series Y", d.y, "bands", b1);

```
