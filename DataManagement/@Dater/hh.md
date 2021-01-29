# `hh`, `Dater.hh`, `dater.hh`

{== Create half-yearly dates ==}


## Shortcut Syntax to Create Dater Objects

    date = hh(year, half)
    date = hh(year, "end")
    date = hh(year)


## Syntax to Create Dater Objects

    date = hh(...)


## Syntax to Create Numeric Date Codes

    dateCode = dater.hh(...)


## Input Arguments

`year` [ numeric ] 

> Calendar year.


`half=1` [ numeric ]

> Halfyear of the year; "end" means `half=2`.


## Output Arguments

`date` [ Dater ]

> Halfyearly date returned as a Dater object.


`dateCode` [ numeric ]

> Halfyearly date returned as a numeric datecode.


## Description


## Example

Calculate the number of halfyears between two halfyearly dates

    t1 = hh(2020,1);
    t2 = hh(2024,2);
    n = t2 - t1

