---
title: select
---

# `select`

{== Select submatrix by referring to row names and column names ==}


## Syntax 

    [XX, pos] = select(x, rowSelection, columnSelection)
    [XX, pos] = select(x, Select)


## Input arguments 

__`x`__ [ namedmat ]
> 
> Matrix or array with named rows and columns.
> 

__`rowSelection`__ [ char | cellstr ]
> 
> Selection of row names.
> 

__`columnSelection`__ [ char | cellstr ]
> 
> Selection of column names.
> 

__`Select`__ [ char | cellstr ]
> 
> Selection of names that will be applied
> to both rows and columns.
> 

## Output arguments 

* `XX` [ namedmat ]
> 
> Submatrix with named rows and columns.
> 

* `pos` [ cell ]
> 
> `pos{1}` is a vector of rows included in the submatrix
> `XX`, `pos{2}` is a vector of columns included in the submatrix `XX`.
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 



## Examples

```matlab
```

