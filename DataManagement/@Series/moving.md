# `moving`

{== Apply function to moving window of time series observation ==}


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
> Function to be applied to moving window of observations.
>

__`Period=false`__ [ `true` | `false` ]
>
> Force the calculations to be put in a loop period by period; this options
> works only whemn `Window=` is not a complex number (in which case the
> calculations are always period by period).
>
> If `true`, the function `Function=` is evaluated on a column vector of
> observations (determined by the `Window=` specification), one period at a
> time. 
>
> If `false`, the funcion is evaluated on a whole array of observations,
> and supplied a second input argument `1` to indicate the dimension along
> which the function is to be calculated. This is consistent with standard
> functions such as `mean`, `sum`, etc.
>

__`Range=Inf`__ [ Dater | `Inf` ]
>
> Date range to which the `inputSeries` will be trimmed before running the
> calculations.
>

__`Window=@auto` [ numeric | `@auto` ]
>
> The moving window of observations to which the function `Function=` will
> applied to construct the observations of the `outputSeries`; see
> Description and Examples.
>

## Description

The moving window of observations can be specificied in three different ways:

* Automatic specification; this only works for time series with a regular
  date frequency (yearly, half-yearly, quarterly, monthly); the window
  covers the last moving year including the current observation, e.g. $t$,
  $t-1$, $t-2$ and $t-3$ for quarterly series. This is equivalent to
  specifying `Window=[0, -1, -2, -3]`.

* An exact specification of lags or leads relative to the current
  observation.

* A fixed number of available (non-missing) observations from the current
  period (plus/minus an offset) backward or forward.


### Exact specification of moving window

Use a vector of integers to specify an exact composition of the moving
window. Negative numbers mean lags (observations before the current
observation), positive numbers mean leads (observations after the current
observation), zero means the current observation:

$$
\mathit{window} = \left[ a, b, c, \dots \right] \\[5pt]
y_t = f\left( \left[ x_{t+a}, x_{t+b}, x_{t+c}, \dots \right] \right)
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

1. For each period $t$, define the output value $y_t$ by applying the
   function $f$ to a vector of a total of $b$ observations from the input
   series $x_t$ constructed as described in steps 2 and 3.

If the window length (the imaginary part) $b$ is a negative number:

2. Take all observations starting from $x_{t+a}$ (i.e. from the current
   observation if $a=0$, or from an observation before or after shifted by
   the offset $a$) going backward, i.e. $x_{t+a}, x_{t+a-1}, x_{t+a-2},
   \dots$, all the way to the very first observation available.

3. Exclude any missing observations from this collection. From the remaining
   non-missing observations, take a total of $b$ observations starting from
   the most recent observation going backward.

If the window length (the imaginary part) $b$ is a positive number:

2. Take all observations starting from $x_{t+a}$ (i.e. from the current
   observation if $a=0$, or from an observation before or after shifted by
   the offset $a$) going forward, i.e. $x_{t+a}, x_{t+a+1}, x_{t+a+2},
   \dots$, all the way to the very last observation available.

3. Exclude any missing observations from this collection. From the remaining
   non-missing observations, take a total of $b$ observations starting from
   the most recent observation going forward.


## Example

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
average (with the window specification as in the previous example); note
that we have to use `period=true` in this case:

```matlab
func = @(x) 0.10*x(1) + 0.15*x(2) + 0.50*x(3) + 0.15*x(4) + 0.10*x(5);
y = moving(x, "window", -2:2, "function", func, "period", true)
```

This is though equivalent to a more compact expression

```matlab
y = 0.10*x{-2} + 0.15*x{-1} + 0.50*x + 0.15*x{1} + 0.10*x{2}
```


### Average of 5 last available observations

Create a daily series of random observations, and remove weekends:

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
observations available, however now not including the current observation
(i.e. select the last five observations from $x_{t-1}, x_{t-2}, \dots$

```matlab
y1 = moving(x, "window", -1-5i)
```

