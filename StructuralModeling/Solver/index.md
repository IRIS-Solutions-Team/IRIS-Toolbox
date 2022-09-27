
# Overview of nonlinear equations solver settings

{==
Iris features its own nonlinear equations solver used in calculating the
steady state and dynamic simulations of structural models.
==}


## General settings

__`display="iter"`__ [ `"iter"` | `"final"` | `"none"` | numeric ]
> 
> Level of display in numeric iterations:
> 
> * `display="iter"` - print every iteration and the final convergence
>   message;
> 
> * `display="final"` - print the final convergence message only;
> 
> * `display="none"` - do not print any message;
> 
> * `display=numeric` - same as `"display="iter"` but print every `display`
>   iterations only.
> 

## Objective function settings

__`functionNorm=2`__ [ numeric | `Inf` | function ]
> 
> A vector norm applied to the array of discrepancies between the LHS and
> RHS of individual equations; see help on the builtin `norm` function for
> numeric specification of the norm; or specify your own function norm as
> an anonymous function. 
> 
> In most situations, one of the following norms are the appropriate
> choice:
> 
> * `functionNorm=2` - a quadratic norm, i.e. sum of squared discrepancies;
> 
> * `functionNorm=Inf` - an infinity norm, i.e. sum of absolute discrepancies.
> 

__`trimObjectiveFunction=false` [ `true` | `false` ]
> 
> After evaluating the objective function, replace the value smaller than
> `functionTolerance` with zeros.
> 

## Convergence settings

__`maxIterations=5000`__ [ numeric ]
> 
> Maximum number of iterations.
> 

__`maxFunctionEvaluations=@(x) 200*x.NumUknowns`__ [ numeric | functions ]  
> 
> Maximum number of function evaluations.
> 

__`functionTolerance=1e-12`__ [ numeric ]
> 
> Convergence tolerance for the `functionNorm`.
> 

__`stepTolerance=1e-12`__ [ numeric ]
> 
> Convergence tolerance for the maximum absolute change in the value of the
> unknowns; set `stepTolerance=Inf` to turn step tolerance off.
> 

## Jacobian settings

__`jacobCalculation="analytical"`__ [ `"analytical"` | `"forwardDiff"` ]
> 
> Calculate the Jacobian analytically or numerically.
> 

__`lastJacobUpdate=Inf`__ [ numeric | `Inf` ]
> 
> Last iteration in which the Jacobian will be updated:
> 
> * `lastJacobUpdate=Inf` means the Jacobian will be always updated;
> 
> * `lastJacobUpdate=0` means the Jacobian will be calculated once at the
>   beginning and never updated afterwards;
> 
> * `lastJacobUpdate=-1` means the Jacobian will not be calculated, and an
>   identity matrix will be used in its place;
> 
> * `lastJacobUpdate=n` means the Jacobian will be update until the `n`-the
>   iteration (inclusive).
> 


__`skipJacobUpdate=0`__ [ numeric ]
> 
> The Jacobian will be reused (without recalculation) in the next
> `skipJacobUpdate` iteration; then it will get updated again.
> 

