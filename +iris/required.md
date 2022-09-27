---
title: iris.required
---

# `iris.required`

{== Throw error if the Iris release currently running fails to comply with the required minimum ==}


## Syntax

    iris.required(release)


## Input arguments

__`release`__ [ string | numeric ]
> 
> Text string describing the oldest acceptable release number of the Iris.
> 


## Description

If the Iris release present on the computer does not comply with the
minimum requirement `release`, an error is thrown.


## Example

These two calls to `iris.required` are equivalent:

```matlab
iris.required(20111222)
iris.required("20111222")
```

