
# Writing source code for structural models

## Basic rules

* There can be four types of equations in Iris models: transition equations
which are simply the endogenous dynamic equations, measurement equations
which link the model to observables, deterministic trend equations which
can be added at the top of measurement equations, and dynamic links which
can be used to link some parameters or steady-state values to each other.

* There can be two types of variables and two types of shocks in Iris
models: transition variables and shocks, and measurement variables and
shocks.

* Each model must have at least one transition (aka endogenous)
variable and one transition equation.

* Each variable, shock, or parameter must be declared in the appropriate
declaration section.

* The declaration sections and equations sections can be written in any
order.

* You can have as many declaration sections or equations sections of the
same kind as you wish in one model file; they all get combined together
at the time the model is being loaded.

* Transition variables can occur with lags and leads in transition
equations. Transition variables cannot, though, have leads in measurement
equations.

* Measurement variables and the shocks cannot have any lags or leads.

* Transition shocks cannot occur in measurement equations, and the
measurement shocks cannot occur in transition equations.

* Exogenous variables can only occur in two contexts: deterministic trend
  equations in any model, or transition and measuremement equations of
  purely backward-looking models simulated without the use of first-order
  solution. These variables must be always supplied as part of the input database to
  commands such as
  [`Model/simulate`](../@Model/simulate.md),
  [`Model/kalmanFilter`](../@Model/kalmaFilter.md),
  [`Model/estimate`](../@Model/estimate.md), etc.
  They are not returned in the output databases.

* You can choose between linearization and log-linearization for each
individual transition and measurement variable. Shocks are always
linearized. Exogenous variables must be always introduced so that their
effect on the respective measurement variable is linear.



## Matlab and user-defined functions in model files

You can use any of the built-in functions (Matlab functions, functions
within the Toolboxes you have on your computer, or your own m-file
functions). The only requirement is that the function needs to be visible
to Matlab, i.e. located either in the current working directory or in a
folder on the Matlab search path.

In addition, when using your own m-file functions, you can also
(optionally) supply the first derivatives that will be used to compute
Taylor expansions when the model is being solved, and the second
derivatives that will be used when the function occurs in a loss function.

When asked for the derivatives, the function is called with two extra
input arguments on top of that function's regular input arguments. The
first extra input argument is a text string `"diff"` (indicating the call
to the function is supposed to return a derivative). The second extra
input argument is a number or a vector of two numbers; it determines with
respect to which input argument or arguments the first derivative or the
second derivative is requested.

For instance, your function takes three input arguments, `myfunc(x, y, z)`.
To be able to supply derivates avoiding thus numerical differentiation,
the function must be written so that the following three calls

    myfunc(x, y, z, "diff", 1)
    myfunc(x, y, z, "diff", 2)
    myfunc(x, y, z, "diff", 3)

return the first derivative wrt to the first, second, and third input
argument, respectively, while

    myfunc(x, y, z, "diff", [1, 2])

returns the second derivative wrt to the first and second input
arguments. Note that second derivatives are only needed for functions
that occur in an equation defining optimal policy objective,
[`min`](min.md).

If any of these calls fail, the respective derivative will be simply
evaluated numerically.



