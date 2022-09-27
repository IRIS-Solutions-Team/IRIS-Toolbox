---
title: rephrase.Matrix
---

# `rephrase.Matrix` ^^(+rephrase)^^

{== Create a Matrix object for rephrase reports ==}


## Syntax 

    output = rephrase.Matrix(title, input, varargin)


## Input arguments 

__`title`__ [ string ]
> 
> Title text for the matrix.
> 

__`input`__ [ array ]
> 
> Array type of object which contains the data to be displayed.
> 

## Output arguments 

__`output`__ [ Matrix ]
> 
> Matrix type object with the assigned arguements to be
> passed into the rephrase objects.
> 

## Options 

__`CellClasses=`__ [ cell ]
> 
> Description
> 

## Possible children

None

## Description 

The function `+rephrase/Matrix` returns the Matrix object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Grid`.

## Examples

```matlab
```
