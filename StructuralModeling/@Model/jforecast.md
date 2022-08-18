---
title: jforecast
---

# `jforecast`

{== Forecast with judgmental adjustments (conditional forecasts). ==}


## Syntax 

    F = jforecast(SolvedModel, InputData, Range, ...)


## Input arguments 

 `SolvedModel` [ model ]
>
> Solved model object.
>

 `InputData` [ struct ] 
> 
> Input data from which the initial condition is taken.
>

 `Range` [ numeric ] 
>
> Forecast range.
>


## Output arguments 

`F` [ struct ]
> 
> Output struct with the judgmentally adjusted forecast.
> 


## Options 

`Anticipate=true` [ `true` | `false` ]
> 
> If true, real future shocks are anticipated,
> imaginary are unanticipated; vice versa if false.
>
 `CurrentOnly=true` [ `true` | `false` ] 
> 
> If `true`, MSE matrices will
> be computed only for the current-dated variables, not for their lags or
> leads (expectations).
>

 `Deviation=false` [ `true` | `false` ] 
> 
> Treat input and output data as
> deviations from balanced-growth path.
>

 `Dtrends=@auto` [ `@auto` | `true` | `false` ] 
> 
> Measurement data
> contain deterministic trends.
>

 `InitCond='data'` [ `'data'` | `'fixed'` ] 
> 
> Use the MSE for the
> initial conditions if found in the input data or treat the initial
> conditions as fixed.
>

 `InitCondMSE=@auto` [ `@auto` | numeric | `0` ]
> 
> MSE for the initial
> condition of the vector of backward looking variables, including their
> auxiliary lags.
>

 `MeanOnly=false` [ `true` | `false` ]
> 
> Return only mean data, i.e.
> point estimates.
>

 `Plan=[ ]` [ plan | empty ]
> 
> Forecast plan specifying exogenized
> variables, endogenized shocks, and conditioning variables.
>

 `StdScale=1` [ numeric | complex | `'normalize'` ]
> 
> Scale standard
> deviations of shocks by this factor; if `StdScale=` is a complex number,
> stdevs for anticipated and unanticipated shocks will be scaled
> differently. See Description/Std Deviations.
>

 `Override=[ ]` [ struct | empty ] 
> 
> Database with time-varying std
> deviations or cross-correlations of shocks.
>

 ## Description 

>
> Function `jforecast( )` provides similar functionality as `simulate( )`
> but differs in a number of ways:
>
> `jforecast( )` returns also standard deviations for the forecasts of
> model variables;
>
> `jforecast( )` can use conditioning (specified in a `plan` object)
> techniques in addition to exogenizing techniques; conditiong and
> exogenizing techniques can be combined together.
>
> `jforecast( )` only works with first-order approximate solution; no
> nonlinear technique is available.
>
>
> ### Anticipated and Unanticipated Shocks
>
> When adjusting the mean of shocks (in the input database, `InputData`) or
> the std deviations of shocks (in the option `Override=`), you can use
> real and imaginary numbers to distinguish between anticipated and
> unanticipated shocks (depending on the `Anticipate=` option):
>
> if `Anticipate=true` then real numbers describe anticipated shocks and
> imaginary numbers describe unanticipated shocks;
>
> if `Anticipate=false` then real numbers describe unanticipated shocks
> and imaginary numbers describe anticipated shocks;
>



## Examples

