---
title: databank.minusControl
---

# `databank.minusControl` ^^(+databank)^^

{== Create simulation-minus-control database ==}


## Syntax 

    [outputDb, controlDb] = databank.minusControl(model, inputDb, ...)
    [outputDb, controlDb] = databank.minusControl(model, inputDb, controlDb, ...)


## Input arguments 

__`model` [ model ]
> 
> Model object on which the databases `inputDb` and `controlDb`__ are
> based.
> 

__`inputDb`__ [ struct ]
> 
> Simulation (or any other kind of) databank from which the `controlDb`
> will be subtracted.
> 

^__`controlDb` [ struct ]
> 
> Control database that will be subtracted form the `inputDb`; if omitted a
> steady-state databank for the `model` is created and used in the place of
> the control databank.
> 

## Output arguments 

__`outputData`__ [ struct ]
> 
> Simulation-minus-control database, in which all log variables are
> `inputDb.x/controlDb.x`, and all other variables are
> `inputDb.x-controlDb.x`.
> 

__`controlDb`__ [ struct ]
> 
> Control database that has been subtracted from the `inputDb` database to
> create `outputDb`.
> 

## Options 

__`Range=Inf`__ [ Dater | `Inf` ]

> This range is used in two places:
> 
> * if a `controlDb` is not supplied, the `model` steady-state databank is
>   created with the `Range=` input argument (meaning the control
>   databank will exist on this range plus any necessary presample and
>   postsample periods); if `opt.Range` refers to
>   `-Inf` or `Inf`, then the control databank is created on an
>   all-encompassing range of the `inputDb`.
> 
> * each `model` variable time series is clipped to the `Range=` before
>   being included in the `outputDb`.
> 

## Description 


## Example 

Run a shock simulation in full levels using a steady-state (or
balanced-growth-path) database as input, and then compute the deviations
from the steady state:

```matlab
d = steadydb(m, 1:40);
% Set up a shock or shocks here
s = simulate(m, d, 1:40, prependInput=true);
s = databank.minusControl(m, s, d);
```

or simply

```matlab
    s = databank.minusControl(m, s);
```

The above block of code is equivalent to this one:

```matlab
    d = zerodb(m, 1:40);
    % Set up a shock or shocks here
    s = simulate(m, d, 1:40, deviation=true, prependInput=true);
```

