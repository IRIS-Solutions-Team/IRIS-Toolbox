---
title: regress
---

# `regress`

{== Estimate parameters and residual models in Explanatory object ==}

## Syntax

    [expy, outputDb, info] = regress(expy, inputDb, fittedRange, ...)


##  Input Arguments

__`expy`__ [ Explanatory ]
> 
> Explanatory object or array whose parameters (associated with
> regression terms) will be estimated by running a single-equation
> linear regression; only those parameters that have the corresonding
> element in `.Fixed` set to `NaN` will be estimated.k
> 

__`inputDb`__ [ struct | Dictionary ]
> 
> Input databank from which the time series for each variable in the
> Explanatory object or array will be retrieved.
> 

__`fittedRange`__ [ DateWrapper ]
> 
> Date range on which the linear regression(s) will be fitted; this
> range does not include the pre-sample initial condition if there are
> lags in the Explanatory object or array.
> 

## Output Arguments

__`expy`__ [ Explanatory ]
> 
> Output Explanatory object or array with the parameters estimated.
> 

__`outputDb`__ [ struct | Dictionary ]
> 
> Output databank inclusive of the fitted values and residuals (whose
> names will be created using the `.FittedNamePattern` and
> `.ResidualNamePattern`.
> 

__`info`__ [ struct ]
> 
> Information structure with the following fields:
> 
> * `.FittedRange` - A K-by-N cell array with the dates of the fitted
>   periods for each of the K equations and each of the N data pages or
>   parameter variants.
> 
> * `.ExitFlagsResidualModels` - A K-by-N numeric array with the
>   Optimization Tbx exit flags from estimating the residual models; `NaN`
>   means no residual model was estimated.
> 
> * `.ExitFlagsParameters` - A K-by-N numeric array with the Optimization
>   Tbx exit flags from estimating the parameters; `NaN` means the
>   parameters were estimated by linear regression with no iterative
>   procedure.
> 

##  Options

__`AppendInput=false`__ [ `true` | `false` ]
> 
> Append post-sample data from the `inputDb` to the `outputDb`.
> 

__`MissingObservations="warning"` [ `"error"` | `"warning"` | `"silent"` ]
> 
> Action taken when some within-sample observations are missing:
> `"error"` means an error message will be thrown; `"warning"` means
> these observations will be excluded from the estimation sample with a
> warning; `"silent"` means these observations will be excluded from
> the estimation sample silently.
> 

__`PrependInput=false`__ [ `true` | `false` ]
> 
> Prepend pre-sample data from the `inputDb` to the `outputDb`.
> 

## Description


## Example

Create an Explanatory object from a string inclusive of three regression
terms, i.e. additive terms preceded by `+@*` or `-@*`:

```matlab
expy0 = Explanatory.fromString("difflog(x) = @ + @*difflog(x{-1}) + @*log(z)");
expy0.Parameters
```

Assign some parameters to the three regression terms:

```matlab
expy0.Parameters = [0.002, 0.8, 1];
```

Simulate the equation period by period, using random shocks (names `'res_x'`
by default) and random observations for `z`:

```matlab
rng(981);
d0 = struct();
d0.x = Series(qq(2020,1), ones(40,1));
d0.z = Series(qq(2020,1), exp(randn(40, 1)/10));
d0.res_x = Series(qq(2020,1), randn(40, 1)/50);

d1 = simulate(expy0, d0, qq(2021,1):qq(2029,4));
```

Estimate the parameters using the simulated data, and compare the
parameter estimates and the estimated residuals with their "true" values:

```matlab
[expy2, d2] = regress(expy0, d1, qq(2021,1):qq(2029,4));
[ expy0.Parameters; expy2.Parameters ]
plot([d0.res_x, d2.res_x]);
```

