---
title: rephrase.Table
---

# `rephrase.Table` ^^(+rephrase)^^

{== Create a Table object for rephrase reports ==}


## Syntax 

    output = rephrase.Table(title, dates, varargin)


## Input arguments 

__`title`__ [ string ]
> 
> Title text for the table.
> 

__`dates`__ [ numeric ]
> 
> Range of the data to be displayed which should match the
> format of the data.
> 

## Output arguments 

__`output`__ [ Table ]
> 
> Table type object with the assigned arguements to be passed
> into the rephrase objects.
> 

## Options 

__`DateFormat='YYYY:MM'`__ [ string ]
> 
> Date format to be displayed in the table.
> 

__`NumDecimals=2`__ [ numeric ]
> 
> Number of decimals to be displayed in the table.
> 

__`RowTitles=`__ [ struct ]
> 
> Struct containing row titles to be displayed in the table.
> 

__`ShowRows=`__ [ struct `struct('Baseline', true, 'Alternative', true, 'Diff', true)` ]
> 
> Struct of options setting whether to show specific rows.
> 

__`FirstCells=`__ [ string ]
> 
> Description
> 

__`ShowUnits=false`__ [ `true` | `false*` ]
> 
> Description
> 

__`UnitsHeading='Units'`__ [ string `Units` ]
> 
> Description
> 

## Possible children

`+rephrase/Series`
`+rephrase/DiffSeries`
`+rephrase/Heading`

## Description 

The function `+rephrase/Table` returns the Table object based on the input arguments and options set by the user. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Grid`.

## Examples

```matlab

table1 = rephrase.Table( ...
    "Table Name", range ...
    , "DateFormat", "YYYY:QQ" ...
    , "NumDecimals", 2 ...
    , "DisplayRows", struct("Diff", true, "Baseline", true, "Alternative", false) ...
    , "RowTitles", struct("Baseline","Title1","Alternative","Title2", "Diff", "Title3"));

```
