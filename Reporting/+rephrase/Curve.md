---
title: rephrase.Curve
---

# `rephrase.Curve` ^^(+rephrase)^^

{== Create a Curve object for rephrase reports ==}


## Syntax 

    output = rephrase.Curve(title, input, varargin)


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

__`output`__ [ Curve ]
> 
> Curve type object with the assigned arguements to be
> passed into the rephrase objects.
> 

## Options 

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

## Description 

The function `+rephrase/Curve` returns the Curve object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/CurveChart`.

The object requires the child to be defined either via a standalone object or a class function `fromMultivariate`. See the example below.

## Examples

```matlab
```
