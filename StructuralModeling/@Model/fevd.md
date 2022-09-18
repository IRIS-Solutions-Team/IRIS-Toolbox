---
title: fevd
---

# `fevd` ^^(Model)^^

{== Forecast error variance decomposition for model variables.==}


## Syntax 

    [X, Y, List, A, B] = fevd(M, Range, ...)
    [X, Y, List, A, B] = fevd(M, NPer, ...)


 ## Input Arguments

  `M` [ model ] 
>
> Model object for which the decomposition will be
> computed.
>

  `Range` [ numeric | char ] 
>  
> Decomposition date range with the first
> date beign the first forecast period.
>

  `NPer` [ numeric ] 
>  
> Number of periods for which the decomposition will
> be computed.
>

 ## Output Arguments

  `X` [ namedmat | numeric ]
>  
> Array with the absolute contributions of
> individual shocks to total variance of each variables.
>

  `Y` [ namedmat | numeric ]
>  
> Array with the relative contributions of
> individual shocks to total variance of each variables.
>

  `List` [ cellstr ] 
>  
> List of variables in rows of the `X` an `Y`
> arrays, and shocks in columns of the `X` and `Y` arrays.
>

  `A` [ struct ]
>  
> Database with the absolute contributions converted to
> time series.
>

  `B` [ struct ] 
>  
> Database with the relative contributions converted to
> time series.
>

 ## Options

 `'MatrixFormat='` [ `'namedmat'` | `'plain'` ] 
> 
> Return matrices `X`
> and `Y` as be either [`namedmat`](namedmat/Contents) objects (i.e.
> matrices with named rows and columns) or plain numeric arrays.
>

  `'select='` [ `@all` | char | cellstr ]
>  
> Return FEVD for selected
> variables and/or shocks only; `@all` means all variables and shocks; this
> option does not apply to the output databases, `A` and `B`.
>

 ## Description


 ## Examples

