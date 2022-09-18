---
title: ffrf
---

# `ffrf` ^^(Model)^^

{== Filter frequency response function of transition variables to measurement variables==}


## Syntax 

    [F, list] = ffrf(model, freq, ...)


 ## Input Arguments

  __`model`__ [ Model ]
>
> Model object for which the frequency response function will be
> computed.
>

  __`freq`__ [ numeric ]
>  
> Vector of freq for which the response
> function will be computed.
>

 ## Output Arguments

  __`F`__ [ namedmat | numeric ]
>  
> Array with frequency responses of transition variables (in rows) to
> measurement variables (in columns).
>

  __`list`__ [ cell ]
>  
> List of transition variables in rows of the `F` matrix, and list of
> measurement variables in columns of the `F` matrix.
>


 ## Options


 __`Include=@all`__ [ char | cellstr | `@all` ]
> 
> Include the effect of the listed measurement variables only; `@all` means
> all measurement variables.
>

 __`Exclude=[ ]`__ [ char | cellstr | empty ]
> 
> Remove the effect of the
> listed measurement variables.
>

 __`MaxIter=500`__ [ numeric ]
> 
> Maximum number of iteration when
> calculating a steady-state Kalman filter for zero-frequency FRF.
>

 __`MatrixFormat='NamedMat'`__ [ `'NamedMat'` | `'Plain'` ]
>
> Return matrix
> `F` as either a [`namedmat`](namedmat/Contents) object (i.e. matrix with
> named rows and columns) or a plain numeric array.
>

 __`Select=@all`__ [ `@all` | char | cellstr ]
> 
> Return FFRF for selected variables only; `@all` means all variables.
>

 __`Tolerance=1e-7`__ [ numeric ]
> 
> Convergence tolerance when calculating a steady-state Kalman filter for
> zero-frequency FRF.
>
 ## Description


 ## Examples

