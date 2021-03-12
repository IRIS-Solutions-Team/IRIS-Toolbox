# `dd  |  Dater.dd  |  dater.dd`

{== Create daily dates ==}


## Shortcut syntax for Dater objects

    date = dd(year, month, day)
    date = dd(year, month, "end")
    date = dd(year, month)
    date = dd(year)


## Syntax for Dater objects

    date = Dater.dd(...)


## Syntax for numeric date codes

    date = dater.dd(...)


## Input arguments

`year` [ numeric ] 

> Calendar year.


`month=1` [ numeric ] 

> Calendar month.


`day=1` [ numeric ]

> Week of the year; "end" means the last day of the respective `month`
> (considering leap years for February).


## Output arguments

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

