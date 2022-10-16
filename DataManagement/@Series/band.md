---
title: band
---

# `band` ^^(Series)^^

{== Draw time series with uncerainty bands ==}


## Syntax

    [plotHandle, info] = band([mid, lower, upper], ___)
    [plotHandle, info] = band(mid, lower, upper, ___)


## Input arguments


__`mid`__ [ Series ]
> 
> Time series with the mid point for the band.
> 


__`lower`__ [ Series ]
> 
> Time series with the lower band or lower bands.
> 


__`upper`__ [ Series ]
> 
> Time series with the upper band or upper bands.
> 


## Output arguments


__`plotHandle`__ [ handle ]
> 
> Graphics handle to the mid-point line.
> 


__`info`__ [ struct ]
> 
> Output information struct with the following fieds:
> 
> * `.BandHandles` - graphics handles to the bands (patch objects)
> 
> * `.Dates` - dates actually plotted
> 
> * `.MidData` - mid-point data actually plotted;
> 
> * `.LowerData` - lower bound data actually plotted;
> 
> * `.UppderData` - upper bound data actually plotted;
> 


## Description 



## Examples

```matlab
```


