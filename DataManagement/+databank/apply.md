---
title: databank.apply
---

# `databank.apply` ^^(+databank)^^

{== Apply function to a selection of databank fields ==}


## Syntax

    [outputDb, appliedToNames, newNames] = databank.apply(inputDb, func, ...) 


## Input arguments

__`inputDb`__ [ struct | Dictionary ]
> 
> Input databank to whose fields the `function` will be applied.
> 

__`func`__ [ function_handle ]
> 
> Function (function handle) that will be applied to the selected fields of
> the `inputDb`.
> 

## Output arguments

__`outputDb`__ [ struct | Dictionary ]
> 
> Output databank created from the `inputDb` with new fields or some fields
> modified.
> 

__`appliedToNames`__ [ string ] 
> 
> List of names to which the `function` has been actually applied.
> 

__`newNames`__ [ string ] 
> 
> List of names under which the results are stored in the `outputDb`.
> 

## Options

__`StartsWith=""`__ [ string ] 
> 
> Apply the `function` to fields whose names start with this string.
> 

__`EndsWith=""`__ [ string ] 
> 
> Apply the `function` to fields whose names end with this string.
> 

__`RemoveStart=false`__ [ `true` | `false` ] 
> 
> If option `StartsWith=` was used, a new field will be created after the
> `function` has been applied with its named derived from the original name
> by removing the start of the string.
> 

__`RemoveEnd=false`__ [ `true` | `false` ] 
> 
> If option `EndsWith=` was used, a new field will be created after the
> `function` has been applied with its named derived from the original name
> by removing the end of the string.
> 

__`Prepend=""`__ [ char | string ] 
> 
> A new field will be created after the `function` has been applied with
> its named derived from the original name by prepending this string to the
> beginning of the original field name.
> 

__`Append=""`__ [ char | string ] 
> 
> A new field will be created after the `function` has been applied with
> its named derived from the original name by appending this string to the
> end of the original field name.
> 

__`RemoveSource=false`__ [ `true` | `false` ] 
> 
> Remove the source field from the `outputDb`; the source field is
> the `inputDb` on which the `function` was run to create a new
> field.
> 

__`SourceNames=@all`__ [ `@all` | cellstr | string ] 
> 
> List of databank field names to which the name selection procedure will
> be reduced.
> 

__`TargetNames=@default`__ [ `@default` | cellstr | string ] 
> 
> New names for output databank fields.
> 

__`TargetDb=@default`__ [ `@default` | struct | Dictionary ] 
> 
> Databank to which the transformed fields will be added;
> `TargetDb=@default` means they will be kept in the `inputDb`.
> 

__`WhenError="keep"`__ [ `"keep"` | `"remove"` | `"error"` ]
> 
> What to do when the function `func` fails with an error on a field:
> 
> * `"keep"` means the field will be kept in the `outputDb` unchanged;
> 
> * `"remove"` means the field will be removed from the `outputDb`;
> 
> * `"error"` means the execution of `databank.apply` will stop with an
>   error.
> 

## Description


## Example

Add 1 to all databank fields, regardless of their types. Note that the
addition also works for strings.

```matlab
d1 = struct( );
d1.x = Series(1:10, 1:10);
d1.b = 1:5;
d1.y_u = Series(qq(2010,1):qq(2025,4), @rand);
d1.s = "x";
d2 = databank.apply(d1, @(x) x+1); 
```

## Example

Seasonally adjust all time series whose name ends with `_u`.

```matlab
% Create random series, some with seasonal patterns

range = qq(2010,1):qq(2025,4);
s1 = Series.seasonDummy(range, 1);
s2 = Series.seasonDummy(range, 2);
s3 = Series.seasonDummy(range, 3);

d = struct();
d.x1_u = cumsum(Series(range, @randn)) + 4*s1 - 2*s2 + 2*s3;
d.x2_u = cumsum(Series(range, @randn)) - 1*s1 + 3*s2 - 7*s3;
d.x3_u = cumsum(Series(range, @randn)) + 7*s1 + 3*s2 - 5*s3;
d.x4 = cumsum(Series(range, @randn));
d.x5 = cumsum(Series(range, @randn));

databank.list(d)

% Apply the seasonal adjustment function to all fields whose name starts
% with `_u`; the seasonally adjusted series will be added to the databank
% under new names created by removing the `_u`
func = @(x) x13.season(x, "x11_mode", "add");
d = databank.apply(d, func, "endsWith", "_u", "removeEnd", true);

databank.list(d)
```

