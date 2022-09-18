---
title: ifrf
---

# `ifrf` ^^(Model)^^

{== Frequency response function to shocks. ==}


## Syntax 

    [W,List] = ifrf(M,Freq,...)


## Input arguments 

 `M` [ model ]
>
> Model object for which the frequency response function
> will be computed.
>

 `Freq` [ numeric ] 
> 
> Vector of frequencies for which the response
> function will be computed.
> 


## Output arguments 

 `W` [ namedmat | numeric ]
>
> Array with frequency responses of
> transition variables (in rows) to shocks (in columns).
>

 `List` [ cell ]
>
> List of transition variables in rows of the `W`
> matrix, and list of shocks in columns of the `W` matrix.
>

## Options 

 `'MatrixFormat='` [ *`'namedmat'`| `'plain'` ]
>
> Return matrix `W` as
> either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
> rows and columns) or a plain numeric array.
>

 `'select='` [ *`@all`| char | cellstr ]
>
> Return IFRF for selected
> variables only; `@all` means all variables.
>

## Description 



## Examples


