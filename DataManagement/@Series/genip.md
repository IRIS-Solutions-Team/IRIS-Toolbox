---
title: genip
---

# `genip` ^^(Series)^^

{== Generalized indicator based interpolation ==}


## Syntax 

    [highOutput, info] = genip(lowInput, highFreq, order, aggregation, ...)


## Input arguments 

__`lowInput`__ [ Series ] 
> 
> Low-frequency input series that will be interpolated to the `highFreq`
> frequency using the `Indicator...` and hard conditions specified in `Hard...`
> 

__`highFreq`__ [ Frequency ]
> 
> Target frequency to which the `lowInput` series will be interpolated;
> `highFreq` must be higher than the date frequency of the `lowInput`.
> 

__`order`__ [ `0` | `1` | `2` ]
> 
> Autoregressive order of the transition equation for the dynamics
> of the interpolated series, and for the relationship between
> the interpolated series and the indicator (if included).
> 

__`aggregation`__ [ `"mean"` | `"sum"` | `"first"` | `"last"` | numeric ]
> 
> Type of aggregation of quarterly observations to yearly observations;
> the `aggregation` can be assigned a `1-by-N` numeric vector with
> the weights given, respectively, for the individual high-frequency
> periods within the encompassing low-frequency period.
> 

## Output arguments 

__`highOutput`__ [ Series ] 
> 
> High-frequency output series constructed by interpolating the input
> `lowInput` using the dynamics of the `indicator`.
> 

__`info`__ [ struct ]
> 
> Output information struct with the the following fields:
> 

__`.FromFreq`__ 
> 
> Original (low) frequency of the input series
> 

__`.ToFreq`__ 
> 
> Target (high) frequency to which the input series has been interpolated
> 

__`.LowRange`__ 
> 
> Low frequency date range from which the input series has been interpolated
> 

__`.HighRange`__ 
> 
> High frequency date range to which the input series has been interpolated
> 

__`.EffectiveLowRange`__
> 
> Low frequency range after excluding years with full conditioning level information
> 

__`.StackedSystem`__
> 
> Stacked-time linear system (StackedSystem) object used to run the interpolation
> 


## Options 

__`Range=Inf`__ [ `Inf` | Dater ]
> 
> Low-frequency range on which the interpolation will be calculated;
> `Inf` means from the date of the first observation to
> the date of the last observation in the `lowInput` time series.
> 

__`ResolveConflicts=true`__ [ `true` | `false` ]
> 
> Resolve potential conflicts (singularity) between the `lowInput`
> obervatations and the data supplied through the `HighLevel=` option.
> 

__`IndicatorLevel=[ ]`__ [ empty | Series ] 
> 
> High-frequency indicator whose dynamics will be used to interpolate
> the `lowInput`.
> 

__`IndicatorModel="Difference"`__ [ `"Difference"` | `"Ratio"` ]
> 
> Type of model for the relationship between the interpolated series
> and the indicator in the transition equation: `"Difference"`
> means the indicator will be subtracted from the series, `"Ratio"`
> means the series will be divided by the indicator.
> 

__`Initials=@auto`__ [ `@auto` | Series ]
> 
> Initial (presample) conditions for the Kalman filter; `@auto` means
> the initial condition will be extracted from the `HardLevel`
> time series; if no observations are supplied either directly
> through `Initials` or through `HardLevel`, then the initial
> condition will be estimated by maximum likelihood.
> 

__`HardLevel=[ ]`__ [ empty | Series ]
> 
> Hard conditioning information; any values in this time series within
> the interpolation range or the presample initial condition (see also
> the option `Initials`) will be imposed on the resulting `highOutput`.
> 

__`TransitionIntercept=0`__ [ numeric | `@auto` ]
> 
> Intercept in the transition equation; if `@auto` the intercept will
> be estimated by GLS.
> 

## Description 

The interpolated `lowInput` is obtained from the first element of the state
vector estimated using the following quarterly state-space model
estimated by a Kalman filter:

### State transition equation 

$$ \left(1 - L\right)^k \hat x_t = v_t $$

where $ \hat x_t $ is a transformation of the unobserved higher-frequency
interpolated series, $ x_t $, depending on the option `Indicator.Model`,
and $v_t$ is a transition error with constant variance. The
transformation $\hat x_t$ is given by:

* $ \hat x_t = x_t $ if no indicator is specified;

* $ \hat x_t = x_t - q_t $ if an indicator $ q_t $ is entered through
`Indicator.Level=` and `Indicator.Model="Difference"`;

* $ \hat x_t = x_t / q_t $ if an indicator $ q_t $ is entered through
`Indicator.Level=` and `Indicator.Model="Ratio"`;

$ L $ is the lag operator, $ k $ is the order of differencing
specified by `order`.

### Measurement equation ###

$$ y_t = Z x_t $$

where 

* $ y_t $ is a measurement variables containing the lower-frequency data
placed in the last (fourth) quarter of every year; in other words, only
every fourth observation is available, and the three in between are
missing

* $ x_t $ is a state vector consisting of $N$ elements, where $N$
is the number of high-frequency periods within one low-frequency period:
the unobserved high-frequency lags $t-N, \dots, t-1, t$.

* $ Z $ is a time-invariant aggregation matrix depending on
`aggregation`: 
    * $ Z=[1, 1, 1, 1] $ for `aggregation="Sum"`, 
    * $ Z=[1/4, 1/4, 1/4, 1/4] $ for `aggregation="Average"`, 
    * $ Z=[0, 0, 0, 1] $ for `aggregation="Last"`, 
    * $ Z=[1, 0, 0, 0] $ for `aggregation="First"`, 
    * or a user supplied 1-by-$ N $ vector

* $ w_t $ is a vector of measurement errors associated with soft
conditions.

## Examples

```matlab
```

