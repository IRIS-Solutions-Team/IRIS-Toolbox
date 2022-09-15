---
title: isstationary
---

# `isstationary` ^^(Model)^^

{== True if model or specified combination of variables is stationary. ==}


 ## Syntax

     [Flag, List] = isnan(M, 'Parameters')
     [Flag, List] = isnan(M, 'Steady')
     [Flag, List] = isnan(M, 'Derivatives')
     [Flag, List] = isnan(M, 'Solution')


 ## Input Arguments ##

 `M` [ model ]
> 
> Model object.
>

 `Name` [ char ]
> 
> Transition variable name.
>

 `LinComb` [ char ] 
> 
> Text string defining a linear combination of
> transition variables; log variables need to be enclosed in `log(...)`.
>

 ## Output Arguments ##

 `Flag` [ `true` | `false` ]
> 
> True if the model (if called without a
> second input argument) or the specified transition variable or
> combination of transition variables (if called with a second input
> argument) is stationary.
>

 ## Description


 ## Examples
>
> In the following examples, `m` is a solved model object with two of its
> transition variables named `X` and `Y`; the latter is a log variable:
>
>     isstationary(m)
>     isstationary(m, 'X')
>     isstationary(m, 'log(Y)')
>     isstationary(m, 'X - 0.5*log(Y)')
>