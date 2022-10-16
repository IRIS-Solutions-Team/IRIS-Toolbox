
# Overview of data grouping objects

{==
Data grouping objects are used for aggregating the contributions of shocks
in model simulations,
[`Model/simulate`](../../StructuralModeling/@Model/simulate.md), or
aggregating the contributions of measurement variables in Kalman filtering,
[`Model/kalmanFilter`](../../StructuralModeling/@Model/kalmanFilter.md).
==}

## Categorical list of functions 

### Constructing data grouping objecs

Function | Description 
---|---
[`Grouping`](Grouping.md) | Create new empty Grouping object


### Getting information about groups

Function | Description 
---|---
[`detail`](detail.md) | Details of a Grouping object
[`isempty`](isempty.md) | True for empty Grouping object


### Setting up and using groups

Function | Description 
---|---
[`add`](add.md) | Add measurement variable group or shock group to Grouping object
[`remove`](remove.md) | 
[`split`](split.md) | 
[`eval`](eval.md) | Evaluate data groups in input database 

