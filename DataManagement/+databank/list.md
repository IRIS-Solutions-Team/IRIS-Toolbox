---
title: databank.list
---

# `databank.list` ^^(+databank)^^

{== List databank fields adding date range to time series fields ==}


## Syntax

    databank.list(db)


## Input Arguments

__`db`__ [ struct | Dictionary ]
> 
> Databank whose fields will be listed on the screen, with information on
> date ranges added to time series fields.
> 

## Description


## Example

```matlab
d = struct();
d.a = 1;
d.b = Series(qq(2020,1), rand(20, 1));
d.c = Series(yy(2020), rand(10, 1));
d.d = "abcd";
databank.list(d)
```

