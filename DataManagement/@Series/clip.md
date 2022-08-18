---
title: clip
---

# `clip`

{== Clip time series range ==}


## Syntax 

    outputSeries = clip(inputSeries, newStart, newEnd)


## Input arguments 

__`inputSeries`__ [ TimeSubscriptable ]
>
> Input time series whose date range will be clipped.
>

__`newStart`__ [ Dater | `-Inf` ]
>
> New start date; `-Inf` means keep the current start date.
>

__`newEnd`__ [ Dater | `Inf` ]
>
> New end date; `Inf` means keep the current enddate.
>

## Output arguments 

__`outputSeries`__ [ TimeSubscriptable ]
>
> Output time series  with its date range clipped to the new range from
> `newStart` to `newEnd`. 
>

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 



## Examples

```matlab
```

