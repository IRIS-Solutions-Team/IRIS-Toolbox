---
title: chkpriors
---

# `chkpriors`

{== Check compliance of initial conditions with priors and bounds.==}


## Syntax 

    Flag = chkpriors(M, E)
    [Flag, InvalidBound, InvalidPrior, NotFound] = chkpriors(M, E)


## Input Arguments

 `M` [ struct ] 
>
> Model object.
>

 `E` [ struct ] 
>
> Estimation specs. See `model/estimate` for details.
>


## Output Arguments

 `Flag` [ `true` | `false` ]
> 
> True if all parameters exist in the model
> object, and have initial values consistent with lower and upper bounds, 
> and prior distributions.
> 

 `InvalidBound` [ cellstr ]
> 
> Cell array of parameters whose initial
> values are inconsistent with lower or upper bounds.
> 

 `InvalidPrior` [ cellstr ] 
> 
> Cell array of parameters whose initial
> values are inconsistent with priors.
> 

 `NotFound` [ cellstr ] 
> 
> Cell array of parameters that do not exist in
> the model object `M`.
> 


## Options


## Description


## Example
