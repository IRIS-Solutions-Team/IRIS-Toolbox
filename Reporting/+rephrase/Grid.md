---
title: rephrase.Grid
---

# `rephrase.Grid` ^^(+rephrase)^^

{== Create a Grids object for rephrase reports ==}


## Syntax 

    output = rephrase.Grid(title, numRows, numColumns, varargin)

## Input arguments 

__`title`__ [ string ]
> 
> Title text for the grid.
>  

## Output arguments 

__`output`__ [ Grid ]
> 
> Grid type object with the assigned arguements to be passed
> into the rephrase objects. It can be used to create a grid
> for its children (i.e. charts and tables).
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 

## Possible children

`+rephrase/Table`
`+rephrase/Chart`
`+rephrase/SeriesChart`
`+rephrase/CurveChart`
`+rephrase/Matrix`

## Description 

The function `+rephrase/Grid` returns the Grid object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Report`. It serves as a basis object that accepts all of the children.

## Examples

```matlab

grid1 = rephrase.Grid("", 2, 2, "DisplayTitle", true,  "DateFormat", "YY\QQ");

```
