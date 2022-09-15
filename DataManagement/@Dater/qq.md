---
title: Dater.qq
---

# `Dater.qq`

{== Create quarterly dates ==}


## Syntax shortcuts to create dater objects

    date = qq(year, quarter)
    date = qq(year, "end")
    date = qq(year)


## Syntax to create dater objects

    date = Dater.qq(...)


## Syntax to create numeric date codes

    dateCode = dater.qq(...)


## Input arguments

__`year`__ [ numeric ] 

> Calendar year.


__`quarter=1`__ [ numeric | `"end"` ]

> Quarter of the year; `"end"` means `quarter=4`.


## Output arguments

__`date`__ [ Dater ]

> Quarterly date returned as a Dater object.


__`dateCode`__ [ numeric ]

> Quarterly date returned as a numeric datecode.


## Description


## Examples

Calculate the number of quarters between two quarterly dates

    t1 = qq(2020,1);
    t2 = qq(2020,4);
    n = t2 - t1

