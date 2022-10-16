---
title: databank.forModel
---

# `databank.forModel` ^^(+databank)^^

{== Create model specific databank ==}


## Syntax

    db = databank.forModel(model, range, ___)


## Input arguments


__`model`__ [ Model ]
> 
> Model object for which the databank will be created; 
> 


__`range`__ [ Dater ]
> 
> Date range on which the time series in the output `db` will be created.
> 


## Output arguments


__`db`__ [ struct | Dictionary ]
> 
> The output `db` will contain a time series for each variable and shock,
> and a numerical values for each parameter. Each time series will be
> automatically prepeneded a sufficient number of periods before the start
> of the input `range` to cover the model's initial conditions, and
> appended a sufficient number of periods after the end of the input
> `range` to cover the model's terminal condition.
> 


## Options

__`Deviation=false` [ `true` | `false` ]
> 
> `Deviation=false` means the time series in the output `db` contain the
> steady-state lines; `Deviation=true` means the time series in the output
> `db` are filled with ones (for log-variables) or zeros (for other
> variables and shocks).
> 

__`ShockFunc=@zeros`__ [ function ] 
> 
> Function used to generate shocks; each shock is then corrected for its
> std deviation currently assigned in the model object.
> 


__`NumColumns=1`__ [ numeric ]
> 
> Number of columns created for each time series in the output `db`; only
> works when the input `model` object has only one single parameter
> variant.
> 


__`NumDraws=1`__ [ numeric ]
> 
> Number of columns created for each time series in the output `db` with
> the time series for shocks randomly drawn than many times; only
> works when the input `model` object has only one single parameter
> variant; cannot be combined with `NumColumns>1`.
> 

## Description


## Examples

```matlab
d = databank.forModel(m, qq(2025,1):qq(2030,4));
```

