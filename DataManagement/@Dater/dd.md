# `dd`, `Dater.dd`, `dater.dd`

{== Create daily dates ==}


## Shortcut Syntax for Dater Objects

    date = dd(year, month, day)
    date = dd(year, month, "end")
    date = dd(year, month)
    date = dd(year)


## Syntax for Dater Objects

    date = Dater.dd(...)


## Syntax for Numeric Date Codes

    date = dater.dd(...)


## Input Arguments

`year` [ numeric ] 

> Calendar year.


`month=1` [ numeric ] 

> Calendar month.


`day=1` [ numeric ]

> Week of the year; "end" means the last day of the respective `month`
> (considering leap years for February).


## Output Arguments

`date` [ Dater ]

> Daily date returned as a Dater object.


`dateCode` [ numeric ]

> Daily date returned as a numeric datecode.


## Description

The underlying date codes of daily dates is exactly the same as the
standard Matlab serial date numbers.


## Example

Calculate the number of days between two daily dates

    t1 = dd(2020,02,01);
    t2 = dd(2020,02,"end");
    n = t2 - t1

