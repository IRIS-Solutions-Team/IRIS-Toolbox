# `qq`, `dater.qq`

Quarterly date


## Syntax Creating Dater Objects

    date = qq(year, quarter)
    date = qq(year, "end")
    date = qq(year)


## Syntax Creating Numeric Date Codes

    dateCode = dater.qq(year, quarter)
    dateCode = dater.qq(year, "end")
    dateCode = dater.qq(year)


## Input Arguments

* `year` [ numeric ] 

> Calendar year.


* `quarter=1` [ numeric ]

> Quarter of the year; "end" means `quarter=4`.


## Output Arguments

* `date` [ Dater ]

> Quarterly date returned as a Dater object.


* `dateCode` [ numeric ]

> Quarterly date returned as a numeric datecode.


## Description


## Example

Calculate the number of quarters between two quarterly dates

    t1 = qq(2020,1);
    t2 = qq(2020,4);
    n = t2 - t1

