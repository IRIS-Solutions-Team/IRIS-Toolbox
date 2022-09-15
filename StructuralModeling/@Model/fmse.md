---
title: fmse
---

# `fmse` ^^(Model)^^

{== Forecast mean square error matrices. ==}


## Syntax 

    [F, List, D] = fmse(M, NPer, ...)
    [F, List, D] = fmse(M, range, ...)


## Input arguments 

  `M` [ model ]
>
> Model object for which the forecast MSE matrices will
> be computed.
>

  `NPer` [ numeric ] 
>  
>  Number of periods.
>

  `range` [ numeric | char ] 
>  
>  Date range.
>

 ## Output Arguments

  `F` [ namedmat | numeric ]
>
> Forecast MSE matrices.
>

  `List` [ cellstr ]
>  
> List of variables in rows and columns of `M`.
>

  `D` [ dbase ]
>
> Database with the std deviations of individual variables,
> i.e. the square roots of the diagonal elements of `F`.
>

 ## Options ##

  `'MatrixFormat='` [ `'namedmat'` | `'plain'` ]
>
> Return matrix `F` as
> either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
> rows and columns) or a plain numeric array.
>

  `'Select='` [ `@all` | char | cellstr ]
>  
> Return FMSE for selected
> variables only; `@all` means all variables.
>


## Description 



## Examples


