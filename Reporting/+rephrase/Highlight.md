---
title: rephrase.Highlight
---

# `rephrase.Highlight` ^^(+rephrase)^^

{== Create a Highlight object for rephrase reports ==}


## Syntax 

    output = rephrase.Highlight(startDate, endDate, varargin)

## Input arguments 

__`StartDate`__ [ numeric ]
> 
> Start date of the data to be displayed.
> 

__`EndDate`__ [ numeric ]
> 
> End date of the data to be displayed.
> 

## Output arguments 

__`output`__ [ Highlight ]
> 
> Highlight type object with the assigned arguements to be
> passed into the rephrase objects.
> 

## Options 

__`Shape=`__ [ Struct ]
> 
> Description
> 

__`Line=`__ [ Struct ]
> 
> Description
> 

__`Class=`__ [ string ]
> 
> Description
> 

__`Pass=`__ [ cell ]
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

__`ShowTitle=true`__ [ `true*` | `false` ]
> 
> Flag which enables the graph title by default and can be set
> to false.
> 

## Description 

The function `+rephrase/Highlight` returns the Highlight object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/SeriesChart`.

The passed object then highlights the specified area.

## Examples

```matlab

    hl = rephrase.Highlight(StartDate, EndDate, "fillColor", [0, 100, 200, 0.1]);

```
