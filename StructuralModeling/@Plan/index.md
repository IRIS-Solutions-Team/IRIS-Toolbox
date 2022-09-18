---
topic: Plan
---

# Overview of simulation plan objects

{==
Simulation plans define more complex simulation assumptions for various
types of models (structural models, explanatory equations, vector
autoregressions): anticipation status, inversion pairs
(exogenize/endogenize) and conditioning information.
==}


## Categorical list of functions 

### Constructing plan objects 

Function | Description 
---|---
[`Plan.forModel`](forModel.md) | Create simulation Plan for Model object
[`Plan.forExplanatory`](forExplanatory.md) | Create simulation Plan for Explanatory object
[`Plan.forExplanatory`](forSVAR.md) | 


### Specifying anticipation status

Function | Description 
---|---
[`anticipate`](anticipate.md) |


### Exogenizing variables, endogenizing shocks

Function | Description 
---|---
[`autoswap`](autoswap.md) | Exogenize variables and endogenize shocks autoswap pairs
[`swap`](swap.md) | Exogenize variables and endogenize shocks autoswap pairs


