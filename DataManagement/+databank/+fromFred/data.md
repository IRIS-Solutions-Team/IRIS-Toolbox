---
title: databank.fromFred.data
---

# `databank.fromFred.data`

{== Download time series from Fred, the St Louis Fed databank ==}


## Syntax

    [outputDb, status] = databank.fromFred.data(seriesId, ___)


## TL;DR

    db = databank.fromFred.data(["GDPC1", "PCE"]);

    db = databank.fromFred.data(["GDPC1", "PCE"], frequency=Frequency.QUARTERLY);

    db = databank.fromFred.data(["GDPC1->gdp", "PCE->pc"]);

    db = databank.fromFred.data( ...
        "GDPC1", vintage=["2001-09-11", "2019-12-30", "2019-12-31"] ...
    );

    v = databank.fromFred.data(["GDPC1", "TB3MS"], "Request", "VintageDates");


## Input Arguments

__`seriesId`__ [ string ]
> 
> List of Fred series Ids to retrieve, or `"Id->Name"` mappings
> specifying a `Name` different from `Id` under which the series will
> be saved in the databank.
> 

## Output arguments

__`outputDb`__ [ struct ]
> 
> Output databank with requested time series.
> 

__`status`__ [ `true` | `false` ]
> 
> True if all requested time series have been sucessfully downloaded.
> 

## Options

__`AddToDatabank=[]`__ [ struct | empty ]  
> 
> Requested time series will be added to this existing databank; if
> empty, a new databank of the `OutputType=` class will be created; the
> type of `AddToDatabank=` option must be consistent with the
> `OutputType=`.
> 

__`AggregationMethod="avg"`__ [ `"avg"` | `"sum"` | `"eop"` ]
> 
> Aggregation (frequency conversion) method applied when option
> `'Frequency='` is used.
> 

__`Frequency=[]`__ [ empty | Frequency ]
> 
> Request time series conversion to the specified frequency; frequency
> conversion will be performed server-side; only high- to low-frequency
> conversion is possible (aggregation).
> 

__`Request="Observations"`__ [ `"Observations"` | `"Vintages"` ]
> 
> Kind of information requested from Fred: `Observations` means the
> actual observations arranged in a time series databank; `Vintages`
> means vintage dates currently available for each series specified.
> 

__`MaxRequestAttempts=3`__ [ numeric ]
> 
> Maximum number of attempts to run each HTTPS request.
> 

__`OutputType='struct'`__ [ `struct` | `Dictionary` ]
> 
> Type (Matlab class) of the output databank; the type of
> `AddToDatabank=` option must be consistent with the `OutputType=`.
> 

__`Progress=false`__ [ `true` | `false` ]
> 
> Show command line progress bar.
> 

__`URL="https://api.stlouisfed.org/fred/series"`__ [ string ]
> 
> URL for the Fred(R) API.
> 

__`Vintage=[ ]`__ [ string | "*" | Dater ]
> 
> List of vintage dates (strings in ISO format, "YYYY-MM-DD") for which
> the time series will be requested; the resulting time series will
> have as many columns as the number of vintages actually returned;
> with the column comments starting with the vintage date string. 
> 
> Requesting "*" means all vintages currently available will be first
> obtained for each series, and then observations for all these
> vintages will be requested requested; the list of vintages is
> then returned in each series as a user data field named
> "Vintages".
> 

## Description



## Examples of basic use cases

Run a plain vanilla command to retrieve one quarterly (`GDPC1`) and one
monthly series (`PCE`):

    db = databank.fromFred(["GDPC1", "PCE"])


Do the same, but convert the non-quarterly series to quarterly frequency
server side. Obviously, it can alternatively also be done ex-post in
Iris:

    db = databank.fromFred(["GDPC1", "PCE"], "Frequency=", Frequency.QUARTERLY)


Retrieve the same series but rename them in the output database:

    db = databank.fromFred(["GDPC1->gdp", "PCE->pc"])



## Examples of user specified vintages

Specify the vintage dates for which you wish to retrieve the series. The
vintage dates can be any date (formatted as ISO strings); if some do not
coincide with the vintages actually available, the observations will
simply be returned as they existed at those particular dates:

    db = databank.fromFred( ...
        "GDPC1", Vintage=["2001-09-11", "2019-12-30", "2019-12-31"] ...
    );


The latter two vintage dates produce exactly the same time series as there was
no update of GDP data between December 30 and Decemeber 31, 2019;
compare the two columns:

    disp(db.GDPC1)


## Example of all-vintage use case

First, run a request for the list of vintages currently available for one
quarterly series (`GDPC1`) and one monthly series (`TB3MS`):

    vin = databank.fromFred(["GDPC1", "TB3MS"], "Request=", "VintageDates");
    disp(vin) 
    disp(vin.GDPC1)


The `vin` databank contains a list of the vintages available for each of
the requested series. Now, retrieve the last five vintages for each
series:

    db = struct( );

    db = databank.fromFred( ...
        "GDPC1", ...
        "Vintage=", vin.GDPC1(end-4:end), ...
        "AddToDatabank=", db ...
    );

    db = databank.fromFred( ...
        "TB3MS", ...
        "Vintage=", vin.TB3MS(end-4:end), ...
        "AddToDatabank=", db ...
    );

    disp(db)


