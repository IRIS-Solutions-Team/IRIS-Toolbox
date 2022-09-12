
# Overview of structural model objects


## Categorical list of functions 


### Constructing model objects 

Function | Description 
---|---
[`Model.fromFile`](fromFile.md) | Create new Model object from model source file(s)
[`Model.fromSnippet`](fromSnippet.md) | Create new Model object from snippet of code within m-file
[`Model.fromString`](fromString.md) | Create new Model object from string array


### Getting information about models

Function | Description 
---|---
[`access`](access.md) | Access properties of Model objects
[`beenSolved`](beenSolved.md) | 
[`table`](table.md) | Create table based on selected indicators from Model object
[`solutionMatrices`](solutionMatrices.md) | Access first-order state-space (solution) matrices
[`byAttributes`](byAttributes.md) | 
[`findEquation`](findEquation.md) | 
[`getBounds`](getBounds.md) | 
[`isLinkActive`](isLinkActive.md) |
[`isLinear`](isLinear.md) |
[`isLog`](isLog.md) |
[`print`](print.md) |
[`table`](table.md) |


### Assigning values within models

Function | Description 
---|---
[`assign`](assign.md) | 
[`assignFromModel`](assignFromModel.md) | 
[`replaceNames`](replaceNames.md) | Replace model names with some other names
[`reset`](reset.md) | Reset specific values within model object
[`resetBounds`](resetBounds.md) | 
[`setBounds`](setBounds.md) | 
[`rescaleStd`](rescaleStd.md) | Rescale all std deviations by the same factor


### Analytical properties of models

Function | Description 
---|---
[`analyticGradients`](analyticGradients.md) |
[`blazer`](blazer.md) |
[`eig`](eig.md) |
[`systemMatrices`](systemMatrices.md) |



### Stochastic properties of models

Function | Description 
---|---
[`acf`](acf.md) |
[`bn`](bn.md) |
[`fevd`](fevd.md) |
[`ffrf`](ffrf.md) |
[`fmse`](fmse.md) |


### Solving and simulating models 

Function | Description 
---|---
[`checkSteady`](checkSteady.md) | Check if equations hold for currently assigned steady-state values
[`checkInitials`](checkInitials.md) |
[`expand`](expand.md) |
[`simulate`](simulate.md) | Run a model simulation
[`solve`](solve.md) | Calculate first-order solution matrices
[`steady`](steady.md) | Compute steady state or balance-growth path of the model
[`system`](system.md) | System matrices for the unsolved model
[`lhsmrhs`](lhsmrhs.md) |


### Estimating and filtering model quantities

Function | Description 
---|---
[`estimate.md`](estimate.md) | Estimate model parameters by optimizing selected objective function
[`kalmanFilter`](kalmanFilter.md) | Kalman smoother and estimator of out-of-likelihood parameters


### Manipulating the structure of models

Function | Description 
---|---
[`activeLink`](activateLink.md) |
[`deactiveLink`](deactivateLink.md) |
[`alter`](alter.md) |
[`changeGrowthStatus`](changeGrowthStatus.md) |
[`changeLinearStatus`](changeLinearStatus.md) |
[`changeLogStatus`](changeLogStatus.md) |

