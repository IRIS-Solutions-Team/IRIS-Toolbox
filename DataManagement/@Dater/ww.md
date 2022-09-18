---
title: Dater.ww
---

# `Dater.ww`

{== Create weekly dates ==}


## Shortcut Syntax to Create Dater Objects

    date = ww(year, week)
    date = ww(year, "end")
    date = ww(year)
    date = ww(year, month, day)


## Syntax to Create Dater Objects

    date = Dater.ww(...)


## Syntax to Create Plain Numeric Date Codes

    dateCode = dater.ww(...)


## Input Arguments

`year` [ numeric ] 

> Calendar year.


`week=1` [ numeric ]

> Week of the year; "end" means `week=52` or `week=53` depending on the
> number of weeks in the year as defined by ISO-8601.


## Output Arguments

`date` [ Dater ]

> Weekly date returned as a Dater object.


`dateCode` [ numeric ]
> Weekly date returned as a numeric datecode.


## Description


## Example

Calculate the number of weeks between two weekly dates

```matlab
t1 = ww(2020,1);
t2 = ww(2020,"end");
n = t2 - t1
```


