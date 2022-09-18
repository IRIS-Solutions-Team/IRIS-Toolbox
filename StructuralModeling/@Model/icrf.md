---
title: icrf
---

# `icrf` ^^(Model)^^

{== Initial-condition response functions, first-order solution only ==}


 ## Syntax ##

     S = icrf(M, NPer, ...)
     S = icrf(M, Range, ...)


 ## Input Arguments ##

 `M` [ model ] 
>
> Model object for which the initial condition responses
> will be simulated.
>

 `Range` [ numeric | char ]
>
> Date range with the first date being the
> shock date.
>

 `NPer` [ numeric ] 
>
> Number of periods.
>

 ## Output Arguments ##

 `S` [ struct ]
>
> Databank with initial condition response series.
>

 ## Options ##

 `'Delog='` [ *`true`| `false` ] 
>
> Delogarithmise the responses for
> variables declared as `!log_variables`.
>

 `'Size='` [ numeric | *`1`for linear models | *`log(1.01)`for non-linear
 models ] 
> 
> Size of the deviation in initial conditions.
>

 ## Description ##
>
> Function `icrf` returns the responses of all model variables to a
> deviation (of a given size) in one initial condition. All other
> initial conditions remain undisturbed and all shocks remain zero in the
> simulation.
>

## Examples

