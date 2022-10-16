---
title: Series
---

# `Series` ^^(Series)^^

{== Create new time series object ==}


## Syntax

    X = Series()
    X = Series(dates, values)
    X = Series(dates, values, comments)
    X = Series(dates, values, comments, userData)


## Input Arguments

__`dates`__ [ numeric | char ] 
> 
> Dates for which observations will be supplied; `dates` do not need to be
> sorted in ascending order or create a continuous date range. If `dates`
> is scalar and `values` have multiple rows, then the date is interpreted
> as the start date for the entire time series.
> 

__`values`__ [ numeric | function_handle ] 
> 
> Numerical values (observations) arranged columnwise, or a function that
> will be used to create an N-by-1 array of values, where N is the number
> of `dates`.
> 

__`comments`__ [ string ] 
> 
> Comment(s) attached to each column of the time series; if omitted,
> comments will be empty strings.
> 

__`userData`__ [ * ] 
> 
> Any kind of user data attached to the object; if omitted, user data will
> be empty; if `userData` is a struct, the Series methods `accessUserData`
> and `assignUserData` can be used access or assign/change them.
> 

## Output Arguments

__`x`__ [ Series ] 
> 
> New times series.
> 

## Description


## Example

```matlab
x = Series(qq(2020,1):qq(2021,4), rand(8, 1), "Random numbers");
x = Series(qq(2020,1), rand(8, 1), "Random numbers");
x = Series(qq(2020,1):qq(2021,4), @rand, "Random numbers");
```

