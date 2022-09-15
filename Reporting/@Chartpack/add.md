---
title: add
---

# `add`

{== Add a new chart to a Chartpack object ==}


## Syntax

    add(ch, inputString, ___)


## Short-cut syntax

    ch + inputString
    ch + [inputString, inputString, inputString]


## Input arguments

__`inputString`__ [ string ]
> 
> String, or an array of strings, specifying the expression to be plotted
> in a new chart, optionally with a caption preceding the expression and
> separated by a colon.
> 

## Output arguments

No output arguments are needed because the Chartpack object `ch`
is a handle object, and updating handle objects does not require capturing
them as output arguments.


## Options

__`ApplyTransform=true`__ [ `true` | `false` ]
> 
> Apply the function specified in the option `Transform` to the data in
> this chart; `ApplyTransform=false` can be also achieved by using a hat
> sign `^` at the beginning of the expression in the `inputString`.
> 

__`Expansion=@parent`__ [ cell | empty | `@parent` ]
> 
> Replace a substring in the expression with mutliple strings, creating
> multiple series to be plotted in the same chart; overrides the
> property `Expansion` defined at the level of the Chartpack
> object.
> 

__`Transform=@parent`__ [ function | empty | `@parent` ]
> 
> Function that will be applied to this data inputString before it gets plotted;
> overrides the property `Transform` defined at the level of the
> Chartpack object.
> 

