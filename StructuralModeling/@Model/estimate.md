---
title: estimate
---

# `estimate` ^^(Model)^^

{== Estimate model parameters by maximizing posterior-based objective function ==}


## Syntax

Input arguments marked with a `~` sign may be omitted.

    [summary, poster, proposalCov, hess, mEst] ...
        = estimate(m, inputDb, range, estimSpecs, ~SystemPriors, ...)


## Input arguments

__`m`__ [ model ]
>
> Model object with single parameterization.
> 


__`inputDb`__ [ struct ]
>
> Input database from which the measurement variables will be
> taken.
> 


__`range`__ [ struct ]
>
> Date range on which the data likelihood
> will be evaluated.
> 


__`estimSpecs`__ [ struct ]
>
> Struct with the list of paremeters that will be
> estimated, and the parameter prior specifications (see below).
> 


__`SystemPriors=[]`__ [ SystemPriorWrapper | empty ]
>
> System priors, [`SystemPriorWrapper`](systempriors/Contents).
> 


## Output arguments


__`summary`__ [ table ]
>
> Table with summary information.
> 


__`poster`__ [ Posterior ]
>
> Posterior, [`poster`](poster/Contents), object;
> this object also gives you access to the value of the objective function
> at optimum or at any point in the parameter space, see the
> [`Posterior/eval`](../@Posterior/eval) function.
> 


__`proposalCov`__ [ numeric ]
>
> Proposal covariance matrix based on the final Hessian, and adjusted for
> lower/upper bound hits.
> 


__`hess`__ [ cell ]
>
> `Hess{1}` is the total hessian of the objective
> function; `Hess{2}` is the contributions of the priors to the hessian.
> 


__`mEst`__ [ Model ]
>
> Model object solved with the estimated parameters (including
> out-of-likelihood parameters and common variance factor).
> 


## Options

__`CheckSteady=false`__ [ `true` | `false` | cell ]
>
> Check steady state in each iteration; works only in non-linear models.
> 


__`EvalLikelihood=true`__ [ `true` | `false` ]
>
> In each iteration, evaluate likelihood (or another data based criterion),
> and include it to the overall objective function to be optimised.
> 


__`EvalParameterPriors=true`__ [ `true` | `false` ]
>
> In each iteration, evaluate parameter prior density, and include it to
> the overall objective function to be optimised.
> 


__`EvalSystemPriors=true`__ [ `true` | `false` ]
>
> In each iteration, evaluate system prior density, and include it to the
> overall objective function to be optimised.
> 


__`Filter={}`__ [ cell ]
>
> Cell array of options that will be passed on to the Kalman filter
> including the type of objective function; see help on
> [`kalmanFilter`](kalmanFilter.md) for the options available.
>  

__`StartIterations="struct"`__ [ `"Model"` | `"Struct"` | struct ]
> 
> If `InitVal="struct"` use the values in the input struct `est` to start
> the iteration; if `Model` use the currently assigned parameter values in
> the input model, `m`.
>  


__`MaxIter=500`__ [ numeric ]
>
> Maximum number of iterations allowed.
> 


__`MaxFunEvals=2000`__ [ numeric ]
>
> Maximum number of objective function calls allowed.
> 


__`NoSolution='Error'`__ [ `'Error'` | `'Penalty'` | numeric ]
>
> > Specifies
> what happens if solution or steady state fails to solve in an iteration:
> `NoSolution='Error'` stops the execution with an error message,
> `NoSolution='Penalty'` returns an extreme value, `1e10`, back to the
> minimization routine; or a user-supplied penalty can be specified as a
> numeric scalar greater than `1e10`.
> 


__`OptimSet={}`__ [ cell ]
>
> Cell array used to create the Optimization
> Toolbox options structure; works only with the option `Solver='Default'`.
> 


__`Summary='Table'`__ [ `'Table'` | `'Struct'` ]
>
> Format of the `Summary` output argument.
> 


__`Solve=true`__ [ `true` | `false` | cellstr ]
> 
> Re-compute solution in
> each iteration; you can specify a cell array with options for the `solve`
> function.
> 

__`Steady=false`__ [ `true` | `false` | cell | function_handle ]
>
> Re-compute steady state in each iteration; you can specify a cell array
> with options for the `sstate( )` function, or a function handle whose
> behaviour is described below.
> 

__`TolFun=1e-6`__ [ numeric ]
>
> Termination tolerance on the objective
> function.
> 

__`TolX=1e-6`__ [ numeric ]
>
> Termination tolerance on the estimated
> parameters.
> 


## Description

The parameters that are to be estimated are specified in the input
parameter estimation specification struct, `estimSpecs` in which you can provide the following
specifications for each parameter:

    estimSpecs.parameterName = { start, lower, upper, prior };

where `start` is the value from which the numerical optimization will
start, `lower` is the lower bound, `upper` is the upper bound, and `prior`
is a 
[distribution function object](../../ShrinkageEstimation/+distribution/index.md)
specifying the prior density for the parameter.

You can use `NaN` for `start` if you wish to use the value currently
assigned in the model object. You can use `-Inf` and `Inf` for the
bounds, or leave the bounds empty or not specify them at all. You can
leave the prior distribution empty.


_Estimating nonlinear models_

By default, only the first-order solution, but not the steady state is
updated (recomputed) in each iteration before the likelihood is
evaluated. This behavior is controled by two options, `Solve=` (`true`
by default) and `Sstate=` (`false` by default). If some of the
estimated parameters do affect the steady state of the model, the option
`Sstate=` needs to be set to `true` or to a cell array with
steady-state options, as in the function [`sstate`](model/sstate),
otherwise the results will be groslly inaccurate or a valid first-order
solution will be impossible to find.

When steady state is recomputed in each iteration, you may also want to
use the option `Chksstate=` to require that a steady-state check for
all model equations be performed.


_User-supplied Optimization (Minimization) Routine_

You can supply a function handle to your own minimization routine through
the option `Solver=`. This routine will be used instead of the Optim
Tbx's `fminunc` or `fmincon` functions. The user-supplied function is
expected to take at least five input arguments and return three output
arguments:

    [pEst, ObjEst, Hess] = yourminfunc(F, P0, PLow, PHigh, OptimSet)

with the following input arguments:

* `F` is a function handle to the function minimised;
* `P0` is a 1-by-N vector of initial parameter values;
* `PLow` is a 1-by-N vector of lower bounds (with `-Inf` indicating no
lower bound);
* `PHigh` is a 1-by-N vector of upper bounds (with `Inf` indicating no
upper bounds);
* `OptimSet` is a cell array with name-value pairs entered by the user
through the option `'OptimSet='`. This option can be used to modify
various settings related to the optimization routine, such as tolerance,
number of iterations, etc. Of course, you may simply ignore it and leave
this input argument unused;

and the following output arguments:

* `pEst` is a 1-by-N vector of estimated parameters;
* `ObjEst` is the value of the objective function at optimum;
* `Hess` is a N-by-N approximate Hessian matrix at optimum.

If you need to use extra input arguments in your minimization function,
enter a cell array instead of a plain function handle:

    {@yourminfunc, Arg1, Arg2, ...}

In that case, the solver will be called the following way:

    [pEst, ObjEst, Hess] = yourminfunc(F, P0, PLow, PHigh, Opt, Arg1, Arg2, ...)


_User-Supplied Steady-State Solver_

You can supply a function handle to your own steady-state solver (i.e. a
function that finds the steady state for given parameters) through the
`Sstate=` option.

The function is expected to take one input argument, the model object
with newly assigned parameters, and return at least two output arguments,
the model object with a new steady state (or balanced-growth path) and a
success flag. The flag is `true` if the steady state has been successfully
computed, and `false` if not:

    [m, success] = mysstatesolver(m)

It is your responsibility to add the growth characteristics if some of
the model variables drift over time. In other words, you need to take
care of the imaginary parts of the steady state values in the model
object returned by the solver.

Alternatively, you can also run the steady-state solver with extra input
arguments (with the model object still being the first input argument).
In that case, you need to set the option `Sstate='` to a cell array with
the function handle in the first cell, and the other input arguments
afterwards, e.g.

    'Sstate=', {@mysstatesolver, 1, 'a', x}

The actual function call will have the following form:

    [m, success] = mysstatesolver(m, 1, 'a', x)


## Examples



