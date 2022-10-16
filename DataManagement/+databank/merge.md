---
title: databank.merge
---

# `databank.merge` ^^(+databank)^^

{== Merge two or more databanks ==}


## Syntax

    outputDb = databank.merge(method, primaryDb [, otherDb ], ___)


## Shortcut syntax for `databank.merge("horzcat", ___)`

    outputDb = databank.horzcat(primaryDb, [, otherDb], ___)


## Input arguments


__`method`__ [ `"horzcat"` | `"vertcat"` | `"replace"` | `"warning"` | `"discard"` | `"error"` ] 
> 
> Action to perform when two or more of the input mergeWith contain a
> field of the same name; see Description.
> 


__`primaryDb`__ [ struct | Dictionary ] 
> 
> Primary input databank that will be merged with the other input
> mergeWith, `d1`, etc.  using the `method`.
> 


__`otherDb`__ [ struct | Dictionary ] 
> 
> One or more mergeWith which will be merged with the primaryinput databank
> `primaryDb` to create the `outputDb`.
> 


## Output arguments


__`outputDb`__ [ struct | Dictionary ] 
> 
> Output databank created by merging the input mergeWith using the
> method specified by the `method`.
> 


## Options

__`MissingField=@rmfield`__ [ `@rmfield` | `NaN` | `[ ]` | * ] 
> 
> Action to take when a field is missing from one or more of the
> input mergeWith when the `method` is `"horzcat"`.
> 


__`WhenFailed="warning"`__ [ `"warning"` | `"silent"` | `"error"` ]
>
> Action to take when the `method` fails to merge a field across some of
> the input databanks. `WhenFailed="warning"` or `WhenFailed="silent"`
> results in the failed fields being excluded from the `outputDb`.
>


## Description

The fields from each of the additional mergeWith (`d1` and further) are
added to the main databank `d`. If the name of a field to be added
already exists in the main databank, `d`, one of the following actions is
performed:

* `"horzcat"` - horizontally concatenate the fields;

* `"replace"` - silently replace the field in the main databank with the
  new field;

* `"warning"` - replace the field in the main databank with the
  new field, and throw a warning;

* `"discard"` - keep the field in the main databank unchanged, and discard
  the new field;

* `"error"` - throw an error whenever the main databank and the other
  databank contain a field of the same name.


## Example


