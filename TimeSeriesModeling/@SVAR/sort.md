---
title: sort
---

# `sort` ^^(SVAR)^^

{== Sort SVAR parameterisations by squared distance of shock reponses to median ==}


## Syntax

    [b, outputDb, inx, sortKey] = sort(a, inputDb, sortBy, ...)


## Input arguments

__`a`__ [ SVAR ]
> 
> SVAR object with multiple parameterisations that will
> be sorted.
> 

__`inputDb`__ [ struct | empty ]
> 
> SVAR database; if nonempty, the structural shocks will be re-ordered according to the SVAR parameterisations.
> 

__`sortBy`__ [ string ]
> 
> Text string that will be evaluated to compute the sort key by which the
> parameterisations will be ordered; see Description for how to write
> `sortBy`.
> 


## Output arguments

__`b`__ [ SVAR ]
> 
> SVAR object with parameterisations ordered by the
> specified sort key.
> 


__`outputDb`__ [ struct ]
> 
> SVAR data with the structural shocks re-ordered to correspond to the order of parameterisations.
> 


__`inx`__ [ numeric ]
> 
> Vector of indices so that `b = a(inx)`.
> 


__`sortKey`__ [ numeric ]
> 
> The value of the sort key based on the string `sortBy` for each parameterisation.
> 


## Options

__`Progress=false`__ [ `true` | `false` ]
> 
> Display progress bar in the command window.
> 


## Description

The individual parameterisations within the SVAR object `A` are sorted by
the sum of squared distances of selected shock responses to the
respective median reponses. Formally, the following sort key is
evaluated for each parameterisation

$$ \sum_{i\in I, j\in J, k\in K} \left[ S_{i, j}(k) - M_{i, j}(k) \right]^2 $$

where $S_{i, j}(k)$ denotes the response of the i-th variable to the j-th
shock in period k, and $M_{i, j}(k)$ is the median responses. The sets of
variables, shocks and periods, i.e. `I`, `J`, `K`, respectively, over
which the summation runs are determined by the user in the `SortBy`
string.

How do you select the shock responses that enter the sort key in
`SortBy`? The input argument `SortBy` is a text string that refers to
array `S`, whose element `S(i, j, k)` is the response of the i-th
variable to the j-th shock in period k.

Note that when you pass in SVAR data and request them to be sorted the
same way as the SVAR parameterisations (the second line in Syntax), the
number of parameterisations in `A` must match the number of data sets in
`Data`.


## Example

Sort the parameterisations by squared distance to median of shock
responses of all variables to the first shock in the first four periods.
The parameterisation that is closest to the median responses

```matlab
S2 = sort(S1, [ ], 'S(:, 1, 1:4)')
```

