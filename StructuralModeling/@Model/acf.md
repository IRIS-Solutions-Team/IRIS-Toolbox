---
title: acf
---

# `acf` ^^(Model)^^

{== Autocovariance and autocorrelation function for model variables ==}


## Syntax 

    [C, R, list] = acf(model, ...)


## Input arguments 

__`model`__ [ Model ]
> 
> A solved model object for which the autocorrelation function will be
> computed.
> 


## Output arguments 


__`C`__ [ NamedMat | numeric ]
> 
> Covariance matrices for measurement and transition variables.
> 

__`R`__ [ NamedMat | numeric ]
> 
> Correlation matrices for measurement and transition variables.
> 

__`list`__ [ string ]
> 
> List of variables in rows and columns of `C` and `R`.
> 

## Options 

__`ApplyTo=@all`__ [ string | `@all` ]
> 
> List of variables to which the `Filter=` will be applied; `@all` means
> all variables.
> 

__`Contributions=false`__ [ `true` | `false` ]
> 
> If `true` the contributions of individual shocks to ACFs will be computed
> and stored in the 5th dimension of the `C` and `R` matrices.
> 

__`Filter=""`__ [ string ]
> 
> Linear filter that is applied to variables specified by the option
>`ApplyTo=`.
> 

__`NFreq=256`__ [ numeric ]
> 
> Number of equally spaced frequencies over which the filter in the option
> `filter=` is numerically integrated.
> 


__`Order=0`__ [ numeric ]
> 
> Order up to which ACF will be computed.
> 

__`MatrixFormat="NamedMatrix"`__ [ `"NamedMatrix"` | `"plain"` ] 
> 
> Return matrices `C` and `R` as either
> [NamedMatrix](../../DataManagement/@NamedMatrix/index.md) objects
> (matrices with named rows and columns) or plain numeric arrays.
> 

__`Select=@all`__ [ `@all` | string ]
> 
> Return ACF for selected variables only; `@all` means all variables.
> 

## Description 

The output matrices, `C` and `R`, are both n-by-n-by-(p+1)-by-v matrices,
where n is the number of measurement and transition variables (including
auxiliary lags and leads in the state space vector), p is the order up to
which the ACF is computed (controlled by the option `Order=`), and v is
the number of parameter variants in the input model object, `M`.

If `Contributions=true`, the size of the two matrices is
n-by-n-by-(p+1)-by-k-by-v, where k is the number of all shocks
(measurement and transition) in the model.


### Linear filters


You can use the option `Filter=` to get the ACF for variables as though
they were filtered through a linear filter. You can specify the filter in
both the time domain (such as first-difference filter, or
Hodrick-Prescott) and the frequncy domain (such as a band of certain
frequncies or periodicities). The filter is a text string in which you
can use the following references:

* `'L'` for the lag operator, which will be replaced with `'exp(-1i*freq)'`

* `'per'` for the periodicity

* `'freq'` for the frequency


## Example


A first-difference filter (i.e. computes the ACF for the first
differences of the respective variables):

```matlab
[C, R] = acf(m, 'Filter', '1-L')
```


## Example


The cyclical component of the Hodrick-Prescott filter with the smoothing
parameter, \(\lambda\), set to 1,600. The formula for the filter follows
from the classical Wiener-Kolmogorov signal extraction theory, 

$$
w(L) = \frac{\lambda}{\lambda + \frac{1}{ | (1-L)(1-L) | ^2}}
$$

```matlab
[C, R] = acf(m, 'filter', '1600/(1600 + 1/abs((1-L)^2)^2)')
```


## Example


A band-pass filter with user-specified lower and upper bands. The
band-pass filters can be defined either in frequencies or periodicities;
the latter is usually more convenient. The following is a filter which
retains periodicities between 4 and 40 periods (this would be between 1
and 10 years in a quarterly model), 

```matlab
[C, R] = acf(m, 'filter', 'per>=4 & per<=40')
```


