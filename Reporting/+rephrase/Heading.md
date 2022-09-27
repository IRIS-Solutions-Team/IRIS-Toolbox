---
title: rephrase.Heading
---

# `rephrase.Heading` ^^(+rephrase)^^

{== Creates Heading object for rephrase reports ==}


## Syntax 

    hd = rephrase.Heading(title, varargin)


## Input arguments 

__`title`__ [ string ]
> 
> Title text for the table which will be passed to the
> Table object as a heading
>  


## Output arguments 

__`hd`__ [ Heading ]
> 
> Heading type object with the assigned arguements to be passed
> into the rephrase objects.
> 


## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 

The function `+rephrase/Heading` returns the Heading object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Table`.

## Examples

```matlab

hd = rephrase.Heading("Heading");

```
