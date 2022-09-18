---
title: lhsmrhs
---

# `lhsmrhs` ^^(Model)^^

{== Discrepancy between the LHS and RHS of each model equation for given data ==}


 ## Syntax for Casual Evaluation

    Q = lhsmrhs(Model, InputDatabank, Range)

 ## Syntax for Fast (Repeated Evaluation)   

    Q = lhsmrhs(Model, X)

 ## Input Arguments 

 `Model` [ model ] 
> 
> Model object whose equations and currently assigned
> parameters will be evaluated.
>

`X` [ numeric ] 
>
> Numeric array created from an input databank by
> calling the function [`data4lhsmrhs`](model/data4lhsmrhs). `X` contains
> data for all `Model` quantities (measurement variables, transition
> variables, shocks, parameters, and exogenous variables including a time
> trend) organised in rows, plus an extra last row with time shifts for
> steady-state references.
 
 `InputDatabank` [ struct ]
>
> Input databank with data for measurement
> variables, transition variables, and shocks on which the discrepancies
> will be evaluated.
>

`Range` [ numeric ]
>
> Date range on which the discrepancies will be
> evaluated.
>


 ## Output Arguments

 `N` [ numeric ]
> 
>  Number of parameter variants within the model object,
> `M`.
>

 ## Description


 ## Example

