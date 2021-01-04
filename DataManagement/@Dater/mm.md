# `mm`, `dater.mm`

Monthly date


## Syntax Creating Dater Objects

    date = mm(year, month)
    date = mm(year, "end")
    date = mm(year)


## Syntax Creating Numeric Date Codes

    dateCode = dater.mm(year, month)
    dateCode = dater.mm(year, "end")
    dateCode = dater.mm(year)


## Input Arguments

* `year` [ numeric ] 

> Calendar year.


* `month=1` [ numeric ]

> Month of the year; "end" means `month=12`.


## Output Arguments

* `date` [ Dater ]

> Monthly date returned as a Dater object.


* `dateCode` [ numeric ]

> Monthly date returned as a numeric datecode.


## Description


## Example

Calculate the number of months between two monthly dates

    t1 = mm(2020,01);
    t2 = mm(2023,12);
    n = t2 - t1

