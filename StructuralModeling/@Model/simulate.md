# `simulate`

{== Run a model simulation ==}


## Syntax 

    [outputDb, outputInfo, frameDb] = simulate(model, inputDb, range, ...)


## Input Arguments 

__`model`__ [ Model ]
> 
> Model object with a valid solution avalaible for each of its parameter
> variants.
>

__`inputDb`__ [ struct | Dictionary ]
>
> Input databank from which the following data will be retrieved:
>
> * initial conditions for the lags of transition variables; use
>   `access(model, "initial-conditions")` to get the list of 
>
> exogenized data points for the simulation.
> 

__`range`__ [ DateWrapper | numeric ]
>
> Simulation range; only the start date (the first element in `range`) and
> the end date (the last element in `range`) are considered.
> 

## Output Arguments 


__`outputDb`__ [ struct | Dictionary ]
> 
> Databank (struct or Dictionary) with the simulation results; if options
> `PrependInput=` or `AppendInput=` are not used, the time series in
> `outputDb` span the simulation `range` plus all necessary initial
> conditions for those variables that have lags in the model.
> 

__`outputInfo`__ [ struct ]
> 
> Info struct with details on the simulation; the `outputInfo` struct
> contains the following fields:
> 
> * `.FrameColumns`
> 
> * `.FrameDates` 
> 
> * `.BaseRange` 
> 
> * `.ExtendedRange` 
> 
> * `.Success` 
> 
> * `.ExitFlags` 
> 
> * `.DiscrepancyTables` 
> 
> * `.ProgressBar` 
> 

__`frameDb`__ [ cell ]
> 
> Only returned nonempty when `Method="stacked"`: Nested cell arrays with
> databanks containing the simulation results of each individual frame; the
> `frameDb{i}{j}` element is the output databank from simulating the j-th
> frame in the i-th variant or data page.
> 

## Options 

__`Method="firstOrder"`__ [ "firstOrder" | "stacked" | "period" ]
> 
> Simulation method: "firstOrder" means using a first-order approximate
> solution, "stacked" means a stacked-time system solved by a
> quasi-Newton method.
> 

__`Deviation=false`__ [ `true` | `false` ]
> 
> If true, both the input data and the output data are (and are expected
> to be) in the form of deviations from steady state:
> 
> * for variables not declared as `log-variables`, the deviations from
> steady state are calculated as a plain difference: $x_t - \bar x_t$
> 
> * for variables declared as `log-variables`, the deviations from
> steady state are calculated as a ratio: $x_t / \bar x_t$.
> 

__`PrependInput=false`__ [ `true` | `false` ]
> 
> If `true`, the data from `inputDb` preceding the simulation range
> will be included in the output time series returned in `outputDb`.
> 

__`AppendInput=false`__ [ `true` | `false` ]
> 
> If `true`, the data from `inputDb` succeeding the simulation range
> will be included in the output time series returned in `outputDb`.
> 

## Description 


## Example 



