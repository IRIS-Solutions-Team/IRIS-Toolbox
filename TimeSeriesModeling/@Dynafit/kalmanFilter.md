---
title: filter
---

# `filter`

{== Re-estimate factors by Kalman filtering data taking Dynamo coefficients as given ==}

 ## Syntax

     [outputDb, a, info] = kalmanFilter(a, inputDb, range, ___)


 ## Input arguments

__`a`__ [ Dynamo ]
> 
> Estimated Dynamo object.
> 


__`inputDb`__ [ struct ]
> 
> Input database or tseries object with the
> 

 Dynamo observables.

__`range`__ [ Dater ]
> 
> Filter date range.
> 



 ## Output arguments


__`outputDb`__ [ struct ]
> 
> Output databank.
> 


__`a`__ [ Dynamo ]
> 
> Dynamo object.
> 


 ## Options

__`Cross=true`__ [ `true` | `false` | numeric ]
> 
> Run the filter with the off-diagonal elements in the covariance matrix of
> idiosyncratic residuals; if false all cross-covariances are reset to zero;
> if a number between zero and one, all cross-covariances are multiplied by
> that number.
> 

__`InvFunc="auto"`__ [ `"auto"` | function_handle ]
> 
> Inversion method for the FMSE matrices.
> 

__`MeanOnly=false`__ [ `true` | `false` ]
> 
> Return only mean data, i.e.  point estimates.
> 

__`Persist=false`__ [ `true` | `false` ]
> 
> If `filter` or `forecast` is used with `Persist=true` for the first time,
> the forecast MSE matrices and their inverses will be stored; subsequent
> calls of the `filter` or `forecast` functions will re-use these matrices
> until `filter` or `forecast` is called with this option set to `false`.
> 


__`Tolerance=0`__ [ numeric ]
> 
> Numerical tolerance under which two FMSE matrices computed in two
> consecutive periods will be treated as equal and their inversions will be
> re-used, not re-computed.
> 


 ## Description

 It is the user's responsibility to make sure that `filter` and `forecast`
 called with `Persist=` set to true are valid, i.e. that the previously
 computed FMSE matrices can be really re-used in the current run.


 ## Example

