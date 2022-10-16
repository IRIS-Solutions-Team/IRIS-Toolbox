---
populate: true
topic: Series
---

# Overview of time series (Series) objects

{==
Time series objects are two- or higher-dimensional arrays whose rows are
referenced by dates. 
==}

The arrays can be one of the following types:

* numeric arrays
* string arrays
* cell arrays

Most of the time series methods are specifically designed for numeric time series,
and do not, naturally, work for string time series or cell time series.


## Categorical list of functions

### Constructing time series objects

Function | Description
---|---
[`Series.fromData`](fromData.md) | Create a new time series from a data array
[`Series.linearTrend`](linearTrend.md) | Create time series with linear trend
[`Series.empty`](empty.md) | Create empty time series or empty existing time series
[`Series.seasonDummy`](seasonDummy.md) | Create time series with seasonal dummies
[`Series.randomlyGrowing`](randomlyGrowing.md) | Create randomly growing time series


### Generating new time series from existing time series

Function | Description
---|---
[`Series.grow`](grow.md) | Cumulate level time series from differences or rates of growth


#### Manipulating the time dimension

Function | Description
---|---
[`clip`](clip.md) | Clip time series to a shorter range
[`rebase`](rebase.md) | Rebase times series data to specified period


#### Filtering, interpolating and aggregating time series

Function | Description 
---|---
[`arf`](arf.md) | Create autoregressive time series from input data
[`convert`](convert.md) | Convert time series to another frequency
[`fillMissing`](fillMissing.md) | Fill missing time series observations
[`hpf`](hpf.md) | Hodrick-Prescott filter with conditioning information
[`moving`](moving.md) | Apply function to moving window of time series observations
[`chainlink`](chainlink.md) | Calculate chain linked aggregate level series from level components and weights


#### Statistics and regression

The following standard Matlab functions work on time series objects:

Function | Default dimension | Default output
:---|:---:|:---
`mean` | 1 | array
`median` | 1  | array
`mode` | 1 | array
`geomean` | 1 | array
`sum` | 1 | array
`prod` | 1 | array
`std` | 1 | array
`var` | 1 | array
`cov` | 1 | array
`prctile` | 2 | Series

Function | Description 
---|---
[`rmse`](rmse.md) | Calculate RMSE for given observations and predictions
[`regress`](regress.md) | Ordinary or weighted least-square regression


#### Visualizing time series data

Function | Description 
---|---
[`ascii`](ascii.md) | Visualize one column of a time series as an ASCII chart
[`plot`](plot.md) | Line chart for time series objects


