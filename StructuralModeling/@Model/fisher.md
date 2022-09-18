---
title: `fisher`
---

# `fisher` ^^(Model)^^

{== Approximate Fisher information matrix in frequency domain ==}

## Syntax ##

    [F, FF, Delta, Freq] = fisher(M, NPer, PList, ...)


## Input Arguments ##

__`M`__ [ model ]
>
> Solved model object.
>

__`NPer`__ [ numeric ]
>
> Length of the hypothetical range for which the Fisher information will be
> computed.
> 

__`PList`__ [ cellstr ]
>
> List of parameters with respect to which the likelihood function will be
> differentiated.
>


## Output Arguments ##

__`F`__ [ numeric ]
>
> Approximation of the Fisher information matrix.
>

__`FF`__ [ numeric ]
>
> Contributions of individual frequencies to the total Fisher information
> matrix.
>

__`Delta`__ [ numeric ]
>
> Kronecker delta by which the contributions in `Fi` need to be multiplied
> to sum up to `F`.
> 

__`Freq`__ [ numeric ]
>
> Vector of frequencies at which the Fisher information matrix is
> evaluated.
> 

## Options ##

__`CheckSteady`__ [ `true` | `false` | cell ]
>
> Check steady state in
> each iteration; works only in non-linear models.
> 

__`Deviation`__ [ `true` | `false` ]
>
> Exclude the steady state effect
> at zero frequency.
> 

__`Exclude`__ [ char | cellstr | empty ]
>
> List of measurement
> variables that will be excluded from the likelihood function.
>

__`Percent`__ [ `true` | `false` ]
>
> Report the overall Fisher matrix `F` as Hessian w.r.t. the log of
> variables; the interpretation for this is that the Fisher matrix
> describes the changes in the log-likelihood function in reponse to
> percent, not absolute, changes in parameters.
> 

__`Progress`__ [ `true` | `false` ]
>
> Display progress bar in the command window.
> 

__`Solve`__ [ `true` | `false` | cellstr ]
>
> Re-compute solution in each differentiation step; you can specify a cell
> array with options for the `solve()` function.
> 

__`Steady`__ [ `true` | `false` | cell ]
>
> Re-compute steady state in each differentiation step; if the model is
> non-linear, you can pass in a cell array with opt used in the `steady()`
> function.
>

## Description ##


## Example ##

