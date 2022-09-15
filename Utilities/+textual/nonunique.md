---
title: textual.nonunique
---

# `textual.nonunique`

{== Find nonunique entries in a list ==}


## Syntax

    [flag, nonuniques] = textual.nonunique(inputList)


## Input arguments

__`inputList`__ [ string ]
> 
> List of strings.
> 

## Output arguments

__`flag`__ [ `true` | `false` ]
> 
> True if there are duplicate (nonunique) entries in the `inputList`.
> 

__`nonuniques`__ [ string ]
> 
> List of nonunique (duplicate) entries from the `inputList`. 
> 

## Description

Find all entries that occur in the `inputList`, more than
once, and return them with each such entry included only once in the
output list, `nonuniques`.


## Example

```matlab
>> [flag, nonuniques] = textual.nonunique(["a", "b", "c"])
flag = 
  logical
   0
nonuniques =
  1x0 empty cell array

>> [flag, nonuniques] = textual.nonunique(["a", "b", "c", "a", "a", "c"})
flag = 
  logical
   1
nonuniques =
  1x2 string array
    "a"    "b"
```


