---
title: table
---

# `table` ^^(Model)^^

{== Create table based on selected indicators from Model object ==}


## Syntax


    outputTable = table(model, request, ...)


## Input arguments

__`model`__ [ Model ] 
> 
> Model object based on which the table will be prepared.
> 

__`requests`__ [ char | cellstr | string ] 
> 
> Requested columns for the table; see Description for the list of
> valid requests.
> 

## Output arguments

__`outputTable`__ [ table ]
> 
> Table object with requested values.
> 

## Options

__`CompareFirstColumn=true`__ [ `true` | `false` ] 
> 
> Include the first column in comparison tables (first column compares
> itself with itself).
> 

__`Diary=""`__ [ string ] 
> 
> If `Diary=` is not empty, the table will be printed on the screen in
> the command window, and captured in a text file under this file name.
> 

__`SelectRows=false`__ [ `false` | string ]
> 
> Select only a subset of rows (names of variables, shocks and/or
> parameters) to be included in the `outputTable`.
> 

__`Sort=false`__ [ `true` | `false` ] 
> 
> If `true` sort the table rows alphabetically by the row names.
> 

__`Round=Inf`__ [ `Inf` | numeric ] 
> 
> Round numeric entries in the table to the specified number of digits;
> `Inf` means no rounding.
> 

__`WriteTable=""`__ [ string | cell ] 
> 
> If non-empty, the table will be exported to a text or spreadsheet
> file (depending on the file extension provided) under this file name
> using the standard `writetable( )` function;
> 

##  Description

This is the list of valid requests that can be combined in one call of
the `table()` function:

* `"SteadyLevel"` - Steady-state level for each model variable.

* `"SteadyChange"` - Steady-state difference (for nonlog-variables) or
steady-state gross rate of change (for log-variables) for each model
variables.

* `"SteadyDiff"` - Steady-state difference for each model variable not
declared as log-variables; `NaN` for log-variables.

* `"SteadyRate"` - Steady-state gross rate of growth for each model
variable declared as log-variables; `NaN` for nonlog-variables.

* `"Form"` - Indicator of the form in which steady-state change and/or
comparison are reported for each model variable: `"Diff-"` (meaning a
first difference when reporting steady-state growth, or a difference
between two steady states when reporting steady-state comparison) for
each nonlog-variable, and `"Rate/"` for each log-variable.

* `"CompareSteadyLevel"` - Steady-state level for each model variable
compared to the first parameter variant (a difference for each
nonlog-variable, a ratio for each log-variable).

* `"CompareSteadyChange"` - Steady-state difference (for
nonlog-variables) or steady-state gross rate of change (for
log-variables) for each model variables compared to the first parameter
variant (a difference for each nonlog-variable, a ratio for each
log-variable).

* `"CompareSteadyDiff"` - Steady-state difference for each model variable
not declared as log-variables, compared to the first parameter variant;
`NaN` for log-variables.

* `"SteadyRate"` - Steady-state gross rate of growth for each model
variable declared as log-variables, compared to the first parameter
variant; `NaN` for nonlog-variables.

* `"Description"` - Description text from the model file (quoted text
  preceding the name in a declaration section).

* `"Alias"` - Alias text from the model file (the part of the quoted text
  preceding the name in a declaration section that follows after a double
  exclamation mark).

* `"Log"` - Indicator of log-variables: `true` for each model variable
declared as a log-variable, `false` otherwise.

This is the list of valid requests that can be called individually:

* `"Parameters"` - The currently assigned value for each parameter; this
request can be combined with `"Description"`.

* `"Stationary"` - Indicator of stationarity of variables or log
variables.

* `"Std"` - The currently assigned value for the standard deviation of
each model shock.

* `"Corr"` - The currently assigned value for the cross-correlation
coefficient of each pair of model shocks.

* `"CompareParameters"` - The currently assigned value for each parameter
compared to the first parameter variant (a difference); this request can
be combined with `"Description"`.

* `"CompareStd"` - The currently assigned value for the standard
deviation of each model shock compared to the first parameter variant (a
difference).

* `"CompareCorr"` - The currently assigned value for the cross-correlation
coefficient of each pair of model shocks compared to the first parameter
variant (a difference).

* `"AllRoots"` - All eigenvalues associated with the current solution.

* `"StableRoots"` - All stable eigenvalues (smaller than `1` in
magnitude) associated with the current solution.

* `"UnitRoots"` - All unit eigenvalues (equal `1` in magnitude)
associated with the current solution.

* `"UnstableRoots"` - All unstable eigenvalues (greater than `1` in
magnitude) associated with the current solution.


## Examples

### Plain vanilla table

Create table with a steady state summary:

```matlab
table(m, ["steadyLevel", "steadyChange", "form", "description"])
```


### Save table to spreadsheet

Create the same table as before, and save it to an Excel spreadsheet file:

```matlab
table( ...
    m, ["steadyLevel", "steadyChange", "form", "description"] ...
    writeTable="steadyState.xls" ...
)
```

