---
title: databank.retrieveColumns
---

# `databank.retrieveColumns` ^^(+databank)^^

{== Retrieve selected columns from databank fields ==}


## Syntax

    outputDb = function(inputDb, refs,...)


## Input Arguments

__`inputDb`__ [ struct | Dictionary ]
> 
> Input databank from whose fields the selected columns given by the `ref`
> will be extracted and included in the `outputDb`.
> 

__`refs`__ [ numeric | cell ]
> 
> References to columns that will be retrieved from the fields of the
> `inputDb`; the references can be either numeric (refering to 2nd
> dimension) or a cell array (referring to multiple dimensions starting
> from 2nd).
> 

## Output Arguments

__`outputDb`__ [ struct | Dictionary ]
> 
> Output databank with the fields from the `inputDb` reduced to the
> selected columns `refs`; what happens when the columns cannot be
> retrieved from a field is determined by the option `WhenFails`.
> 

## Options

__`WhenFails="remove"`__ [ "error" | "keep" | "remove" ]
> 
> This option determines what happens when an attempt to reference and
> retrieve the selected columns from a field fails (when Matlab throws an
> error):
> 
> * `"error"` - an error will be thrown listing the failed fields;
> 
> * `"keep"` - the field will be kept in the `outputDb` unchanged;
> 
> * `"remove"` - the field will be removed from the `outputDb`.
> 

## Description


## Example



