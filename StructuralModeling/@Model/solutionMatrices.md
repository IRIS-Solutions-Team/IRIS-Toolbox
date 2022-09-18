---
title: solutionMatrices
---

# `solutionMatrices` ^^(Model)^^

{== Access first-order state-space (solution) matrices ==}


## Syntax

    output = solutionMatrices(model, ...)


## Input Arguments

__`model`__ [ Model ]
> 
> Solved model object.
> 



## Output Arguments

__`T`__ [ numeric ]
> 
> Transition matrix.
> 


__`R`__ [ numeric ]
> 
> Matrix at the shock vector in transition equations.
> 


__`K`__ [ numeric ]
> 
> Constant vector in transition equations.
> 


__`Z`__ [ numeric ]
> 
> Matrix mapping transition variables to measurement
> 

variables.

__`H`__ [ numeric ]
> 
> Matrix at the shock vector in measurement
> 

equations.

__`D`__ [ numeric ]
> 
> Constant vector in measurement equations.
> 


__`U`__ [ numeric ]
> 
> Transformation matrix for predetermined variables.
> 


__`Omg`__ [ numeric ]
> 
> Covariance matrix of shocks.
> 



## Options

__`Triangular=true`__ [ `true` | `false` ] -
If true, the state-space form returned has the transition matrix `T`
quasi triangular and the vector of predetermined variables transformed
accordingly; this is the default form used in IRIS calculations. If
false, the state-space system is based on the original vector of
transition variables.


## Description

The state-space representation has the following form:

    [xf;alpha] = T*alpha(-1) + K + R*e

    y = Z*alpha + D + H*e

    xb = U*alpha

    Cov[e] = Omg

where `xb` is an nb-by-1 vector of predetermined (backward-looking)
transition variables and their auxiliary lags, `xf` is an nf-by-1 vector
of non-predetermined (forward-looking) variables and their auxiliary
leads, `alpha` is a transformation of `xb`, `e` is an ne-by-1 vector of
shocks, and `y` is an ny-by-1 vector of measurement variables.
Furthermore, we denote the total number of transition variables, and
their auxiliary lags and leads, nx = nb + nf.

The transition matrix, `T`, is, in general, rectangular nx-by-nb.
Furthremore, the transformed state vector alpha is chosen so that the
lower nb-by-nb part of `T` is quasi upper triangular.

You can use the `get(m, 'xiVector')` function to learn about the order of
appearance of transition variables and their auxiliary lags and leads in
the vectors `xb` and `xf`. The first nf names are the vector `xf`, the
remaining nb names are the vector `xb`.


## Example



