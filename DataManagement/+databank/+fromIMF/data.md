# `databank.fromIMF.data`

{== Download databank of time series from IMF Data Portal ==}


# Syntax for Two-Dimensional Requests

    [outputDb, info] = databank.fromIMF.data(datasetId, frequency, areas, items, ...)


# Syntax for Three-Dimensional Requests

    outputDb = databank.fromIMF.data(datasetId, frequency, areas, items, counters, ...)

# Input Arguments

__`databankId`__ [ string ]
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

__`items`__ [ string ]
>
> List of indicators that will be retrieved for each of the `areas`.
>

__`counter=empty`__ [ string ]
>
> List of counterparty reference areas for which the output time series
> will be retrieved; counterparty reference areas are needed for only some
> of the IMF databanks, such as Directions of Trade Statistics (DOT); an
> empty string or empty array means all counterparty reference areas.
>

# Output Arguments

__`outputDb`__ [ struct | Dictionary ]
>
> Output databank with time series retrieved from an IMF databank.
>

__`info`__ [ struct ]
>
> Output information struct with the following fields:
>
> * `.Request` - the entire request string (including the URL)
> * `.Response` - a JSON struct with the IMF data portal response


# Options for HTTP Request


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

# Options for Output Databank

__`AddToDatabank=struct()`__ [ struct | Dictionary ]
>
> Add the output time series to this databank.
>

__`ApplyMultiplier=true`__ [ `true` | `false` ]
>
> Apply the unit multiplier to the output time series data, scaling them to
> basic units (e.g. from millions).
>

# Options for Output Time Series Names

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

# Description

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


# Examples

## Two-Dimensional Requests

Most of the IMF data requests need two dimensions to be specified: the
reference area and the indicator (the concept). 

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

## Three-Dimensional Requests

From the IMF DOT databank (Directions of Trade Statistics), retrieve
yearly exports from US to Euro Area (code "U2"):

```matlab
d = databank.fromIMF.data("DOT", Frequency.YEARLY, "US", "TXG_FOB_USD", "U2");
```

From the IMF DOT databank (Directions of Trade Statistics), retrieve
yearly exports from US to all reported areas:

```matlab
d = databank.fromIMF.data("DOT", Frequency.YEARLY, "US", "TXG_FOB_USD", []);
```

