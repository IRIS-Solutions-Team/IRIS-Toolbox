---
title: Series.empty
---

# `Series.empty` ^^(Series)^^

{== Create empty time series or empty existing time series ==}


## Syntax

    x = Series.empty([0, size, ...])
    x = Series.empty(0, size, ...)
    x = Series.empty(x)


## Input Arguments

__`size`__ [ numeric ] 
> 
> Size of new time series in 2nd and higher
> dimensions; first dimenstion (time) must be always 0.
> 

__`this`__ [ Series ] 
> 
> Input time series that will be emptied.
> 

## Output Arguments

__`this`__ [ Series ] 
> 
> Empty time series with the 2nd and higher
> dimensions the same size as the input time series, and comments
> preserved.
> 

## Description


## Examples

### Plain Vanilla Example

Create a 12-by-3-by-2 monthly time series, and then use `Series.empty` to
create a new, empty series with now rows but the same size in 2nd and
higher dimensions

```matlab
x = Series(mm(2020,01), rand(12, 3, 2))
x0 = Series.empty(x)
```

