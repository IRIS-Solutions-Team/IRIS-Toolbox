---
title: rephrase.Marker
---

# `rephrase.Marker` ^^(+rephrase)^^

{== Create a Marker object for rephrase reports ==}


## Syntax 

    output = rephrase.Marker(title, x, y, varargin)

## Input arguments 

__`title`__ [ string ]
> 
> Title text for the marker.
> 

__`x`__ [ numeric ]
> 
> x axis of the marker
> 

__`y`__ [ numeric ]
> 
> y axis of the marker
> 

## Output arguments 

__`output`__ [ Marker ]
> 
> Marker type object with the assigned arguements to be passed
> into the rephrase objects.
> 


## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 

The function `+rephrase/Marker` returns the Marker object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Series`.

## Examples

```matlab
```
