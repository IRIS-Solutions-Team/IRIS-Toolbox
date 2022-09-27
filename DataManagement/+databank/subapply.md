---
title: databank.subapply
---

# `databank.subapply` ^^(+databank)^^

{== Apply function to a crosslist of nested fields ==}


## Syntax 

    db = databank.subapply(func, db, whenMissing, level1, level2, ..., levelK)


## Input arguments 

__`func`__ [ function_handle ]
> 
> Function that is applied to the crosslist of fields of the input
> databank, `db`.
> 

__`db`__ [ struct | Dictionary ]
> 
> Input databank, possibly nested; the function `func` is applied to
> the crosslist of fields of `db`, and the resulting databank is
> returned.
> 

__`whenMissing`__ [ any | `@error` ]
> 
> Value used to create a field if it is missing from `db`, before the
> function `func` is applied to it; if `whenMissing=@error`, an error
> message is thrown.
> 

__`levelK`__ [ string ]
> 
> List of fields at nested level K from which the crosslist will be
> compiled; the crosslist consists of all the combinations of the
> fields at` the respective nesting levels given by the lists
> `level1`, ..., `levelK`, where K is the maximum nesting depth.
> 


## Output arguments 

__`db`__ [ struct | Dictionary ]
> 
> Output databank created from the input databank by applying the
> function `func` to the crosslist of fields given by the lists
> `level1`, ..., `levelK`
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

