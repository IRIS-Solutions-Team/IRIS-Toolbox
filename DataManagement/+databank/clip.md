---
title: databank.clip
---

# `databank.clip` ^^(+databank)^^

{== Clip all time series in databank to a new range ==}


## Syntax 

    outputDatabank = databank.clip(inputDatabank, newStart, newEnd)


#### Input Arguments

__`inputDatabank`__ [ struct | Dictionary ]
> 
> Input databank whose time series (of the matching frequency) will be
> clipped to a new range defined by `newStart` and `newEnd`.
> 

__`newStart`__ [ Dater | `-Inf` ]
> 
> A new start date to which all time series of the matching frequency will
> be clipped; `-Inf` means the start date will not be altered.
> 

__`newEnd`__ [ Dater | `Inf` ]
> 
> A new end date to which all time series of the matching frequency will be
> clipped; `Inf` means the end date will not be altered.
> 


## Output Arguments

__`outputDatabank`__ [ struct | Dictionary ] - 
> 
> Output databank in which all time series (of the matching frequency) are
> clipped to the new range.
> 

## Description


## Example

Create a databank with time series of different frequencies. Clip the date
range of all quarterly series.so that they all start in 2019Q1.

```matlab
d = struct();
d.x1 = Series(qq(2015,1):qq(2030,4), @rand);
d.x2 = Series(qq(2010,1):qq(2025,4), @rand);
d.x3 = Series(mm(2012,01):qq(2025,12), @rand);
d.x4 = Series(mm(2019,01):qq(2022,08), @rand);
d.x5 = Series(1:100, @rand);
d = databank.clip(d, qq(2019,1), Inf)
```

