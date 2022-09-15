---
title: isnan
---

# `isnan` ^^(Model)^^

{== Check for NaNs in model object. ==}


 ## Syntax ##

     [Flag, List] = isnan(M, 'Parameters')
     [Flag, List] = isnan(M, 'Steady')
     [Flag, List] = isnan(M, 'Derivatives')
     [Flag, List] = isnan(M, 'Solution')


 ## Input Arguments ##

 `M` [ model ]
>
> Model object.
>

 ## Output arguments ##

 `Flag` [ `true` | `false` ]
>
> True if at least one `NaN` value exists
> in the queried category.
>

 `List` [ cellstr ]
> 
> List of parameters (if called with `'Parameters'`)
> or variables (if called with `'Steady'`) that are assigned NaN in at
> least one parameter variant, or equations (if called with `'Derivatives'`)
> that produce an NaN derivative in at least one parameterisation.
>

 ## Description ##


 ## Examples ##


