# databank.merge

{== Merge two or more databanks ==}


## Syntax

    outputDb = databank.merge(method, primaryDb [, otherDb ], ___)


## Shortcut syntax for `databank.merge("horzcat", ___)`

    outputDb = databank.horzcat(primaryDb, [, otherDb], ___)


## Input arguments

__`method`__ [ `"horzcat"` | `"vertcat"` | `"replace"` | `"discard"` | `"error"` ] 
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
> Action to perform when a field is missing from one or more of the
> input mergeWith when the `method` is `"horzcat"`.
> 

## Description

The fields from each of the additional mergeWith (`d1` and further) are
added to the main databank `d`. If the name of a field to be added
already exists in the main databank, `d`, one of the following actions is
performed:

* `"horzcat"` - the fields will be horizontally concatenated;

* `"replace"` - the field in the main databank will be replaced with the
new field;

* `"discard"` - the field in the main databank will be kept unchanged, and
the new field will be discarded;

* `"error"` - an error will be thrown.


## Example


