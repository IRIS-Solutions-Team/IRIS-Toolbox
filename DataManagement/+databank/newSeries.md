---
title: databank.newSeries
---

# `databank.newSeries` ^^(+databank)^^

{== Create new empty series in a databank ==}


## Syntax 

    outputDb = databank.newSeries(inputDb, list)


## Input arguments 

__`inputDb`__ [ struct | Dictionary ]
> 
> Input databank within which new time series will be created.
> 

__`list`__ [ string ]
> 
> List of new time series names; if the already exists in the databank,
> they will be simply assigned a new empty time series and the previous
> content will be removed.
> 

## Output arguments 

__`outputDb`__ [ struct | Dictionary ]
> 
> Output databank with the new time series added.
> 

