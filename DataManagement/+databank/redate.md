---
title: databank.redate
---

# `databank.redate` ^^(+databank)^^

{== Redate all time series objects in a database ==}


## Syntax 

    d = databank.redate(d, oldDate, newDate)


## Input arguments 

__`d`__ [ struct ]
> 
> Input database with time series objects.
> 

__`oldDate`__ [ DateWrapper ]
> 
> Base date that will be converted to a new date in all time series objects.
> 

__`newDate`__ [ DateWrapper ]
> 
> A new date to which the base date `oldDate`
> will be changed in all time series objects; `newDate` need not be the
> same frequency as `oldDate`.
> 


## Output arguments 

__`d`__ [ struct ]
> 
> Output database where all time series objects have
> identical data as in the input database, but with their time dimension
> changed.
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

