---
title: rephrase.CurveChart
---

# `rephrase.CurveChart` ^^(+rephrase)^^

{== Create a CurveChart object for rephrase reports ==}


## Syntax 

    output = rephrase.CurveChart(title, ticks, varargin)


## Input arguments 

__`title`__ [ string ]
> 
> Title text for the chart.
> 

__`ticks`__ [ numeric ]
> 
> Range of the data to be displayed which should match the
> format of the data.
> 

## Output arguments 

__`output`__ [ CurveChart ]
> 
> CurveChart type object with the assigned arguements to be
> passed into the rephrase objects.
> 


## Options 

__`DateFormat='YYYY-MM-DD'`__ [ string ]
> 
> Date format to be displayed.
> 

__`Ticks`__ [  ]
> 
> Description
> 

__`TickLabels`__ [  ]
> 
> Description
> 

__`HoverFormat=`__ [ string ]
> 
> Description
> 

__`ShowLegend=true`__ [ `true*` | `false` ]
> 
> Flag which enables the graph legend by default and can be set
> to false.
> 

__`Highlight=`__ [ cell ]
> 
> Option which passes the Highlight object and displays it on
> the graph.
> 

## Possible children

`+rephrase/Curve`
`+rephrase/Marker`

## Description 

The function `+rephrase/CurveChart` returns the CurveChart object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Grid`.

The object requires the child to be defined either via a standalone object or a class function `fromCurve`. See the example below.

## Examples

```matlab
```
