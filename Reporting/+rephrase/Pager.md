---
title: rephrase.Pager
---

# `rephrase.Pager` ^^(+rephrase)^^

{== Create a Text object for rephrase reports ==}


## Syntax 

    output = rephrase.Pager(title, varargin)


## Input arguments 

__`title`__ [ string ]
> 
> Title text for the pager.
> 


## Output arguments 

__`output`__ [ Pager ]
> 
> Pager type object with the assigned arguements to be passed
> into the rephrase objects.
> 

## Options 

__`StartPage=0`__ [ numeric ]
> 
> Sets the start page.
> 

## Description 

The function `+rephrase/Text` returns the Text object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Report`.

## Examples

```matlab
```
