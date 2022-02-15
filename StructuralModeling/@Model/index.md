
# Overview of structural model objects


## Categorical list of functions 


### Constructing model objects 

Function | Description 
---|---
[`Model.fromFile`](fromFile.md)                              | Create new Model object from model source file(s)
[`Model.fromSnippet`](fromSnippet.md)                        | Create new Model object from snippet of code within m-file
[`Model.fromString`](fromString.md)                          | Create new Model object from string array


### Getting information about models

Function | Description 
---|---
[`analyticGradients`](analyticGradients.md)                  | Evaluate analytic/symbolic derivatives of model equations
[`access`](access.md)                                        | Access properties of Model objects
[`table`](table.md)                                          | Create table based on selected indicators from Model object
[`solutionMatrices`](solutionMatrices.md)                    | Access first-order state-space (solution) matrices


### Assigning values within models

Function | Description 
---|---
[`replaceNames`](replaceNames.md)                            | Replace model names with some other names
[`reset`](reset.md)                                          | Reset specific values within model object
[`rescaleStd`](rescaleStd.md)                                | Rescale all std deviations by the same factor


### Solving and simulating models 

Function | Description 
---|---
[`checkSteady`](checkSteady.md)                              | Check if equations hold for currently assigned steady-state values
[`simulate`](simulate.md)                                    | Run a model simulation
[`solve`](solve.md)                                          | Calculate first-order solution matrices
[`steady`](steady.md)                                        | Compute steady state or balance-growth path of the model
[`system`](system.md)                                        | System matrices for the unsolved model


### Estimating and filtering model quantities

Function | Description 
---|---
[`estimate.md`](estimate.md)                                 | Estimate model parameters by optimizing selected objective function
[`kalmanFilter`](kalmanFilter.md)                            | Kalman smoother and estimator of out-of-likelihood parameters

