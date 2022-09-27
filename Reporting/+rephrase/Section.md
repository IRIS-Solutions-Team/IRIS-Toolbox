---
title: rephrase.Section
---

# `rephrase.Section` ^^(+rephrase)^^

{== Create a Section object for rephrase reports ==}


## Syntax 

    output = rephrase.Section(title, varargin)


## Input arguments 

__`title`__ [ string ]
> 
> Section text.
> 

## Output arguments 

__`output`__ [ Section ]
> 
> Section type object with the assigned arguements to be
> passed into the rephrase objects.
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 

## Possible children

`+rephrase/Grid`
`+rephrase/Table`
`+rephrase/Chart`
`+rephrase/SeriesChart`
`+rephrase/CurveChart`
`+rephrase/Matrix`
`+rephrase/Pager`
`+rephrase/Section`

## Description 

The function `+rephrase/Section` returns the Section object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Report`.

## Examples

```matlab

section = rephrase.Section("Section")

```
