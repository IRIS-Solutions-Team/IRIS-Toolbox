---
title: eval
---

# `eval`

{== Evaluate contributions in input database using Grouping object ==}

## Syntax

    [s, lg] = eval(g, s)


## Input arguments

* `g` [ Grouping ] - Grouping object.

* `s` [ dbase ] - Input dabase with individual contributions.


## Output arguments

* `s` [ dbase ] - Output database with grouped contributions.

* `lg` [ cellstr ] - Legend entries based on the list of group names.


## Options

* `'Append='` [ *`true`* | `false` ] - Append in the output database all
remaining data columns from the input database that do not correspond to
any contribution of shocks or measurement variables.


## Description


## Example

For a model object `m`, database `d` and simulation range `r`, 

```matlab
s = simulate(m, d, r, 'contributions=', true) ;
g = Grouping(m, 'Shocks')
...
g = add(g, 'SupplyShocks', 'shock_pi', 'shock_w') ;
g = add(g, 'DemandShocks', 'shock_y', 'shock_is') ;
...
s = eval(s, g)
```

