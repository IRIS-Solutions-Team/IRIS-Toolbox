---
title: yearly
---

# `yearly` ^^(Series)^^

{== Return array with time series data organized as one year per row ==}


## Syntax 

data = yearly(series, ~yearlyDates)
> 
> Input arguments marked with a `~` sign may be omitted
> 

## Input arguments 

__`series`__ [ Series ]
> 
> Input time series.
> 

__`~yearlyDates`__ [ Dater ]
> 
> Years (dates of yearly frequency) for which the time series data will be
> returned; one year per row; if omitted, the data will be returned from
> the first year to the last year of the input `series`.
> 


## Output arguments 

__`data`__ [ numeric | logical ]
> 
> Array with the `series` data organized as one year per row; if the input
> `series` is a multivariate series, the 2nd and higher dimension will be
> shifted to 3rd and higher dimensions.
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

