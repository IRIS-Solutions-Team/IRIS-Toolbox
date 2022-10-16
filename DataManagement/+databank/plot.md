---
title: databank.plot
---

# `databank.plot` ^^(+databank)^^

{== Quickly create a databank chartpack ==}


## Syntax

    [ch, info] = databank.plot(inputDb, list, ___)


## Input arguments 

__`inputDb`__ [ struct ]
> 
> Input databank from which the chartpack will be generated.
> 

__`list`__ [ string ]
> 
> A list of field names or expressions referring to `inputDb` fieldnames
> that will be plotted
> 

## Output arguments

__`ch`__ [ Chartpack ]
> 
> A new Chartpack object created within the function.
> 

__`info`__ [ struct ]
> 
> An info struct returned from the `Chartpack/draw` function.
> 

## Options

Any `Chartpack` property can be assigned as an option in
`databank.plot`.


## Description


## Example

```matlab
d = struct();
d.x = Series(qq(2020,1), rand(40, 1));
d.y = Series(qq(2020,1), rand(40, 1));
d.z = Series(qq(2020,1), rand(40, 1));
ch = databank.plot(d, ["x", "100*y", "z-x"]);
```

