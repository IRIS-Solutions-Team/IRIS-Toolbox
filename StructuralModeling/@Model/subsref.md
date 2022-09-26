---
title: subsref
---

# `subsref` ^^(Model)^^

{== Subscripted reference for Model objects ==}


## Syntax for retrieving object with subset of parameter variants

     m(index)


## Syntax for retrieving parameters or steady-state values

     m.name


## Syntax to retrieve std deviations or cross-correlation of shocks

     m.std_shock
     m.corr_shock1__shock2


 Note that a double underscore is used to separate the names of shocks in
 correlation coefficients.


## Input Arguments

__`m`__ [ Model ]
> 
> Model object.
>  


__`index`__ 
> 
> Index (positional or logical) of requested parameterisations.
> 


__`name`__ 
> 
> Name of a variable, shock, or parameter.
> 

__`shock`, `shock1`, `shock2`__
> 
> Names of shocks.
>  

## Description



## Examples

```matlab
```

