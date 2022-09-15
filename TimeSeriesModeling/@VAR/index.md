
# Overview of VAR objects

VAR objects can be constructed as plain VARs or simple panel VARs (with
fixed effect), and estimated without or with prior dummy observations
(quasi-bayesian VARs). VAR objects are reduced-form models but they are also
the point of departure for identifying [structural VARs](../@SVAR/index.md)

VAR models in IRIS have the following form:

$$
y_t = \sum_{k=1}^{p} A_k\, y_{t-k} + K + J g_t + \epsilon_t
$$

where

* $y_t$ is an $n$-by-1 vector of endogenous variables;
* $A_k$ are transition matrices at lags 1, ..., k;
* $K$ is a vector of intercepts;
* $g_t$ is a vector of exogenous variables;
* $J$ is the impact matrix of exogenous variables;
* $\epsilon_t$ is a vector of forecast (reduced-form) errors, with $\Omega=\mathrm{E}[\epsilon_t \epsilon_t']$.



## Categorical list 

### Constructor

Function | Description 
---|---
[`VAR`](VAR.md) | Create new empty reduced-form VAR object


### Properties Directly Accessible

Function | Description 
---|---
[`object.A`](A.md) | Transition matrices with higher orders concatenated horizontally
[`object.K`](K.md) | Vector of intercepts (constant terms)
[`object.J`](J.md) | Impact matrix of exogenous variables
[`object.Omega`](Omega.md) | Covariance matrix of reduced-form forecast errors
[`object.Sigma`](Sigma.md) | Covariance matrix of parameter estimates
[`object.AIC`](AIC.md) | Akaike information criterion
[`object.AICc`](AICc.md) | Akaike information criterion corrected for small sample
[`object.SBC`](SBC.md) | Schwarz bayesian criterion
[`object.EigenValues`](EigenValues.md) | Eigenvalues of VAR transition matrix
[`object.EigenStability`](EigenStability.md) | Stability indicator for each eigenvalue
[`object.Range`](Range.md) | Estimation range entered by user
[`object.InxFitted`](InxFitted.md) | Logical index of dates in estimation range acutally fitted
[`object.EndogenousNames`](EndogenousNames.md) | Names of endogenous variables
[`object.ResidualNames`](ResidualNames.md) | Names of errors
[`object.ExogenousNames`](ExogenousNames.md) | Names of exogenous variables
[`object.GroupNames`](GroupNames.md) | Names of groups in panel VARs
[`object.ConditioningNames`](ConditioningNames.md) | Names of conditioning instruments
[`object.NumEndogenous`](NumEndogenous.md) | Number of endogenous variables
[`object.NumResiduals`](NumResiduals.md) | Number of errors
[`object.NumExogenous`](NumExogenous.md) | Number of exogenous variables
[`object.NumGroups`](NumGroups.md) | Number of groups in panel VARs
[`object.NumConditioning`](NumConditioning.md) | Number of conditioning instruments


### Getting Information about VAR Objects

Function | Description 
---|---
[`addToDatabank`](addToDatabank.md) | Add VAR parameters to databank or create new databank
[`comment`](comment.md) | Get or set user comments in an IRIS object
[`companion`](companion.md) | Matrices of first-order companion VAR
[`eig`](eig.md) | Eigenvalues of a VAR process
[`fprintf`](fprintf.md) | Write VAR model as formatted model code to text file
[`get`](get.md) | Query VAR object properties
[`testCompatible`](testCompatible.md) | True if two VAR objects can occur together on the LHS and RHS in an assignment
[`isexplosive`](isexplosive.md) | True if any eigenvalue is outside unit circle
[`isstationary`](isstationary.md) | True if all eigenvalues are within unit circle
[`length`](length.md) | Number of parameter variants in VAR object
[`mean`](mean.md) | Asymptotic mean of VAR process
[`nfitted`](nfitted.md) | Number of data points fitted in VAR estimation
[`rngcmp`](rngcmp.md) | True if two VAR objects have been estimated using the same dates
[`sprintf`](sprintf.md) | Print VAR model as formatted model code
[`sspace`](sspace.md) | Quasi-triangular state-space representation of VAR
[`userdata`](userdata.md) | Get or set user data in an IRIS object


### Referencing VAR Objects

Function | Description 
---|---
[`group`](group.md) | Retrieve VAR object from panel VAR for specified group of data
[`subsasgn`](subsasgn.md) | Subscripted assignment for VAR objects
[`subsref`](subsref.md) | Subscripted reference for VAR objects


### Simulation, Forecasting and Filtering

Function | Description 
---|---
[`ferf`](ferf.md) | Forecast error response function
[`filter`](filter.md) | Filter data using a VAR model
[`forecast`](forecast.md) | Unconditional or conditional VAR forecasts
[`instrument`](instrument.md) | Define forecast conditioning instruments in VAR models
[`resample`](resample.md) | Resample from a VAR object
[`simulate`](simulate.md) | Simulate VAR model


### Manipulating VARs

Function | Description 
---|---
[`assign`](assign.md) | Manually assign system matrices to VAR object
[`alter`](alter.md) | Expand or reduce the number of alternative parameterisations within a VAR object
[`backward`](backward.md) | Backward VAR process
[`demean`](demean.md) | Remove constant and the effect of exogenous inputs from VAR object
[`horzcat`](horzcat.md) | Combine two compatible VAR objects in one object with multiple parameterisations integrate - Integrate VAR process and data associated with it
[`xasymptote`](xasymptote.md) | Set or get asymptotic assumptions for exogenous inputs


### Stochastic Properties

Function | Description 
---|---
[`acf`](acf.md) | Autocovariance and autocorrelation functions for VAR variables
[`fmse`](fmse.md) | Forecast mean square error matrices
[`vma`](vma.md) | Matrices describing the VMA representation of a VAR process
[`xsf`](xsf.md) | Power spectrum and spectral density functions for VAR variables


### Estimation, Identification, and Statistical Tests

Function | Description 
---|---
[`estimate`](estimate.md) | Estimate a reduced-form VAR or BVAR
[`infocrit`](infocrit.md) | Populate information criteria for a parameterised VAR
[`lrtest`](lrtest.md) | Likelihood ratio test for VAR models
[`portest`](portest.md) | Portmanteau test for autocorrelation in VAR residuals
[`schur`](schur.md) | Compute and store triangular representation of VAR

