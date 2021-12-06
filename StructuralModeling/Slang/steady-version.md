# !!

{== Steady-state versions of equations ==}


## Syntax

    dynamicEquation !! steadyEquation;


## Description

For each transition or measurement equation, you can provide a separate
steady-state version of it. The steady-state version is used when you run
the functions [`steady`](../model/steady.md) and
[`checkSteady`](../model/checkSteady.md), the latter unless you change the
option `EquationSwitch=`. This is useful when you can substantially
simplify some parts of the full dynamic equations, split the model into
sequential blocks, and help therefore the numerical solver to achieve
faster and possibly laso more accurate results.


## Examples

```iris
log(a) = 0.8*log(a{-1}) + (1-0.8)*2 + epsilon_a !! log(a) = 2;
```

The following steady state version of an Euler equation will be  valid only in stationary models
where we can safely remove lags and leads.

```
lambda = lambda{1}*(1+r)*beta !! r = 1/beta - 1;
```


