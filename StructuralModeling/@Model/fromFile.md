# `Model.fromFile`

{== Create new Model object from model file ==}


## Syntax

    m = Model.fromFile(fileName, ...)


## Input arguments


__`fileName`__ [ string ]
>
> Name(s) of model file(s) that will be loaded and converted to a new Model
> object.
> 

__`modelFile`__ [ model.File ]
>
> A model.File object from which a new Model will be constructed.
> 

## Output arguments


__`m`__ [ Model ]
>
New Model object based on the input model code file or files.


## General options


__`Assign=struct( )`__ [ struct | *empty* ]
>
Assign model parameters and/or steady states from this database at the
time the model objects is being created.


__`AutoDeclareParameters=false`__ [ `true` | `false` ]
>
If `true`, disregard any parameter declaration sections in the model file,
and determine the list of parameters automatically as residual names found
in equations but not declared.


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


__`MakeBkw=@auto`__ [ `@auto` | `@all` | string ]
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
> Specify optimal policy options, see below; only applies when the keyword
> [`min`](.../Slang/min.md) is used in the model file.
> 

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


__`Nonnegative=[]`__ [ string ]
>
> List of variables constrained to be nonnegative.
> 

__`Type="discretion"`__ [ `"commitment"` | `"discretion"` ]
>
> Type of optimal policy; `"discretion"` means leads (expectations) are
> taken as given and not differentiated w.r.t. whereas `"commitment"` means
> both lags and leads are differentiated w.r.t.
> 

## Description

### Loading a model file

The `Model.fromFile` constructor can be used to read in a [model
file](irislang/Contents) named `fileName`, and create a model object `m`
based on the model file. You can then work with the model object in your
own m-files, using using the standard Matlab and IrisT functions.

If `fileName` is an array of more than one file names
then all files are combined together in order of appearance.


## Examples

### Plain vanilla model constructor


Read in a model code file named `my.model`, and declare the model as
linear:

```matlab 
m = Model.fromFile("my.model", Linear=true);
```


### Construct model object and immedidately assign parameters


Read in a model code file named `my.model`, declare the model as linear,
and assign some of the model parameters:

```matlab
m = Model.fromFile("my.model", Linear=true, Assign=P);
```

Note that this is equivalent to

```matlab
m = Model.fromFile("my.model", Linear=true);
m = assign(m, P);
```

unless some of the parameters passed in to the `Model.fromFile` constructor
are needed to evaluate [`!if`](../Slang/if.md) or
[`!switch`](../Slang/switch.md) expressions.


