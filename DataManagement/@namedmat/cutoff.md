---
title: cutoff
---

# `cutoff`

{== Approximate cut-off frequency and periodicity from sample frequency response function ==}


## Syntax 

    [Cof, Cop] = cutoff(F, Freq)
    [Cof, Cop] = cutoff(F, Freq, Cog)


## Input arguments 

__`F`__ [ namedmat ]
> 
> Frequency response function (FRF), i.e. the first
> output argument from [`model/ffrf`](model/ffrf) or
> [`VAR/ffrf`](VAR/ffrf).
> 

__`Freq`__ [ numeric ]
> 
> Vector of frequencies on which the FFRF has been
> evaluated.
> 

__`Cog`__ [ numeric ]
> 
> Definition of the cut-off gain; if not specified, 
> `Cog=1/2`.
> 

## Output arguments 

__`Cof`__ [ numeric ]
> 
> Cut-off frequency for each of the FFRF, i.e. the
> frequency at which the gain of the FRF equals `X`.
> 

__`Cop`__ [ numeric ]
> 
> Cut-off periodicity.
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 

Because the function `cutoff` calculates the cut-off frequencies based on
a vector of discrete points describing the frequency response function, 
it uses simple interpolation between two neighbouring points.

## Examples

```matlab
```

