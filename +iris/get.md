---
title: iris.get
---

# `iris.get`

{== Get values of Iris configuration settings ==}


## Syntax

    value = iris.get(query)
    config = iris.get()


## Input arguments 


__`query`__ [ string ] 
> 
> Name of an IRIS configuration setting.
> 


## Output arguments


__`value`__ [ * ] 
> 
> Current value of the configuration setting.
> 


__`config`__ [ iris.Configuration ] 
>  
> An iris.Configuration object with all current configuration settings.
> 


## Description

You can view any of the modifiable options listed in
[`iris.set`](), plus the following non-modifiable ones
(these cannot be changed by the user):

__`'irisRoot'`__ returns [ string ] 
> 
> The current IRIS root directory.
> 

__`'version'`__ returns [ string ] 
> 
> The current IRIS version string.
> 

When called without any input arguments, the `iris.get()` function returns
a struct with all options and their current values.

When used as input arguments in the `iris.get()` function, the option names
are case-insensitive. When referring to field names of an output struct
returned by the `iris.get()` function, all option names are lower-case and
case-sensitive.


## Examples

```matlab
iris.get('dateFormat')
ans =
YFP

g = iris.get();
g.dateformat
ans =
YFP
```

