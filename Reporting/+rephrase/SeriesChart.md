---
title: rephrase.SeriesChart
---

# `rephrase.SeriesChart` ^^(+rephrase)^^

{== Create a SeriesChart object for rephrase reports ==}


## Syntax 

    output = rephrase.SeriesChart(title, dates, varargin)


## Input arguments 

__`title`__ [ string ]
> 
> Title text for the chart.
> 

__`dates`__ [ numeric ]
> 
> Range of the data to be displayed which should match the
> format of the data.
> 

## Output arguments 

__`output`__ [ SeriesChart ]
> 
> SeriesChart type object with the assigned arguements to be
> passed into the rephrase objects.
> 

## Options 

__`StartDate=`__ [ numeric ]
> 
> Start date of the data to be displayed.
> 

__`Layout=struct()`__ [ struct ]
> 
> Low-level layout options for charts; implemented are the following
> elements:
>
> * `.xaxis`
> * `.yaxis`
> * `.font`
> * `.legend`
> * `.margin`
> 

__`EndDate=`__ [ numeric ]
> 
> End date of the data to be displayed.
> 

__`DateFormat='YYYY-MM-DD'`__ [ string ]
> 
> Date format to be displayed.
> 

__`BarMode='group'`__ [ string `'group'` | `'stack'` | `'relative'` ]
> 
> Bar mode of the series to be displayed.
> 

__`Frequency=`__ [ numeric ]
> 
> Frequency of the displayed data.
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

`+rephrase/Series`

## Description 

The function `+rephrase/SeriesChart` returns the SeriesChart object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Grid`.

The object requires the child to be defined either via a standalone object or a class function `fromSeries`. See the example below.

## Examples

```matlab

    % Using standalone Series object
    chart1 = rephrase.SeriesChart("Chart 1", startDate:endDate) ...
        + rephrase.Series("Series X", d.x);

    % Using fromSeries class function
    chart1 = rephrase.SeriesChart.fromSeries({"Chart 1", startDate:endDate}, ...
    {"Actual", d.l_y});

```
