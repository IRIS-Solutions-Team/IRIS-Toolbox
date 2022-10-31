---
title: kalmanFilter
---

# `kalmanFilter` ^^(Model)^^

{== Kalman filter and smoother, and estimator of out-of-likelihood parameters ==}


## Syntax

    [outputDb, outputModel, info] = kalmanFilter(inputModel, inputData, filterRange, ...)


## Input arguments

__`inputModel`__ [ Model ]
> 
> A solved Model object whose state-space representation will be used to
> run a linear Kalman filter on the `inputData` observations.
> 

__`inputData`__ [ struct | Dictionary ] 
> 
> Input databank from which the observations for measurement variables on
> the `filterRange` will be taken.
> 

__`filterRange`__ [ numeric | char ]
> 
> The range on which the Kalman filter will be run.
> 

## Output arguments


__`outputDb`__ [ struct | Dictionary ]
> 
> Output databank (possibly a nested databank) with the requested data; the
> type of output data are requested through the option `Output=`.
> 

__`outputModel`__ [ Model ]
> 
> Model object with the std deviation of shocks updated (if
> `Relative=true`) and/or the out-of-likelihood parameters updated (if
> `Outlik=` is non-empty).
> 

__`info`__ [ struct ]
> 
> Output information struct with the following fields:
> 
> `.V` - Estimated variance scale factor if the `Relative=`
options is true; otherwise `V` is 1.
> 
> * `.Delta` - Struct with the estimates of out-of-likelihood parameters.
> 
> * `.PE` - Databank with prediction errors for measurement variables.
> 
> * `.SCov` - Sample covariance matrix of smoothed shocks; the
> covariance matrix is computed using shock estimates in periods that are
> included in the option `ObjRange=` and, at the same time, contain at
> least one observation of measurement variables.
> 
> * `.init` - Initial conditions used in the Kalman filter;
> `init{1}` is the initial mean of the vector of transformed state
> variables, `init{2}` is the MSE matrix.
> 

## Options to control output data returned

__`"FlattenOutput=true`"__ [ `true` | `false` ]
> 
> Make the `outputDb` as flat as possible by removing nested levels if they
> are empty or squeezing them if they only contain one field.
> 


__`MatrixFormat="namedMatrix"`__ [ `"namedMatrix"` | `"numeric"` ]
> 
> Format (class) output matrices included in the output `info` struct:
> 
> * `"namedMatrix"` - return NamedMatrix objects where the individual rows
>   and columns have variable names attached
> 
> * `"numeric"` - return plain numeric arrays
> 


__`MeanOnly=false`__ [ `true` | `false` ]
> 
> Return the mean data (point estimates) only in the `outputDb`.
> 
> 


__`OutputData="smooth"`__ [ string | `"predict"` | `"filter"` | `"smooth"` ]
> 
> Choose which Kalman filter steps will be included in the `outputDb`:
> 
> * `"smooth"` - include data from the backward smoother (two-sided
>   filtering)
> 
> * `"update"` - include data from the updating steep (one-sided filtering)
> 
> * `"predict"` - include data from the prediction step
> 


__`ReturnMedian=true`__ [ `true` | `false` ]
> 
> Return a databank with the median estimates of the model variables; the
> meians are calculated by delogarithmizing the log-variables; the medianss
> for other variables is identical to the means. This option only works
> when `MeanOnly=false`.
> 


__`ReturnBreakdown=false`__ [ `true` | `false` ]
> 
> Return contributions of prediction errors in measurement variables to the
> estimates of all variables and shocks. This option only works when
> `MeanOnly=false`.
> 


__`ReturnMse=true`__ [ `true` | `false` ]
> 
> Return MSE matrices for predetermined state variables; these can be used
> for settin up initial condition in subsequent call to another
> `kalmanFilter()`. This option only works when `MeanOnly=false`.
> 


__`ReturnStd=true`__ [ `true` | `false` ]
> 
> Return databank with std devs of model variables. This option only works
> when `MeanOnly=false`.
> 


## Options to control the calculation within the Kalman filter

__`Ahead=1`__ [ numeric ]
> 
> Calculate predictions up to `Ahead` periods
> ahead.
> 

__`ChkFmse=false`__ [ `true` | `false` ]
> 
> Check the condition number of
> the forecast MSE matrix in each step of the Kalman filter, and return
> immediately if the matrix is ill-conditioned; see also the option
> `FmseCondTol=`.
> 

__`Condition={ }`__ [ char | cellstr | empty ]
> 
> List of conditioning measurement variables. Condition time t|t-1 prediction errors (that enter the likelihood function) on time t
> observations of these measurement variables.
> 

__`Deviation=false`__ [ `true` | `false` ]
> >
> Treat input and output data as
> deviations from balanced-growth path.
> 

__`Dtrends=@auto`__ [ `@auto` | `true` | `false` ]
> 
> Measurement data contain deterministic trends; `@auto` means `DTrends=`
> will be set consistently with `Deviation=`.
> 

__`FmseCondTol=eps( )`__ [ numeric ]
> 
> Tolerance for the FMSE condition number test; not used unless
> `ChkFmse=true`.
> 

__`InitCond="Stochastic"`__ [ `"fixed"` | `"optimal"` | `"stochastic"` | struct ]
> 
> The method or data that will be used initialise the Kalman filter;
> user-supplied initial condition must be a databank with the mean values
> (in which case the MSE of the initial condition will be set to zero) or a
> nested databank containing sub-databanks named `.Mean` (or `.Median`) and `.MSE`.
> 

__`UnitRootInitials="approxDiffuse"`__ [ `"approxDiffuse"` | `"fixedUnknown"` | `"preiterate"` ]
> 
> Method of initializing the MSE matrix for unit root variables; see Description.
> 


__`Preiterate=0`__ [ numeric ]
>
> Number of preiteration periods to initialize the MSE matrix for
> unit root variables when `UnitRootInitials="preiterate"`; `Preiterate=0`
> is equivalent to `"UnitRootInitials="fixedUnknown"`.
> 


__`LastSmooth=Inf`__ [ numeric ]
> 
> Last date up to which to smooth data backward from the end of the
> filterRange; `Inf` means the smoother will run on the entire filterRange.
> 

__`Outlik={ }`__ [ cellstr | empty ]
> 
> List of parameters in deterministic trends that will be estimated by
> concentrating them out of the likelihood function.
> 

__`ObjFunc='-LogLik'`__ [ `'-LogLik'` | `'PredErr'` ]
> 
> Objective function computed; can be either minus the log likelihood
> function or weighted sum of prediction errors.
> 

__`ObjRange=Inf`__ [ DateWrapper | `Inf` ]
> 
> The objective function will be
> computed on the specified filterRange only; `Inf` means the entire filter
> filterRange.
> 

__`Relative=true`__ [ `true` | `false` ]
> 
> Std devs of shocks assigned in the model object will be treated as
> relative std devs, and a common variance scale factor will be estimated.
> 

__`Weighting=[ ]`__ [ numeric | empty ]
> 
> Weighting vector or matrix for prediction errors when
> `ObjFunc='PredErr'`; empty means prediction errors are weighted equally.
> 


## Options for time-varying std deviations, correlations and means of shocks


__`Multiply=[ ]`__ [ struct | empty ]
> 
> Databank with time series of
> possibly time-varying multipliers for std deviations of shocks; the
> numbers supplied will be multiplied by the std deviations assigned in
> the model object to calculate the std deviations used in the filter. See
> Description.
> 

__`Override=[ ]`__ [ struct | empty ]
> 
> Databank with time series for
> possibly time-varying paths for std deviations, correlations
> coefficients, or medians of shocks; these paths will override the values
> assigned in the model object. See Description.
> 


## Options for models with nonlinear equations simulated in prediction step


__`Simulate=false`__ [ `false` | cell ]
> 
> Use the backend algorithms from the [`simulate`](model/simulate) function
> to run nonlinear simulation for each prediction step; specify options
> that will be passed into `simulate` when running a prediction step.
> 


## Description

Run a Kalman filter based on the `inputModel`
The option `Ahead=` cannot be combined with one another, or with multiple
data sets, or with multiple parameterisations.


### Initial Conditions in Time Domain

By default (with `InitCond='Stochastic'`), the Kalman filter starts
from the model-implied asymptotic distribution. You can change this
behaviour by setting the option `InitCond=` to one of the following
four different values:

__`'Fixed'`__ -- the filter starts from the model-implied asymptotic mean
(steady state) but with no initial uncertainty. The initial condition is
treated as a vector of fixed, non-stochastic, numbers.

__`'Optimal'`__ -- the filter starts from a vector of fixed numbers that
is estimated optimally (likelihood maximising).

* databank (i.e. struct with fields for individual model variables) -- a
databank through which you supply the mean for all the required initial
conditions, see help on [`model/get`](model/get) for how to view the list
of required initial conditions.

* mean-mse struct (i.e. struct with fields `.mean` and `.mse`) -- a struct
through which you supply the mean and MSE for all the required initial
conditions.


### Initialization of Unit Root (Nonstationary, Diffuse) Processes

Two methods are available to initialize unit-root (nonstationary,
diffuse) elements in the state vector. In either case, the Kalman filter
works with a system where the state vector is transformed so that its
transition matrix is upper diagonal, with unit roots concentrated in the
top left corner.

* Fixed unknown quantities. This is the default method (for backward
compatibility reasons), and corresponds to setting
`InitUnit='FixedUnknown'`.  The initial conditions for unit-root
processes are treated as fixed unknown elements, and uses a Rosenberg
(1973) algorithm to compute the optimal estimates of these. The algorithm
is completely described in section 3.4.4. of Harvey (1990) "Forecasting,
Structural Time Series Models and the Kalman Filter", Cambridge
University Press.

* Approximate diffuse. The other method is used when
`InitUnit='ApproxDiffuse'`.  This alternative method treats the initial
conditions for unit-root processes as a diffuse distribution (with
infinitely large variances) approximating the true diffuse distribution
by scaling up the appropriate elements of the initial covariance matrix
(by a sufficiently large factor in proportion to the remaining parts of
the matrix). This method is described e.g. in Harvey & Phillips (1979)
"Maximum Likelihood Estimation of Regression Models with Autoregressive-
Moving Average Disturbances" Biometrika 66(1).


### Contributions of measurement variables to estimates of all variables

Use the option `ReturnCont=true` to request the decomposition of
measurement variables, transition variables, and shocks into the
contributions of each individual measurement variable. The resulting
output databank will include one extra subdatabank called `.cont`. In
the `.cont` subdatabank, each time series will have Ny columns where Ny
is the number of measurement variables in the model. The k-th column will
be the contribution of the observations on the k-th measurement variable.

The contributions are additive for linearised variables, and
multiplicative for log-linearised variables (log variables). The
difference between the actual path for a particular variable and the sum
of the contributions (or their product in the case of log varibles) is
due to the effect of constant terms and deterministic trends.


### Time variation in std deviations, correlations and means of shocks

The options `Multiply=` and `Override=` modify the std deviations,
correlation coefficients or medians of shocks within the filter range,
allowing them also to vary over time. Create a time series and specify
observations for each std deviation, correlation coefficient, or median
(mean) that you want to deviate from the values currently assigned in the
model object. The time series supplied do not need to stretch over the
entire filter range: in the periods not specified, the values currently
assigned in the model object will be assumed. 

The option `Override=` simply overrides the std deviations, correlations
or medians (means) of the shocks whenever specified. 

The option `Mutliply=` can be used to supply multipliers for std
deviations. The numbers entered will be multiplied by the std deviations
to obtain the final std deviations used in the filter.

To alter the median (mean) of a shock, supply a time series named after
the shock itself. To alter the std deviation of a shock, use the name of
that std deviation, i.e. `std_xxx` where `xxx` is the name of the shock.
To alter the correlation coefficient between two shocks, use the name of
that correlation coefficient, i.e. `corr_xxx__yyy` where `xxx` and `yyy`
are the names of the shocks (mind the double underscore between `xxx` and
`yyy`).


## Example


