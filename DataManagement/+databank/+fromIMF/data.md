---
title: databank.fromIMF.data
---

# `databank.fromIMF.data`

{== Download databank of time series from IMF Data Portal ==}


## Syntax for plain vanilla requests (most datasets)

    [outputDb, info] = databank.fromIMF.data(dataset, frequency, areas, indicators, ...)


## Syntax for requests that need more dimensions

    [outputDb, info] = databank.fromIMF.data(dataset, frequency, areas, dimensions, ...)


## Input Arguments

__`dataset`__ [ string ]
> 
> IMF dataset ID; only one dataset is allowed in one data request.
> 

__`frequency`__ [ Frequency ]
> 
> Date frequency for the output time series; the `frequency` must be
> yearly, quarterly or monthly; only one frequency is allowed in one data
> request.
> 

__`areas`__ [ string ]
> 
> List of reference areas for which the output time series will be
> retrieved; an empty string or emtpy array means all reference areas.
> 

__`indicators`__ [ string ]
> 
> List of indicators that will be retrieved for each of the `areas`.
> 

__`dimensions`__ [ cell ]
> 
> Cell array of string arrays; each element of the cell array stands for one
> particular dimension that needs to be specified in the request (depending
> on the dataset).
> 

__`counter=empty`__ [ string ]
> 
> List of counterparty reference areas for which the output time series
> will be retrieved; counterparty reference areas are needed for only some
> of the IMF databanks, such as Directions of Trade Statistics (DOT); an
> empty string or empty array means all counterparty reference areas.
> 

## Output arguments

__`outputDb`__ [ struct | Dictionary ]
> 
> Output databank with time series retrieved from an IMF databank.
> 

__`info`__ [ struct ]
> 
> Output information struct with the following fields:
> 
> * `.Request` - the entire request string (including the URL)
> 
> * `.Response` - a JSON struct with the IMF data portal response
> 

## Options for HTTP Request


__`EndDate=-Inf`__ [ Dater ]
> 
> End date for the data requested; `-Inf` means the date of the latest
> observation for each series.
> 

__`StartDate=-Inf`__ [ Dater ]
> 
> Start date for the data requested; `-Inf` means the date of the earliest
> observation for each series.
> 

__`URL="http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/"`__ [ string ]
> 
> URL for the IMF data portal HTTP request.
> 

__`WebOptions=weboptions("Timeout", 9999)`__ [ weboption ]
> 
> A weboptions object with HTTP settings.
> 

__`WhenEmpty="warning"`__ [ `"error"` | `"warning"` ]
> 
> How to report an empty response from the server:
> 
> * `"error"` means an error is thrown and the execution of the function
>   stops;
> 
> * `"warning"` means a warning is thrown and an empty databank is return
>   without interrupting the execution of the function.
> 

## Options for output databank

__`AddToDatabank=struct()`__ [ struct | Dictionary ]
> 
> Add the output time series to this databank.
> 

__`ApplyMultiplier=true`__ [ `true` | `false` ]
> 
> Apply the unit multiplier to the output time series data, scaling them to
> basic units (e.g. from millions).
> 

## Options for output time series names

__`NameFunc=[]`__ [ empty | function_handle ]
> 
> Function that will be applied to each time series name before it is
> stored in the `outputDb`.
> 

__`IncludeArea=true`__ [ `true` | `false` ]
> 
> Include the respective reference area code as a prefix in the name of
> each output time series.
> 

__`IncludeCounter=true`__ [ `true` | `false` ]
> 
> Three-dimensional requests only (with counterparty reference area):
> Include the respective counterparty reference area code as a suffix in
> the name of each output time series.
> 

__`Separator="_"`__ [ string ]
> 
> Separator used in the area prefix and/or the counterparty area suffix in
> the output time series names.
> 

## Description

This function returns a databank of time series from the IMF data portal.
To create a data request, you need to know the IMF dataset code, the
reference area code(s), the indicator code(s), and for three-dimensional
requests, also the counterparty reference area code(s).

Leaving the reference area code, the indicator code or the counterparty
reference area code empty will return data for all of those that exist in
that dimension.

The IMF data portal has bandwith restrictions. Sometimes, requests
returning larger amounts of data need to be split into smaller, more
specific requests. Sometimes, the function needs to be called several times
before an actual data response is returned.


## Examples

### Plain vanilla three-dimensional requests

Most of the IMF datasets need three dimensions to be specified: 

* date frequency (only one single date frequency can be specified)
* reference area(s)
* indicator(s)

From the IMF IFS dataset, retrieve quarterly nominal GDP in localy currency
for the US:

```matlab
d = databank.fromIMF.data("IFS", Frequency.QUARTERLY, "US", "NGDP_XDC")
```

Retrieve nominal GDP in localy currency for all areas (countries and
regions) for which this indicator is available:

```matlab
d = databank.fromIMF.data("IFS", Frequency.QUARTERLY, [], "NGDP_XDC")
```


Retrieve all indicators available from the IMF IFS databank for the US; do
not include the country prefix (here, "US_") in the names of the output
time series:

```matlab
d = databank.fromIMF.data("IFS", Frequency.QUARTERLY, "US", [], "includeArea", false)
```

### Multi-dimensional requests

Some IMF datasets require some extra dimensions; for instance, the IMF
Directions of Trade Statistics dataset (code `DOT`) needs an extra
dimension for the counterparty following after the indicator dimension; the
IMF Government Finance Statistics - Main Aggregates and Balances dataset
(code `GFSMAB`) needs a government sector dimension and a unit of
measurement dimension, both preceding the indicator dimension.

Retrieve yearly exports from US (code `US`) to Euro Area (code `U2`):

```matlab
d = databank.fromIMF.data("DOT", Frequency.YEARLY, "US", {"TXG_FOB_USD", "U2"});
```

From the IMF DOT databank (Directions of Trade Statistics), retrieve
yearly exports from US to all reported areas:

```matlab
d = databank.fromIMF.data("DOT", Frequency.YEARLY, "US", "TXG_FOB_USD", []);
```

