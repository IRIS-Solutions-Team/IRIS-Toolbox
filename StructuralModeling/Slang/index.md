# Overview of model source code language

The IrisT model source code language (Slang) is a system of keywords that define the structure of
model source files. The model source files are plain text files (saved
under any file name with any extension) that describe the model: its
equations, variables, parameters, etc. The model files do not describe what
tasks to do with the model. To run the tasks you want to perform with the
model, you need first to load the model file into Matlab using the
[`Model.fromFile`](../Model/fromFile.md) function. This function creates a
model object. Then you write your own m-files using Matlab and IrisT
functions to perform the desired tasks with the model object.

When writing model files, you can also use the IrisT preparsing commands
that introduce tools for writing reusable and well-structured model code
base and minimize repetitive model code writing tasks.

You can get the model source files syntax highlighted in the Matlab editor
to improve the readability of the files, and helps navigate the model more
quickly; see the [setup instructions](../../Install/index.md).


## Guidelines

Reference | Description
---|---
[`Creating model files`](model-files.md)                              | Guideline for writing and structuring model source files
[`Declaring model names`](names.md)                                          | Declare model names: Variables, shocks, parameters
[`Writing model equations`](equations.md)                                  | Write model equations


## Categorical list of keywords

### Declaring model names: Variables, parameters and shocks

Keyword | Description 
---|---
[`!transition-variables`](!transition-variables.md)          | Declare names of transition variables
[`!transition-shocks`](!transition-shocks.md)                | Declare names of transition shocks
[`!measurement-variables`](!measurement-variables.md)        | Declare names fo measurement variables
[`!measurement-shocks`](!measurement-shocks.md)              | Declare names of measurement shocks
[`!parameters`](!parameters.md)                              | Declare names of parameters
[`!exogenous-variables`](!exogenous-variables.md)            | Declare names exogenous variables


### Writing model equations

See [{{ slang._equations }}](`equations.md`) for details on declaring model equations.
See [{{ slang._guidelines }}](`guidelines.md`) for writing model source files.

Keyword | Description 
---|---
[`!transition-equations`](!transition-equations.md)          | Block of transition equations
[`!measurement-equations`](!measurement-equations.md)        | Block of measurement equations
[`!dtrends`](!dtrends.md)                                    | Block of deterministic trend equations
[`!links`](!links.md)                                        | Define dynamic links
[`!preprocessor`](!preprocessor.md)                          | Preprocessing equations
[`!postprocessor`](!postprocessor.md)                        | Postprocessing equations


### Controlling log status of variables

Keyword | Description 
---|---
[`!log-variables`](!log-variables.md)                        | List of log-linearised variables
[`!all-but`](!all-but.md)                                    | Inverse list of log-linearised variables


### Defining autoswap pairs
[`!autoswaps-simulate`](!autoswaps-simulate.md)              | Definitions of variable-shock pairs to be autoswapped in dynamic simulations
[`!autoswaps-steady`](!autoswaps-steady.md)                  | Definitions of variable-parameter pairs to be autoexogenized in steady-state calculations


### Other keywords and syntax

Keyword | Description 
---|---
[`min`](min.md)                                              | Define loss function for optimal policy
[`!!`](steady-version.md)                                    | Steady-state versions of equations
[`||`](alias.md)                                             | Separate alias from the rest of name or equation description
[`{...}`](shift.md)                                          | Lag or lead
[`&`](steady-ref.md)                                         | Reference to the steady-state level of a variable
[`!ttrend`](!ttrend.md)                                      | Linear time trend in deterministic trend equations


### Pseudofunctions

Pseudofunctions do not start with an exclamation point

Keyword | Description 
---|---
[`diff`](diff.md)                                            | First difference pseudofunction
[`roc`](roc.md)                                              | Gross rate of change pseudofunction
[`pct`](pct.md)                                              | Percent change
[`difflog`](difflog.md)                                      | First log-difference pseudofunction
[`movavg`](movavg.md)                                        | Moving average pseudofunction
[`movgeom`](movgeom.md)                                      | Moving geometric average pseudofunction
[`movprod`](movprod.md)                                      | Moving product pseudofunction
[`movsum`](movsum.md)                                        | Moving sum pseudofunction

### Preparsing keywords

Keyword | Description 
---|---
[`%`](line-comment.md)                                       | Line comments
[`%{ ... %}`](block-comment.md)                                | Block comments
[`<...>`](interp.md)                                         | Interpolation.
[`!export`](!export.md)                                      | Create exportable file to be saved in working directory.
[`!for`](!for.md)                                            | For-loop control structure for automated creation of model source code
[`!function`](!function.md)                                  | Create exportable m-file function to be saved in working directory
[`!if`](!if.md)                                              | Choose block of code based on logical condition.
[`!import`](!import.md)                                      | Include the content of another model file.
[`!substitutions`](!substitutions.md)                        | Define text substitutions
[`!switch`](!switch.md)                                      | Switch among several cases based on expression.



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


## Basic rules for writing IrisT model source files

* There can be four types of equations in IrisT models: transition equations
which are simply the endogenous dynamic equations, measurement equations
which link the model to observables, deterministic trend equations which
can be added at the top of measurement equations, and dynamic links which
can be used to link some parameters or steady-state values to each other.

* There can be two types of variables and two types of shocks in IrisT
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

* Exogenous variables can only occur in dtrends (deterministic trend
  equations), and must be always supplied as part of the input database to
  commands like [`Model/simulate`](../Model/simulate),
  [`Model/filter`](../Model/filter), [`Model/estimate`](../Model/estimate),
  etc. They are not returned in the output databases.

* You can choose between linearisation and log-linearisation for each
individual transition and measurement variable. Shocks are always
linearized. Exogenous variables must be always introduced so that their
effect on the respective measurement variable is linear.



