# `Model`

{== Create new Model object from model file ==}


## Syntax


    m = Model(fileName, ...)
    m = Model(modelFile, ...)
    m = Model(m, ...)


## Input arguments


__`fileName`__ [ char | cellstr | string ]
>
Name(s) of model file(s) that will be loaded and converted to a new model
object.


__`modelFile`__ [ model.File ]
>
Object of model.File class.


__`m`__ [ Model ]
>
Rebuild a new model object from an existing one; see Description for when
you may need this.


## Output arguments


__`M`__ [ model ]
>
New model object based on the input model code file or files.


## General options


__`Assign=struct( )`__ [ struct | *empty* ]
>
Assign model parameters and/or steady states from this database at the
time the model objects is being created.


__`AutoDeclareParameters=false`__ [ `true` | `false` ]
>
If `true`, skip parameter declaration in the model file, and determine
the list of parameters automatically as residual names found in equations
but not declared.


__`BaseYear=@config`__ [ numeric | `@config` ]
>
Base year for constructing deterministic time trends; `@config` means the
base year will be read from iris configuration.


__`Comment=''`__ [ char ]
>
Text comment attached to the model object.


__`CheckSyntax=true`__ [ `true` | `false` ]
>
Perform syntax checks on model equations; setting `CheckSyntax=false` may
help reduce load time for larger model objects (provided the model file
is known to be free of syntax errors).


__`Epsilon=eps^(1/4)`__ [ numeric ]
>
The minimum relative step size for numerical differentiation.


__`Linear=false`__ [ `true` | `false` ]
>
Indicate linear models.


__`MakeBkw=@auto`__ [ `@auto` | `@all` | cellstr | char ]
>
Variables included in the list will be made part of the vector of
backward-looking variables; `@auto` means the variables that do not have
any lag in model equations will be put in the vector of forward-looking
variables.


__`AllowMultiple=false`__ [ true | false ]
>
Allow each variable, shock, or parameter name to be declared (and
assigned) more than once in the model file.


__`Optimal={ }`__ [ cellstr ]
>
Specify optimal policy options, see below; only applies when the keyword
[`min`](irislang/min) is used in the model file.


__`OrderLinks=true`__ [ `true` | `false` ]
>
Reorder `!links` so that they can be executed sequentially.


__`RemoveLeads=false`__ [ `true` | `false` ]
>
Remove all leads (aka forward-looking variables) from the state-space
vector and keep included only current dates and lags; the leads are not a
necessary part of the model solution and can dropped e.g. for memory
efficiency reasons in larger model objects.


__`SteadyOnly=false`__ [ `true` | `false` ]
>
Read in only the steady-state versions of equations (if available).


__`Std=@auto`__ [ numeric | `@auto` ]
>
Default standard deviation for model shocks; `@auto` means `1` for linear
models and `log(1.01)` for nonlinear models.


__`UserData=[ ]`__ [ ... ]
>
Attach user data to the model object.


## Options for optimal policy models


The following options for optimal policy models need to be
nested within the `'Optimal='` option.


__`MultiplierPrefix='Mu_'`__ [ char ]
>
Prefix used to create names for lagrange multipliers associated with the
optimal policy problem; the prefix is followed by the equation number.


__`Nonnegative={ }`__ [ cellstr ]
>
List of variables
constrained to be nonnegative.


__`Type='discretion'`__ [ `'commitment'` | `'discretion'` ]
>
Type of optimal policy; `'discretion'` means leads (expectations) are
taken as given and not differentiated w.r.t. whereas `'commitment'` means
both lags and leads are differentiated w.r.t.


## Description


### Loading a model file


The `Model` constructor can be used to read in a [model
file](irislang/Contents) named `FileName`, and create a model object `M`
based on the model file. You can then work with the model object in your
own m-files, using using the IRIS [model functions](model/Contents) and
standard Matlab functions.

If `FileName` is a cell array of more than one file names
then all files are combined together in order of appearance.


### Rebuilding an existing model object


When calling the `Model` constructor with an existing model object as the
first input argument, the model will be rebuilt from scratch. The typical
instance where you may need to call the constructor this way is changing
the `RemoveLeads=` option. Alternatively, the new model object can be
simply rebuilt from the model file.


## Examples

### Plain vanilla model constructor


Read in a model code file named `my.model`, and declare the model as
linear:

```matlab 
m = Model('my.model', 'Linear=', true);
```


### Construct model object and immedidately assign parameters


Read in a model code file named `my.model`, declare the model as linear,
and assign some of the model parameters:

```matlab
m = Model('my.model', 'Linear=', true, 'Assign=', P);
```

Note that this is equivalent to

```matlab
m = Model('my.model', 'Linear=', true);
m = assign(m, P);
```

unless some of the parameters passed in to the `Model` constructor are needed
to evaluate [`!if`](../Slang/if.md) or [`!switch`](../Slang/switch.md)
expressions.


