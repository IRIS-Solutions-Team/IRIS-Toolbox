---
title: moving
---

# `moving` ^^(Series)^^

{== Apply function to moving window of time series observations ==}


## Syntax  

    outputSeries = moving(inputSeries, ...)


## Input arguments  

__`inputSeries`__ [ Series ]
> 
> Input times series.
> 

## Output arguments  

__`outputSeries`__ [ Series ]
> 
> Output time series with their observations constructed by applying the
> the function `Function=` to a moving window `Window=` of observations
> from the `inputSeries`.
> 

## Options   

__`Function=@mean`__ [ function_handle ]
> 
> Function to be applied to moving window of observations. By default, the
> function is supposed to accept two input arguments: an array of data, and
> the dimension along which the function will be calculated (this is the
> way the standard built-int `@mean`, `@sum`, etc. functions work).
> 

__`Period=false`__ [ `true` | `false` ]
> 
> Force the calculations to be put in a loop period by period and refrain
> from using dimension as a second input argument into the `Function`. This
> options works only when `Window=` is not a complex number (in which case
> the calculations are always period by period).
> 
> Under the default `Period=false`, the function is evaluated on a whole
> array of observations, and supplied a second input argument `1` to
> indicate the dimension along which the function is to be calculated. This
> is consistent with standard functions such as `mean`, `sum`, etc.
> 
> If `Period=true`, the function `Function=` is evaluated on a column
> vector of observations constituting the moving window for the current
> period only (determined by the `Window=` specification), one period at a
> time. 
> 

__`Range=Inf`__ [ Dater | `Inf` ]
> 
> Date range to which the `inputSeries` will be trimmed before running the
> calculations.
> 

__`Window=@auto`__ [ numeric | `@auto` ]
> 
> The moving window of observations to which the function `Function=` will
> applied to construct the observations of the `outputSeries`; see
> Description and Examples.
> 

## Description

The moving window of observations can be specificied in three different ways:

Moving window | Option `Window=` | Comment
--|---|---
Moving year of observations | `@auto` | The window depends on the date frequency of the `inputSeries`; only available for yearly, half-yearly, quarterly and monthly frequencies 
Exact specification of lags and leads | Vector of real integers | Negative for lags, positive for leads, zero for current period 
Fixed number of non-missing observations | Complex number (scalar) | Negative imaginary part means the number of observations going back in time (starting from current), positive imaginary part means going forward in time 


### Exact specification of moving window

Use a vector of integers to specify an exact composition of the moving
window. Negative numbers mean lags (observations before the current
observation), positive numbers mean leads (observations after the current
observation), zero means the current observation:

$$
\begin{gathered}
\mathit{window} = \left[ a, b, c, \dots \right] \\[5pt]
y_t = f\left( \left[ x_{t+a}, x_{t+b}, x_{t+c}, \dots \right] \right)
\end{gathered}
$$

If some of the observations are missing, they are still included in the
window (typically a `NaN` for plain numeric time series), and the result
may be a missing observation again. This depends on the function used,
consider, for instance, the difference between `@mean` and `@nanmean`.


### Moving window depending on the availability of observations

Use a complex number (with a real part denoting the offset and the
imaginary part specifying the length of the window) to specify a window
consisting of a fixed number of available (non-missing) observations from
the current observation backward, or from the current observation forward
(positive imaginary part). The a nonzero offset means that the available
(non-missing) observation will be looked up starting not from the current
observation, but from an observation before (a negative offset) or after (a
positive offset).

If $\mathit{window}=a + bi$, the algorithm is as follows:

* For each period $t$, define the output value $y_t$ by applying the
   function $f$ to a vector of a total of $b$ observations from the input
   series $x_t$ constructed as described in steps 2 and 3.

If the window length (the imaginary part) $b$ is a negative number:

* Take all observations starting from $x_{t+a}$ (i.e. from the current
   observation if $a=0$, or from an observation before or after shifted by
   the offset $a$) going backward, i.e. $x_{t+a}, x_{t+a-1}, x_{t+a-2},
   \dots$, all the way to the very first observation available.

* Exclude any missing observations from this collection. From the remaining
   non-missing observations, take a total of $b$ observations starting from
   the most recent observation going backward.

If the window length (the imaginary part) $b$ is a positive number:

* Take all observations starting from $x_{t+a}$ (i.e. from the current
   observation if $a=0$, or from an observation before or after shifted by
   the offset $a$) going forward, i.e. $x_{t+a}, x_{t+a+1}, x_{t+a+2},
   \dots$, all the way to the very last observation available.

* Exclude any missing observations from this collection. From the remaining
   non-missing observations, take a total of $b$ observations starting from
   the most recent observation going forward.


## Examples

### Centered moving average and sum

Calculate a centered moving average with a total length of the window being 5
observations:

```matlab
x = moving(x, "window", [-2, -1, 0, 1, 2])
```

or more concisely

```matlab
x = moving(x, "window", -2:2)
```
Calculate a moving sum on the same window of observations:

```
x = moving(x, "window", -2:2, "function", @sum)
```


### Weighted centered moving average

Supply a user defined function to calculate a weighted centered moving
average (with the window specification as in the previous example); we have
to use the option `Period=true` in this case because our function
`weightedAverage` assumes that its input argument is only a vector of 5
numbers (the moving window of observations corresponding to the current
period).

```matlab
func = @(x) 0.10*x(1) + 0.15*x(2) + 0.50*x(3) + 0.15*x(4) + 0.10*x(5);
y = moving(x, "window", -2:2, "function", func, "period", true)
```

This is though equivalent to a more compact expression

```matlab
y = 0.10*x{-2} + 0.15*x{-1} + 0.50*x + 0.15*x{1} + 0.10*x{2}
```


### Average of 5 last available observations

Create a daily series of random observations, and remove weekends; the time
series will therefore have `NaN`s in two out of every seven observations:

```matlab
x = Series(dd(2000,1,1):dd(2020,12,31), @randn);
x = removeWeekends(x);
```

Create a time series by calculating the average of the five most recent
observations available (i.e. excluding any missing observations):

```matlab
y0 = moving(x, "window", -5i)
```

Create a time series by calculating the average of the five most recent
observations available as before, but now starting from the previous month
(not including the current observation); in other words, select the latest
available five observations among $x_{t-1}, x_{t-2}, \dots$

```matlab
y1 = moving(x, "window", -1-5i)
```

