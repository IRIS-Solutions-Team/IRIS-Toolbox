---
title: databank.fieldNames
---

# `databank.fieldNames` ^^(+databank)^^

{== List of databank field names as a row vector of strings ==}


## Syntax

    list = databank.fieldNames(db)


## Input Arguments

__`db`__ [ struct | Dictionary ]
> 
> Databank, i.e. a struct or Dicionary object.
> 


## Output Arguments

__`list`__ [ string ]
> 
> List of all field names contained in the input `db`, arranged as a
> row vector of strings.
> 


## Description

The `databank.keys` function shadows the standard function `fieldnames`.
However, the output argument is rearranged as a row vector of strings, and
hence can be directly plugged into a `for` loop.


## Example

```matlab
d = struct();
d.x = Series(mm(2020,01), rand(24,1));
d.y = Series(yy(2010), rand(20,1));
d.z = Series(qq(2015,1), rand(40, 1));
for n = databank.fieldNames(d)
    startDateString = toDefaultString(getStart(d.(n))p);
    disp(n + ": " + startDateString);
end
```

