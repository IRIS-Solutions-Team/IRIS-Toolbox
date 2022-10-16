---
title: rephrase.DiffSeries
---

# `rephrase.DiffSeries` ^^(+rephrase)^^

{== Create a DiffSeries object for rephrase reports ==}


## Syntax 

    output = rephrase.DiffSeries(title, baseline, alternative, varargin)


## Input arguments 

__`title`__ [ string ]
> 
> Title text for the diffseries.
>  

__`baseline`__ [ Series ]
> 
> Baseline Series containing the first set of data.
>  

__`alternative`__ [ Series ]
> 
> Alternative Series containing the second set of data.
>  

## Output arguments 

__`output`__ [ DiffSeries ]
> 
> DiffSeries type object with the assigned arguements to be
> passed into the rephrase objects.
> 

## Options 

__`Units=`__ [ String ]
> 
> Description
> 

## Description 

The function `+rephrase/DiffSeries` returns the Grid object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Table`.

## Examples

```matlab

diffs = rephrase.DiffSeries("Title", d.x, d.y)

```
