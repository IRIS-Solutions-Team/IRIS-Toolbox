# Overview of Series objects

Series objects are two- or higher-dimensional arrays whose rows are
referenced by dates. The arrays can be one of the following types:

* numeric arrays
* string arrays
* cell arrays


## Categorical list of functions

### Constructing time series objects

Function | Description
---|---
[`Series`](Series.md)                                        | Create new time series object
[`Series.linearTrend`](linearTrend.md)                       | Create time series with linear trend
[`Series.empty`](empty.md)                                   | Create empty time series or empty existing time series
[`Series.seasonDummy`](seasonDummy.md)                       | Create time series with seasonal dummies
[`Series.randomlyGrowing`](randomlyGrowing.md)               | Create randomly growing time series


### Generating new time series
[`Series.grow`](grow.md)                                     | Cumulate level time series from differences or rates of growth


#### Converting and modifying time series

Function | Description
---|---
[`convert`](convert.md)                                      | Convert time series to another frequency
[`rebase`](rebase.md)                                        | Rebase times series data to specified period
[`fillMissing`](fillMissing.md)                              | Fill missing time series observations


#### Filtering and aggregating time series

Function | Description 
---|---
[`arf`](arf.md)                                              | Create autoregressive time series from input data
[`hpf`](hpf.md)                                              | Hodrick-Prescott filter with conditioning information
[`moving`](moving.md)                                        | Apply function to moving window of time series observations
[`chainlink`](chainlink.md)                                  | Calculate chain linked aggregate level series from level components and weights


#### Regression and statistics

Function | Description 
---|---
[`rmse`](rmse.md)                                            | Calculate RMSE for given observations and predictions
[`regress`](regress.md)                                      | Ordinary or weighted least-square regression

