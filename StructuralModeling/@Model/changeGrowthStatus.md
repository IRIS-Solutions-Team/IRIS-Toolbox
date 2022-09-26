---
title: changeGrowthStatus
---

# `changeGrowthStatus` ^^(Model)^^

{== Change growth status of the model ==}


## Syntax 

    m = changeGrowthStatus(m, growth)


## Input arguments 

__`m`__ [ Model ]
> 
> Model object whose growth status will be changed.
> 


__`growth`__ [ `true` | `false` ]
> 
> New growth status for model `m`; if `growth=false`, the steady state of
> the model will be calculated assuming no variable is changing over time
> in steady state; if `growth=true`, variables are allowed to change over
> time at a constant first difference or a constant rate of growth.
> 


## Output arguments 

__`m`__ [ Model ]
> 
> Model object with a new `growth` status.
> 


## Description 



## Examples

Turn of growth in productivity (gross rate of change), and recalculate the
steady state of the model.

```matlab
m.roc_a = 1;
m = changeGrowthStatus(m, false);
m = steady(m);
```

