
# Overview of explanatory equation objects

{==
Explanatory equations are systems of sequential (non-simultaneous)
equations that can be estimated and executed (simulated) one after another.
The advantage over the structural models is faster evaluation, especially
for nonlinear equations.
==}


## Categorical list of functions 


### Constructing explanatory equation objects 

Function | Description 
---|---
[`Explanatory.fromFile`](fromFile.md) |
[`Explanatory.fromString`](fromString.md) |
[`Explanatory.fromModel`](fromModel.md) |


### Getting information about explanatory equations

Function | Description 
---|---
[`collectResidualNames`](collectResidualNames.md) | Collect names of LHS variables


### Estimating parameters

Function | Description 
---|---
[`regress.md`](regress.md) | Estimate parameters and residual models in Explanatory object 


### Simulating explanatory equations

Function | Description 
---|---
[`simulate.md`](simulate.md) | 

