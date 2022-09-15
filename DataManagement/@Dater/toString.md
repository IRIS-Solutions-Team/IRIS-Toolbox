---
title: toString
---

# `toString`

{== Print date as formatted string ==}


## Syntax

    outputString = toString(inputDate, format)


## Input Arguments

__`inputDate`__ [ Dater | numeric ]

> Input date (a Dater object or a plain numeric representation) that will
> be printed as a string.


## Output Arguments

__`outputString`__ [ string ]

> Output string printed from the `inputDate`.


__`format`__ [ string ]

> Formatting string; see Description for formatting tokens that can be used
> in the `format`.


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

The formatting string may consist of date formatting tokens and literal
text. If you need to use plain literal text whose part or parts coincide with the
formatting tokens, use the options `Open` and/or `Close` to delineate those
tokens and differentiate them from plain literal text; see Example of Open/Close options.

This is the list of the date formatting tokens available; all date
formatting tokens are case sensitive:

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
| "r"               | Period in lower-case roman numerals                      |
| "R"               | Period in upper-case roman numerals                      |
| "f"               | Frequency in lower-case letter                           |
| "F"               | Frequency in upper-case letter                           |
| "dd"              | Two-digit day                                            |
| "d"               | Plain numeric day with as many digits as needed          |


## Example of Plain Vanilla Date Formatting

Format Dater objects:

```
    t = qq(2020,1);
    toString(t, "yyyy-p")
```

Format plain numeric dates:

```
    t = dater.qq(2020,1);
    dater.toString(t, "yyyy-p");
    ans =
        "2020-1"
```


## Example of `Open`/`Close` Options

Print a quarterly date as `"y2020-q1"`. Because the leading literal `"y"`
conflicts with the formatting token `"y"`, specify at least one of the options
`Open` and/or `Close` to differentiate between plain text and formatting
tokens:

```python
def bubble_sort(items):
    for i in range(len(items)):
        for j in range(len(items) - 1 - i):
            if items[j + 1] < items[j]
                items[j], items[j + 1] = items[j + 1], items[j]
```

cccc

```
    t = qq(2020,1)
    toString(t, "y(yyyy)-q(p)", "open", "(", "close", ")")
    ans =
        "y2020-q1"
```

Alternatively, do the same using the option `Open` only:

```matlab
    t = qq(2020,1)
    toString(t, "y%yyyy-q%p", "open", "%")
    ans =
        "y2020-q1"
```

