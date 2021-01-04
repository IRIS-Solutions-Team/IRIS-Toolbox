# `toString`

Print IrisT dates as formatted strings


## Syntax

    outputString = function(inputDate, format)


## Input Arguments

__`inputDate`__ [ Dater | numeric ]

> Input date (a Dater object or a plain numeric representation) that will
> be printed as a string.


## Output Arguments

__`outputString`__ [ string ]

> Output string printed from the `inputDate`.


__`format`__ [ string ]

> Formatting string; see Description.


## Options

__`Open=""`__ [ string ]

> String to denote the beginning of a date formating token; use the options
> `Open` and `Close` to handle more complex date formatting strings where
> you need to include literal text containing some of the formatting
> characters.


__`Close=""`__ [ string ]

> String to denote the end of a date formating token; use the options
> `Open` and `Close` to handle more complex date formatting strings where
> you need to include literal text containing some of the formatting
> characters.


## Description

The formatting string consists of date formatting tokens and literal text.

This is the list of the date formatting tokens available; they are case
sensitive:

| Token             | Result                                                   |
|-------------------|----------------------------------------------------------|
| "yyyy"            | Four-digit year                                          |
| "yy"              | Last two digits of the year                              |
| "y"               | Plain numeric year with as many digits as needed         |
| "mmmm"            | Full name of the month                                   |
| "mmm"             | Three-letter abbreviation of the month name              |
| "mm"              | Two-digit month                                          |
| "m"               | Plain numeric month with as many digits as needed        |
| "n"               | Month in lower-case romanu numeral                       |
| "N"               | Month in upper-case romanu numeral                       |
| "pp"              | Two-digit period                                         |
| "p"               | Plain numeric period with as many digits as needed       |
| "q"               | Period in lower-case roman numerals                      |
| "Q"               | Period in upper-case roman numerals                      |
| "f"               | Frequency in lower-case letter                           |
| "F"               | Frequency in upper-case letter                           |
| "dd"              | Two-digit day                                            |
| "d"               | Plain numeric day with as many digits as needed          |


## Example



-[IrisToolbox] for Macroeconomic Modeling
-Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

