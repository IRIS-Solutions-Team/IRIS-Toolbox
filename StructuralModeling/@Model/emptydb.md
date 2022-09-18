---
title: emptydb
---

# `emptydb` ^^(Model)^^

{== Create model database with empty time series for each variable and shock==}



 ## Syntax

     outputDatabank = emptydb(m)


 ## Input arguments

  `m` [ model ] 
>
> Model for which the empty database will be created.
>

 ## Output arguments

  `outputDatabank` [ struct ]
>
> Databank with an empty time series for
> each variable and each shock, and a vector of currently assigned values
> for each parameter.
>

 ## Options

  `Include=@all` [ char | cellstr | string | `@all` ] 
>  
> Types of
> quantities that will be included in the output databank; `@all` means all
> variables, shocks and parameters will be included; see Description.
>

  `Size=[0, 1]` [ numeric ]
>  
> Size of the empty time series; the size in
> first dimension must be zero.
>

 ## Description
>
> The output databank will, by default, include an empty time series for
> each measurement and transition variable, and measurement and transition
> shock, as well as a numeric array for each parameter. To create a
> databank with only some of these quantities, use the option `Include=`,
> and assign a cellstr or a string array combining the following:
>
>  `Variables` to include measurement and transition variables;
>  `MeasurementVariables` to include measurement variables;
>  `TransitionVariables` to include transition variables;
>  `Shocks` to include measurement and transition shocks;
>  `MeasurementShocks` to include measurement shocks;
>  `TransitionShocks` to include transition shocks;
>  `Parameters` to include parameters;
>  `Std` to include std deviations of shocks.
>

 ## Examples

