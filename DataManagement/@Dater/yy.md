# `yy`, `dater.yy`

Yearly date


## Syntax Creating Dater Objects

    date = yy(year)


## Syntax Creating Numeric Date Codes

    dateCode = dater.yy(year)


## Input Arguments

* `year` [ numeric ] 

> Calendar year.


## Output Arguments

* `date` [ Dater ]

> Yearly date returned as a Dater object.


* `dateCode` [ numeric ]

> Yearly date returned as a numeric datecode.


## Description


## Example

Calculate the number of years between two yearly dates

    t1 = yy(2020);
    t2 = yy(2024);
    n = t2 - t1

