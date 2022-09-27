---
topic: Slang
---

# Overview of model source language

{==
The model source language is used to describe all the elements of
a model in human-readable form: variables, parameters, shocks,
equations, etc. The model source is then translated to a
structural model object.
==}

Slang is a set of keywords that define the structure of
model source files. The model source files are plain text files (saved
under any file name with any extension) that describe the model: its
equations, variables, parameters, etc. The model files do not describe what
tasks to do with the model. To run the tasks you want to perform with the
model, you need first to load the model file into Matlab using the
[`Model.fromFile`](../@Model/fromFile.md) function. This function creates a
model object. Then you write your own m-files using Matlab and Iris
functions to perform the desired tasks with the model object.

When writing model files, you can also use the Iris preparsing commands
that introduce tools for writing reusable and well-structured model code
base and minimize repetitive model code writing tasks.

You can get the model source files syntax highlighted in the Matlab editor
to improve the readability of the files, and helps navigate the model more
quickly; see the [setup instructions](../../+iris/install.md).


## Guidelines

Topic | Description
---|---
[Writing source code](model-files.md) | Guideline for writing and structuring model source files
[Declaring model names](names.md) | Declare model names: Variables, shocks, parameters
[Writing model equations](equations.md) | Write model equations


## Categorical list of keywords

### Declaring model names: Variables, parameters and shocks

Keyword | Description 
---|---
[`!transition-variables`](!transition-variables.md) | Declare names of transition variables
[`!transition-shocks`](!transition-shocks.md) | Declare names of transition shocks
[`!measurement-variables`](!measurement-variables.md) | Declare names fo measurement variables
[`!measurement-shocks`](!measurement-shocks.md) | Declare names of measurement shocks
[`!parameters`](!parameters.md) | Declare names of parameters
[`!exogenous-variables`](!exogenous-variables.md) | Declare names exogenous variables


### Writing model equations

Keyword | Description 
---|---
[`!transition-equations`](!transition-equations.md) | Block of transition equations
[`!measurement-equations`](!measurement-equations.md) | Block of measurement equations
[`!dtrends`](!dtrends.md) | Block of deterministic trend equations
[`!links`](!links.md) | Define dynamic links
[`!preprocessor`](!preprocessor.md) | Preprocessing equations
[`!postprocessor`](!postprocessor.md) | Postprocessing equations


### Controlling log status of variables

Keyword | Description 
---|---
[`!log-variables`](!log-variables.md) | List of log-linearised variables
[`!all-but`](!all-but.md) | Inverse list of log-linearised variables


### Defining autoswap pairs

Keyword | Description 
---|---
[`!autoswaps-simulate`](!autoswaps-simulate.md) | Definitions of variable-shock pairs to be autoswapped in dynamic simulations
[`!autoswaps-steady`](!autoswaps-steady.md) | Definitions of variable-parameter pairs to be autoexogenized in steady-state calculations


### Other keywords and syntax

Keyword | Description 
---|---
[`min`](min.md) | Define loss function for optimal policy
[`!!`](steady-version.md) | Steady-state versions of equations
[`||`](alias.md) | Separate alias from the rest of name or equation description
[`{...}`](shift.md) | Lag or lead
[`&`](steady-ref.md) | Reference to the steady-state level of a variable
[`!ttrend`](!ttrend.md) | Linear time trend in deterministic trend equations


### Pseudofunctions

Note that pseudofunctions do not start with an exclamation point

Keyword | Description 
---|---
[`diff`](diff.md) | First difference pseudofunction
[`roc`](roc.md) | Gross rate of change pseudofunction
[`pct`](pct.md) | Percent change
[`difflog`](difflog.md) | First log-difference pseudofunction
[`movavg`](movavg.md) | Moving average pseudofunction
[`movgeom`](movgeom.md) | Moving geometric average pseudofunction
[`movprod`](movprod.md) | Moving product pseudofunction
[`movsum`](movsum.md) | Moving sum pseudofunction

### Preparsing keywords

Keyword | Description 
---|---
[`%`](line-comment.md) | Line comments
[`%{ ... %}`](block-comment.md) | Block comments
[`<...>`](evaluate.md) |  
[`!export`](!export.md) | Create exportable file to be saved in working directory.
[`!for`](!for.md) | For-loop control structure for automated creation of model source code
[`!function`](!function.md) | Create exportable m-file function to be saved in working directory
[`!if`](!if.md) | Choose block of code based on logical condition.
[`!import`](!import.md) | Include the content of another model file.
[`!substitutions`](!substitutions.md) | Define text substitutions
[`!switch`](!switch.md) | Switch among several cases based on expression.


