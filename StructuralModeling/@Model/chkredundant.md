
---
title: chkredundant
---

{== Check for redundant shocks and/or parameters.==}


## Syntax 

    Flag = chkpriors(M, E)
    [Flag, InvalidBound, InvalidPrior, NotFound] = chkpriors(M, E)


## Input arguments
 

  `m` [ model ] 
>
> Model object.
>

## Output arguments
 

  `redShocks` [ cellstr ] 
>
> List of shocks that do not occur in any model
> equation.
>

  `redParams` [ cellstr ]
>
> List of parameters that do not occur in any
> model equation.
>


## Options
 

  `'Warning'` [ `true` | `false` ] 
>
> Throw a warning listing redundant
> shocks and parameters.
>

  `'ChkShocks'` [ `true` | `false` ] 
>
> Check for redundant shocks.
>

  `'ChkParams'` [ `true` | `false` ] 
>
> Check for redundant parameters.
>


## Description
 


## Examples
 
