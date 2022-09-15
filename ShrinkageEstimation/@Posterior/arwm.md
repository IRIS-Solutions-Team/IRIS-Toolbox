---
title: arwm
---

# `arwm`

{== Adaptive random-walk Metropolis posterior simulator ==}


## Syntax 

    [theta, poster, acceptRatio, poster, scale, finalCov] = arwm(poster, numDraws, ...)


## Input arguments 

__`poster`__ [ poster ]
> 
> Initialized posterior simulator object.
> 

__`numDraws`__ [ numeric ]
> 
> Length of the chain not including burn-in.
> 

## Output arguments 

__`theta`__ [ numeric ]
> 
> MCMC chain with individual parameters in rows.
> 

__`poster`__ [ numeric ]
> 
> Vector of log posterior density (up to a constant) in each draw.
> 

__`acceptRatio`__ [ numeric ]
> 
> Vector of cumulative acceptance ratios.
> 

__`poster`__ [ poster ]
> 
> Posterior simulator object with its properties updated so to capture the
> final state of the simulation.
> 

__`scale`__ [ numeric ]
> 
> Vector of proposal scale factors in each draw.
> 

__`finalCov`__ [ numeric ]
> 
> Final proposal covariance matrix; the final covariance matrix of the
> random walk step is scale(end)^2*finalCov.
> 

## Options

__`AdaptShape=0.5`__ [ numeric ]
>
> Speed of adaptation of the Cholesky factor of the proposal covariance
> matrix towards the target acceptanace ratio, `TargetAR`; zero means no
> adaptation.

__`AdaptScale=1`__ [ numeric ]
>
> Speed of adaptation of the scale factor to deviations of acceptance
> ratios from the target ratio, `targetAR`.
> 

__`BurnIn=0.10`__ [ numeric ]
> 
> Number of burn-in draws entered either as a percentage of total draws
> (between 0 and 1) or directly as a number (integer greater that one).
> Burn-in draws will be added to the requested number of draws `numDraws`
> and discarded after the posterior simulation.
> 

__`FirstPrefetch=Inf`__ [ numeric | `Inf` ]
> 
> First draw where parallelized pre-fetching will be used; `Inf` means no
> pre-fetching.
> 

__`Gamma=0.8`__ [ numeric ]
> 
> The rate of decay at which the scale and/or the proposal covariance will
> be adapted with each new draw.
> 

__`InitScale=1/3`__ [ numeric ]
> 
> Initial scale factor by which the initial proposal covariance will be
> multiplied; the initial value will be adapted to achieve the target
> acceptance ratio.
> 

__`LastAdapt=Inf`__ [ numeric | `Inf` ]
> 
> Last point at which the proposal covariance will be adapted; `Inf` means
> adaptation will continue until the last draw. Can also be entered as a
> percentage of total draws (a number strictly between 0 and 1).
> 

__`Progress=false`__ [ `true` | `false` ]
> 
> Display a progress bar in the command window.
> 

__`SaveAs=''`__ [ char ]
> 
> File name where results will be saved when the option `SaveEvery=` is
> used.
> 

__`SaveEvery=Inf`__ [ numeric | `Inf` ]
>
> Save every N draws to this HDF5 file, and removed from workspace
> immediately; no values will be returned in the output arguments `theta`,
> `poster`, `acceptRatio`, `scale`; the option `SaveAs=` must be used
> to specify the file name; `Inf` means a normal run with no saving.
> 

__`TargetAR=0.234`__ [ numeric ]
> 
> Target acceptance ratio.
> 


## Description

The function `poster/arwm` returns the simulated chain of parameters and
the corresponding value of the log posterior density. To obtain simulated
sample statistics for each parameter (such as posterior mean, median,
percentiles, etc.) use the function [`poster/stats`](poster/stats) to
process the simulated chain and calculate the statistics.

The properties of the posterior object returned as the 4th output
argument are updated so that they capture the final state of the
posterior simulations. This can be used to initialize a next simulation
at the point where the previous ended.


## Example


