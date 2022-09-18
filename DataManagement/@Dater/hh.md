---
title: Dater.hh
---

# `Dater.hh`

{== Create half-yearly dates ==}


## Shortcut syntax to create Dater objects

    date = hh(year, half)
    date = hh(year, "end")
    date = hh(year)


## Syntax to create Dater objects

    date = Dater.hh(___)


## Syntax to create numeric date codes

    dateCode = dater.hh(___)


## Input arguments

`year` [ numeric ] 

> Calendar year.


`half=1` [ numeric ]

> Halfyear of the year; "end" means `half=2`.


## Output arguments

`date` [ Dater ]

> Halfyearly date returned as a Dater object.


`dateCode` [ numeric ]

> Halfyearly date returned as a numeric datecode.


## Description


## Example

Calculate the number of halfyears between two halfyearly dates

```matlab
t1 = hh(2020,1);
t2 = hh(2024,2);
n = t2 - t1
```

