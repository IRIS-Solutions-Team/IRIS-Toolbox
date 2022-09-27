---
title: databank.range
---

# `databank.range` ^^(+databank)^^

{== Find a range that encompasses the ranges of all or selected databank time series ==}


## Syntax

    [range, listFreq] = databank.range(inputDb, ...)


## Input Arguments

__`inputDb`__ [ struct | Dictionary ]
> 
> Input databank; can be either a struct, or a Dictionary.
> 

## Output Arguments

__`range`__ [ Dater | cell ]
> 
> Range that encompasses the observations of the time series in the input
> database; if time series with different frequencies are contained in the
> `inputDb` then the ranges, one for each of the frequency, are returned in
> a cell array.
> 

__`listFreq`__ [ numeric ]
> 
> Vector of date frequencies coresponding to the returned ranges.
> 

## Options

__`SourceNames=@all`__ [ string | Rexp | `@all` ]
> 
> List of time series that will be included in the range search or a
> regular expression that will be matched to compose the list; `@all`
> means all time series objects existing in the input databases will be
> included.
> 

__`StartDate="unbalanced"`__ [ `"unbalanced"` ]
> 
> `StartDate="unbalanced"` means the output `range` will start at the
> earliest start date among all them time series included in the search;
> `StartDate="balanced"` means the `range` will start at the latest start
> date.
> 

__`EndDate="unbalanced"`__ [ `"unbalanced"` | `"balanced"` ] 
> 
> `EndDate="unbalanced"` means the `range` will end at the latest end date
> among all the time series included in the search; `EndDate="balanced"`
> means the `range` will end at the earliest end date.
> 

## Description


## Example


