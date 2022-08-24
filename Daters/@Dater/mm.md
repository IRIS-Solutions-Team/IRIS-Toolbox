---
title: Dater.mm
--

{== Create monthly dates ==}


## Shortcut Syntax to Create Dater Objects

    date = mm(year, month)
    date = mm(year, "end")
    date = mm(year)


## Syntax to Create Dater Objects

    date = mm(...)


## Syntax to Create Numeric Date Codes

    dateCode = dater.mm(...)


## Input Arguments

`year` [ numeric ] 

> Calendar year.


`month=1` [ numeric ]

> Month of the year; "end" means `month=12`.


## Output Arguments

`date` [ Dater ]

> Monthly date returned as a Dater object.


`dateCode` [ numeric ]

> Monthly date returned as a numeric datecode.


## Description


## Example

Calculate the number of months between two monthly dates

    t1 = mm(2020,01);
    t2 = mm(2023,12);
    n = t2 - t1

