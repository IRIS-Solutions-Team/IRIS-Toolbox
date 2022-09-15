---
title: isLinear
---

# `isLinear` ^^(Model)^^

{== True if the model has been declared as linear ==}


## Syntax 

    flag = isLinear(m)


## Input arguments 

`m` [ Model ]
> 
> Model object whose linear status will be returned.
> 


## Output arguments 

`flag` [ `true` | `false` ]
> 
> True if the model has been declared linear
> 


## Options 



## Description 

The value returned dependes on whether the model has been declared as
linear by the user when constructing the model object. The status returned
by `isLinear` has nothing to do with whether or not the model is actually linear.


## Examples

Read the same model file twice, with a different option `linear=` assigned.

```matlab
>> m = Model.fromFile('some.model');
>> isLinear(m)

ans =
     0

>> m = Model.fromFile('some.model', linear=true);
>> isLinear(m)

ans =
     1
```

