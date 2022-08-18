
---
title: chkmissing
---

{== Check for missing initial values in simulation database.==}

 ## Syntax

     [Ok, Miss] = chkmissing(M, D, Start)


 ## Input Arguments

  `M` [ model ]  
>
> Model object.
>

  `D` [ struct ]  
>
> Input database for the simulation.
>

  `Start` [ numeric ] 
>
> Start date for the simulation.
>

 ## Output Arguments

  `Ok` [ `true` | `false` ] 
>
> True if the input database `D` contains
> all required initial values for simulating model `M` from date `Start`.
>

  `Miss` [ cellstr ] 
>
> List of missing initial values.
>

 ## Options

  `'error='` [ `true` | `false` ] 
>
> Throw an error if one or more
> initial values are missing.
>

 ## Description
>
> This function does not perform any simulation; it only checks for missing
> initial values in an input database.
>

 ## Examples
