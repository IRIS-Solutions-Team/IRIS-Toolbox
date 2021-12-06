# estimate

{== Estimate model parameters by optimizing selected objective function ==}


## Syntax

Input arguments marked with a `~` sign may be omitted.

    [Summary, Poster, Table, Hess, MEst, V, Delta, PDelta] ...
        = estimate(M, D, Range, EstimSpec, ~SystemPriors, ...)


## Input arguments

* `M` [ model ] - Model object with single parameterization.

* `D` [ struct | cell ] - Input database or datapack from which the
measurement variables will be taken.

* `Range` [ struct | char ] - Date range on which the data likelihood
will be evaluated.

* `EstimSpec` [ struct ] - Struct with the list of paremeters that will be
estimated, and the parameter prior specifications (see below).

* `~SystemPriors` [ systempriors | *empty* ] - System priors object,
[`systempriors`](systempriors/Contents); may be omitted.


## Output arguments

* `Summary` [ table ] - Table with summary information.

* `Poster` [ poster ] - Posterior, [`poster`](poster/Contents), object;
this object also gives you access to the value of the objective function
at optimum or at any point in the parameter space, see the
[`poster/eval`](poster/eval) function.

* `Table` [ numeric ] - Summary table with a starting value, point
estimate, std error estimate, and lower and upper bounds for each
parameter. 

* `Hess` [ cell ] - `Hess{1}` is the total hessian of the objective
function; `Hess{2}` is the contributions of the priors to the hessian.

* `MEst` [ model ] - Model object solved with the estimated parameters
(including out-of-likelihood parameters and common variance factor).

The remaining three output arguments, `V`, `delta`, `PDelta`, are the
same as the [`model/loglik`](model/loglik) output arguments of the same
names.


## Options

* `CheckSteady=false` [ `true` | `false` | cell ] - Check steady state in
each iteration; works only in non-linear models.

* `EvalLikelihood=true` [ `true` | `false` ] - In each iteration, evaluate
likelihood (or another data based criterion), and include it to the
overall objective function to be optimised.

* `EvalParameterPriors=true` [ `true` | `false` ] - In each iteration,
evaluate parameter prior density, and include it to the overall objective
function to be optimised.

* `EvalSystemPriors=true` [ `true` | `false` ] - In each iteration,
evaluate system prior density, and include it to the overall objective
function to be optimised.

* `Filter={ }` [ cell ] - Cell array of options that will be passed on to
the Kalman filter including the type of objective function; see help on
[`model/filter`](model/filter) for the options available.

* `InitVal='struct'` [ `'Model'` | `'Struct'` | struct ] - If `Struct`
use the values in the input struct `est` to start the iteration; if
`Model` use the currently assigned parameter values in the input model,
`m`.

* `MaxIter=500` [ numeric ] - Maximum number of iterations allowed.

* `MaxFunEvals=2000` [ numeric ] - Maximum number of objective function
calls allowed.

* `NoSolution='Error'` [ `'Error'` | `'Penalty'` | numeric ] - Specifies
what happens if solution or steady state fails to solve in an iteration:
`NoSolution='Error'` stops the execution with an error message,
`NoSolution='Penalty'` returns an extreme value, `1e10`, back to the
minimization routine; or a user-supplied penalty can be specified as a
numeric scalar greater than `1e10`.

* `OptimSet={ }` [ cell ] - Cell array used to create the Optimization
Toolbox options structure; works only with the option `Solver='Default'`.

* `Summary='Table'` [ `'Table'` | `'Struct'` ] - Format of the `Summary`
output argument.

* `Solve=true` [ `true` | `false` | cellstr ] - Re-compute solution in
each iteration; you can specify a cell array with options for the `solve`
function.

* `Solver='Default'` [ `'Default'` | cell | function_handle ] -
Minimization procedure.

    * `'Default'`: The Optimization Toolbox function `fminunc` or
    `fmincon` will be called depending on the presence or absence of
    lower and/or upper bounds.

    * function_handle or cell: Enter a function handle to your own
    optimization procedure, or a cell array with a function handle and
    additional input arguments (see below).

* `SState=false` [ `true` | `false` | cell | function_handle ] -
Re-compute steady state in each iteration; you can specify a cell array
with options for the `sstate( )` function, or a function handle whose
behaviour is described below.

* `TolFun=1e-6` [ numeric ] - Termination tolerance on the objective
function.

* `TolX=1e-6` [ numeric ] - Termination tolerance on the estimated
parameters.


## Description

The parameters that are to be estimated are specified in the input
parameter estimation database, `E` in which you can provide the following
specifications for each parameter:

    E.parameter_name = { start, lower, upper, logpriorFunc };

where `start` is the value from which the numerical optimization will
start, `lower` is the lower bound, `upper` is the upper bound, and
`logpriorFunc` is a function handle expected to return the log of the
prior density. You can use the [`logdist`](logdist/Contents) package to
create function handles for some of the basic prior distributions.

You can use `NaN` for `start` if you wish to use the value currently
assigned in the model object. You can use `-Inf` and `Inf` for the
bounds, or leave the bounds empty or not specify them at all. You can
leave the prior distribution empty or not specify it at all.


_Estimating Nonlinear Models_

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



