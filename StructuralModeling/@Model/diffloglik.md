---
title: diffloglik
---

# `diffloglik` ^^(Model)^^

{== Approximate gradient and hessian of log-likelihood function ==}


## Syntax 

    [mll, Grad, Hess, varScale] = diffloglik(M, Inp, Range, PList, ...)


## Input arguments 

    `M` [ model ]
> 
> Model object whose likelihood function will be differentiated
> 

    `Inp` [ cell | struct ]
> 
> Input data from which measurement variables will be taken.
> 

    `Range` [ numeric | char ]
> 
> Date range on which the likelihood function will be evaluated.
> 

    `PList` [ cellstr ]
> 
> List of model parameters with respect to which
> the likelihood function will be differentiated.
> 

## Output arguments 


    `mll` [ numeric ]
> 
> Value of minus the likelihood function at the input data.
> 

    `Grad` [ numeric ]
> 
> Gradient (or score) vector.
> 

    `Hess` [ numeric ]
> 
> Hessian (or information) matrix.
> 

    `varScale` [ numeric ]
> 
> Estimated variance scale factor if the `'relative='`
> options is true; otherwise `v` is 1.
> 

## Options 

    `'CheckSteady='` [ `true` | *`false`* | cell ]
> 
> Check steady state in each iteration; works only in non-linear models.
> 

    `'Solve='` [ *`true`* | `false` | cellstr ]
> 
> Re-compute solution for each parameter change; you can specify 
> a cell array with options for the `solve` function.
> 

    `'Sstate='` [ `true` | *`false`* | cell ]
> 
> Re-compute steady state in each differentiation step; if the model 
> is non-linear, you can pass in a cell array with options used 
> in the `sstate( )` function.
> 

> See help on [`model/filter`](model/filter) for other options available.

## Description 



## Examples


