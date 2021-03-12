# `qq  |  Dater.qq  |  dater.qq`

{== Create quarterly dates ==}


## Shortcut Syntax to Create Dater Objects

    date = qq(year, quarter)
    date = qq(year, "end")
    date = qq(year)


## Syntax to Create Dater Objects

    date = Dater.qq(...)


## Syntax to Create Numeric Date Codes

    dateCode = dater.qq(...)


## Input Arguments

__`year`__ [ numeric ] 

> Calendar year.


__`quarter=1`__ [ numeric | `"end"` ]

> Quarter of the year; `"end"` means `quarter=4`.


## Output Arguments

__`date`__ [ Dater ]

> Quarterly date returned as a Dater object.


__`dateCode`__ [ numeric ]

> Quarterly date returned as a numeric datecode.


## Description


## Example

Calculate the number of quarters between two quarterly dates

    t1 = qq(2020,1);
    t2 = qq(2020,4);
    n = t2 - t1

