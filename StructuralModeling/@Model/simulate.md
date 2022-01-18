---
title: simulate
---

# `simulate`

{== Run a model simulation ==}


## Syntax 

    [outputDb, outputInfo, frameDb] = simulate(model, inputDb, range, ___)


## Input arguments 

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
>   `access(model, "initials")` to get the list of the necessary initial
>   conditions;
>  
> * shocks within the simulation range; if shocks are missing, the default
>   zero value is used in the simulation;
>  
> * data points for the transition variables exogenized in the simulation
>   `Plan` (entered optionally through the `plan=` option);
>  
> * initial paths for transition variables in nonlinear simulations
>   (`method="stacked"` or `method="period"`) when the initial iteration is
>   requested to be taken from the input data and not the default
>   first-order simulation, `startIterationsFrom="data"`.
> 

__`range`__ [ DateWrapper | numeric ]
> 
> Simulation range; the simulation range is always from the first date to
> the last date specified in the `range`.
> 


## Output arguments 

__`outputDb`__ [ struct | Dictionary ]
> 
> Databank (struct or Dictionary) with the simulation results; if options
> `prependInput=` or `appendInput=` are not used, the time series in
> `outputDb` span the simulation `range` plus all necessary initial
> conditions for those variables that have lags in the model.
> 

__`outputInfo`__ [ struct ]
> 
> Info struct with details on the simulation; the `outputInfo` struct
> contains the following fields:
>  
> * `.FrameColumns`
> * `.FrameDates` 
> * `.BaseRange` 
> * `.ExtendedRange` 
> * `.Success` 
> * `.ExitFlags` 
> * `.DiscrepancyTables` 
> * `.ProgressBar` 
> 

__`frameDb`__ [ cell ]
> 
> Only returned nonempty when `method="stacked"`: Nested cell arrays with
> databanks containing the simulation results of each individual frame; the
> `frameDb{i}{j}` element is the output databank from simulating the j-th
> frame in the i-th variant or data page.
> 


## Options 

__`method="firstOrder"`__ [ "firstOrder" | "stacked" | "period" ]
> 
> Simulation method:
>  
> * `method="firstOrder"` - use a first-order approximate solution;
>  
> * `method="stacked"` - solve the model numerically as a
>   stacked-time system of nonlinear-equations using a quasi-Newton method.
>  
> * `method="period"` - solve the model numerically as a system of
>   nonlinear-equations period by period using a quasi-Newton method; in
>   forward-looking models, the model-consistent expectations are replaced
>   with the values found in the `inputDb`
>  
> The nonlinear simulation methods also further use the `solver=` option to
> specify the settings for the nonlinear solver.
> 

__`deviation=false`__ [ `true` | `false` ]
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

__`prependInput=false`__ [ `true` | `false` ]
> 
> If `true`, the data from `inputDb` preceding the simulation range
> will be included in the output time series returned in `outputDb`.
> 

__`appendInput=false`__ [ `true` | `false` ]
> 
> If `true`, the data from `inputDb` succeeding the simulation range
> will be included in the output time series returned in `outputDb`.
> 

__`solver=@auto`__ [ `@auto` | string | cell ] 
>  
> The name of the numerical solver to use for solving nonlinear simulations
> (`method="stacked"` or `method="period"`), optionally also with solver
> settings; see Description.
> 

## Description 


### Numerical solver settings in nonlinear simulations

When `method="stacked"` or `method="period"`, the model is solved as a
nonlinear system of equations using an IrisT quasi-Newton solver. There are two
basic varieties of the numerical solver in IrisT:

* a quasi-Newton, called `"iris-newton"`; this is a traditional Newton
  algorithm with optional step size optimization;

* a quasi-Newton-steepest-descent, called `"iris-qnsd"`; this solver
  combines the quasi-Newton step with a Cauchy (steepest descent) step and
  regularizes the Jacobian matrix in the process.

For most simulations, the `"iris-newton"` (which is the default choice) is
the appropriate choice; however, you can still modify some of the settings
by specifying a cell array whose first element is the name of the solver
(`"newton"` or `"qnsd"`) followed by any number of name-value
pairs for the individual settings; for instance:

```matlab
outputDb = simulate( ...
    model, inputDb, range ...
    , method="stacked" ...
    , solver={"iris-newton", "maxIterations", 100, "functionTolerance", 1e-5} ...
);
```

See [Numerical solver settings](../../numerical-utilities/solver/index.md)
for the description of all settings.


## Example 



