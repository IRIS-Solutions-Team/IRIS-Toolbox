---
title: subsref
---

{== Subscripted reference for model objects ==}


## Syntax for Retrieving Object with Subset of Parameter Variants

     m(index)


## Syntax for Retrieving Parameters or Steady-State Values

     m.name


## Syntax to Retrieve Std Deviations or Cross-correlation of Shocks

     m.std_shock
     m.corr_shock1__shock2


 Note that a double underscore is used to separate the names of shocks in
 correlation coefficients.


## Input Arguments

 __`m`__ [ model ] -
 Model object.

 __`index`__ [ numeric | logical ] -
 Index (positional or logical) of requested parameterisations.

 __`name`__ -
 Name of a variable, shock, or parameter.

 __`shock`, `shock1`, `shock2`__ -
 Names of shocks.


## Description



## Examples

```matlab
```

