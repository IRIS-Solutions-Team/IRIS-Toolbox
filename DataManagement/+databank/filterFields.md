---
title: databank.filterFields
---

# `databank.filterFields` ^^(+databank)^^

{== Get the names of databank fields that pass name or value tests ==}

## Syntax

    list = databank.filterFields(inputDb, ...)


## Input Arguments 

__`inputDb`__ [ struct | Dictionary ]
> 
> Input databanks whose fields will be tested for their names, types
> (classes) and values.
> 

## Output Arguments 

__`list`__ [ string ]
> 
> List of the `inputDb` fields that have successfully passed the name,
> class and value tests.
> 

## Options

__`Name=@all` [ `@all` | function ]
> 
> Function (function handle) that will be applied to each field name; the
> `Name` function must return a `true` or `false` for any field name;
> `@all` means all fields pass the name test.
> 

__`Class=@all` [ `@all` | string ]
> 
> 
> List of classes against which the value of each `inputDb` field will be
> tested; `@all` mean all fields pass the class test.
> 

__`Value=@all`__ [ `@all` | function ]
> 
> Function (function handle) that will be applied to each field value; the
> `Value` function must return a `true` or `false` for any field value;
> `@all` means all fields pass the value test.
> 

## Description


## Example

