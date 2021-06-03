# rebase  

{== Rebase times series data to specified period ==}


## Syntax

    outputSeries = rebase(inputSeries, basePeriod, baseValue, ...)


## Input Arguments

__`inputSeries`__ [ Series ]
>
>  Input time series that will be rebased.
>

__`basePeriod="allStart"`__ [ Dater | `"allStart"` | `"allEnd"` ] -
> 
> Date relative to which the input data will be rebased (baseValue period);
> `'allStart'` means the first date for which all time series columns have
> a NaN observation; `'allEnd'` means the last such date.
> 

__`baseValue=1`__ [ `0` | `1` | `100` ]
>
> Rebasing mode and value:
>
> * `B=0` means additive rebasing with `0` in the `basePeriod`; 
>
> * `B=1` means multiplicative rebasing with `1` in the `basePeriod`;
>
> * `B=100` means multiplicative rebasing with `100` in the `basePeriod`.
>

## Output Arguments

__`outputSeries`__ [ Series ]
>
> Rebased time series.
>

## Description


## Example

