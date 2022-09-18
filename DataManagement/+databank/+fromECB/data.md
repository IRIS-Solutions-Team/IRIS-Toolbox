---
title: databank.fromECB.data
---

# `databank.fromECB.data`

{== Download databank of time series from ECB Statistical Data Warehouse ==}


## Syntax

    [db, info] = databank.fromECB.data(dataset, skeys, ___)


## TL;DR

    [db, info] = databank.fromECB.data("EXR", "M.USD.EUR.SP00.A")

    [db, info] = databank.fromECB.data("EXR", "M.CHF+USD.EUR.SP00.A")

    [db, info] = databank.fromECB.data("EXR", {"M", ["CHF", USD"], "EUR.SP00.A"})


## Input arguments

__`dataset`__ [ string ]
> 
> Dataset identifier (usualy a three-letter string); only one dataset is
> allowed in one request.
> 


__`skeys`__ [ string | cell ]
> 
> Series key or keys specified one of the following ways:
> 
> * A single string with requested dimensions separated by periods, `.`; connect
>   more than one value in a dimension using a plus sign, `+`.
> 
> * A cell array of strings or string arrays; the cells will be joined by a
>   period, `.`; if a cell contains a string array, the individual array
>   elements will be joind by a plus sign, `+`.
> 


## Output arguments

__`outputDb`__ [ struct | Dictionay ]
> 
> Output databank with the requested series.
> 

__`info`__ [ struct ]
> 
> Output information struct with the following fields:
> 
> * `.Request` - a string with the entire URL request
> 
> * `.Response` - a JSON struct with the ECB SDW response
> 


## Options

__`AddToDatabank=[]`__ [ struct | Dictionary | empty ]
> 
> The new time series will be added to this databank.
> 

__`Attributes=true`__ [ `true` | `false` ]
> 
> Read also the attributes for each time series and populated the time
> series comments and user data; if `Attributes=false`, the attributes are
> not requested, and the output time series do not have their comments and
> user data populated from them.
> 

__`OutputType="struct"` [ `"struct"`  | `"Dictionary"` ]
> 
> Type of the output databank (struct or Dictionary).
> 

__`DimensionSeparator="_"`__ [ string ]
> 
> String that will be used to separate the individual dimensions in the
> names of the series (the dimensions are separated with periods, `.`, in
> the URL request, which cannot be part of struct fields in Matlab).
> 

__`CommentFrom="TITLE"`__ [ string ]
> 
> Name of the ECB SDW attribute on which each time series comment will be
> based.
> 


## Description

See the
[ECB SDW API manual](https://sdw-wsrest.ecb.europa.eu/help/#tabData)
for details on how to look up and specify the datasets and time series
dimensions.

Visit the 
[ECB SDW web interface](https://sdw.ecb.europa.eu)
to browse the time series.


## Examples

Download a monthly time series for the USD/EUR exchange rate 

```matlab
[db, info] = databank.fromECB.data("EXR", "M.USD.EUR.SP00.A")
```

Download a monthly and a yearly (annual) time series for the USD/EUR exchange rate;
note the multiple dimension request `A+M`

```matlab
[db, info] = databank.fromECB.data("EXR", "A+M.USD.EUR.SP00.A")
```

The previous data request is equivalent to 

```matlab
[db, info] = databank.fromECB.data("EXR", {["A", "M"], "USD.EUR.SP00.A"})
```


Download monthly and yearly (annual) time series for multiple exchange
rates: USD, CHF, JPY; the following two requests are eqivalent

```matlab
[db, info] = databank.fromECB.data("EXR", "A+M.USD+CHF+JPY.EUR.SP00.A")
[db, info] = databank.fromECB.data("EXR", {["A", "M"], ["USD", "CHF", "JPY"], "EUR.SP00.A"})
```

