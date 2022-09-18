---
title: Dater.ii
---

# `Dater.ii`

{== Create integer dates (numbered observations) ==}


## Shortcut Syntax to Create Dater Objects

    date = ii(integer)


## Syntax to Create Dater Objects

    date = Dater.ii(...)


## Syntax to Create Numeric Date Codes

    dateCode = dater.ii(...)


## Input Arguments

`integer` [ numeric ] 

> Integer number, any non-integers will be floored.


## Output Arguments

`date` [ Dater ]

> Integer date returned as a Dater object.


`dateCode` [ numeric ]

> Inteeger date returned as a numeric datecode.


## Description

This function is unnecessary and exists for consistency only; simply use
plain vectors of integers when integer dates are needed.


## Example

Create time series whose observations are numbered 1:10 (no calendar
dates):

```
    x = Series(ii(1:10), @rand);
```

Instead of `ii(1:10)`, simply use `1:10`:

```
    x = Series(1:10, @rand);
```


