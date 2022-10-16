---
title: databank.copy
---

# `databank.copy` ^^(+databank)^^

{== Copy fields of source databank to target databank ==}


## Syntax

    targetDb = databank.copy(sourceDb, ...)


## Input Arguments

__`sourceDb`__ [ struct | Dictionary ]
> 
> Source databank from which some (or all) fields will be copied over
> to the `targetDb`.
> 

## Options

__`SourceNames=@all`__ [ `@all` | cellstr | string ]
> 
> List of fieldnames to be copied over from the `sourceDb` to the
> `targetDb`; `@all` means all fields existing in the `sourceDb` will
> be copied.
> 

__`TargetDb=@empty`__ [ `@empty` | struct | Dictionary ]
> 
> Target databank to which some (or all) fields form the `sourceDb`
> will be copied over; `@empty` means a new empty databank will be
> created of the same type as the `sourceDb` (either a struct or a
> Dictionary).
> 

__`TargetNames=@auto`__ [ cellstr | string | function_handle ]
> 
> Names under which the fields from the `sourceDb` will be stored in
> the `targetDb`; `@auto` means the `TargetNames` will be simply the
> same as the `SourceNames`; if `TargetNames` is a function, the target
> names will be created by applying this function to each of
> the `SourceNames`.
> 

__`Transform={}`__ [ empty | function_handle | cell ]
> 
> Transformation function or functions applied to each of the fields being
> copied over from the `sourceDb` to the `targetDb`; if empty, no
> transformation is performed; if a cell array of functions, each function
> will be applied consecutively.
> 

__`WhenTransformFails='Error'`__ [ `'Error'` | `'Warning'` | `'Silence'` ]
> 
> Action to be taken if the transformation function `Transform=`
> evaluates to an error when applied to one or more fields of the source
> databank.
> 

## Output Arguments

__`targetDb`__ [ struct | Dictionary ]
> 
> Target databank to which some (or all) fields from the `sourceDb`
> will be copied over.
> 

## Description


## Example


