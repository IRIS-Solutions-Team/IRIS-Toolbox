---
title: x13.season
---

{== Interface to X13-Arima seasonal adjustment procedure ==}
 

## Syntax

    [outputSeries, outputSeries, ..., info] = x13.season(inputSeries, ...)
    [outputSeries, outputSeries, ..., info] = x13.season(inputSeries, range, ...)


## Input Arguments

__`inputSeries`__ [ Series ]
> 
> Input time series that will be subjected to a X13-ARIMA seasonal
> adjustment procedure.
> 

__`range=Inf`__ [ Dater ]
> 
> Date range on which the seasonal adjustment will be performed; any
> observations outside the `range` will be clipped off before running
> the procedure; if not specified, all observations available will be
> used.
> 

## Output Arguments

__`outputSeries`__ [ Series ]
> 
> One or more output time series that correspond to the type of output
> requested in the option `Output`.
> 

__`info`__ [ struct ] 
> 
> Information struct with details on the X13-ARIMA procedure run. The
> `info` struct includes the following fields and nested fields:
> 
> * `.InputFiles` - a struct with nested fields named after the extensions
> of the individual input files, with the content of the these input files.
> 
> * `.OutputFiles` - a struct with with nested fields named after the
> extensions of the individual output files produced by the X13-ARIMA
> procedure, with the content of these output files.  The output files
> always included are `.log`, `.out`, and `.err`.  Additional output files
> are included based on the output series (output tables) requested in the
> option `Output`.
> 
> * `.Message` - the screen output of the X13-ARIMA procedure; this output
> is also printed on the screen when the option `Display=true`.
> 
> * `.OutputSpecs` - selected specs based on the information captured from
> some output files; the output specs may include `OutputSpecs.X11_Mode`,
> `OutputSpecs.Arima_Model`, `OutputSpecs.Arima_AR`,
> `OutputSPecs.Arima_MA`.
> 
> * `.Path` - the entire path to the input and output files, including the
> file name wkithout and extension (the same file name with different
> extensions is used for both input and output files); when `Cleanup=true`,
> the input and output files are all deleted automatically.
> 

## General Options

__`Output="d10"`__ [ string ]
> 
> Types of output requested to be returned as time series from the
> X13-ARIMA procedure; see the Output Tables in Description; the number
> of the `outputSeries` arguments corresponds to the number of elements
> in this option.
> 

__`Range=Inf`__ [ Dater ]
> 
> Date range that will be extracted from the `inputSeries` before
> running the X13-ARIMA procedure; the observations outside the range
> will be discarded.
> 

__`Display=false`__ [ `true` | `false` ]
> 
> Print the screen output produced by the X13-ARIMA procedure; the
> message is also captured in the output argument `info.Message`.
> 

__`Cleanup=true`__ [ `true` | `false` ]
> 
> Delete all input and output files automatically.
> 

## X13-ARIMA Options

Below are listed the X13-ARIMA specs that are supported in the current
implemenation; refer to the X13-ARIMA-SEATS manual for details and
explanation. To assign values to the individual specs and their settings,
follow these rules:

* if a numeric scalar or vector is expected, assign the option a numeric
scalar or vector;

* if a "yes" or "no" value is expected, assign a `true` or `false`;

* if a text value or a list of more than onetext values is expected (such
as `log` in `Transform_Function`, or `td lpyear` in
`Regression_Variables`), enter a single double-quoted string, or an array
of strings (such as `"log"` or `["td", "lpyear"]`);

* if time series data are expected (such as in `Regression_Data`), enter
a time series object;

* if a fixed numeric value is expected (such as fixed coefficients in
`Arima_AR`, as opposed to initial values in the same spec), enter an
imaginary value (such as `0.8i`); imaginary values will be printed with
an extra `F` in the input files (such as `0.8F`);


### Series Spec

* `Series_Title`
* `Series_Span`
* `Series_ModelSpan`
* `Series_Precision`
* `Series_Decimals`
* `Series_CompType`
* `Series_CompWeight`
* `Series_AppendBcst`
* `Series_AppendFcst`
* `Series_Type`
* `Series_Save`

### X11 Spec 

* `X11_SeasonalMA`
* `X11_TrendMA`
* `X11_SigmaLim`
* `X11_Title`
* `X11_AppendFcst`
* `X11_AppendBcst`
* `X11_Final`
* `X11_Print`
* `X11_Save`
* `X11_SaveLog`

### Transform Spec

* `Transform_Function`
* `Transform_Power`
* `Transform_Adjust`
* `Transform_Title`
* `Transform_AicDiff`
* `Transform_Print`
* `Transform_Save`
* `Transform_SaveLog`

### Estimate Spec

* `Estimate_Tol`
* `Estimate_MaxIter`
* `Estimate_Exact`
* `Estimate_OutOfSample`
* `Estimate_Print`
* `Estimate_Save`
* `Estimate_SaveLog`

### Automdl Spec

* `Automdl_MaxOrder`
* `Automdl_MaxDiff`
* `Automdl_Diff`
* `Automdl_AcceptDefault`
* `Automdl_CheckMu`
* `Automdl_LjungBoxLimit`
* `Automdl_Mixed`
* `Automdl_Print`
* `Automdl_SaveLog`


### Pickmdl Spec

* `Pickmdl_Method`
* `Pickmdl_Mode`
* `Pickmdl_Print`
* `Pickmdl_SaveLog`


### Arima Spec 

* `Arima_Model`
* `Arima_AR`
* `Arima_MA`
* `Arima_Title`

### Force Spec

* `Force_Type`
* `Force_Lambda`
* `Force_Rho`
* `Force_Round`
* `Force_Start`
* `Force_Target`
* `Force_UseFcst`
* `Force_Print`
* `Force_Save`

### Forecast Spec

* `Forecast_MaxLead`
* `Forecast_MaxBack`
* `Forecast_Exclude`
* `Forecast_LogNormal`
* `Forecast_Print`
* `Forecast_Save`

### Regression Spec

* `Regression_Variables`
* `Regression_TestAllEaster`
* `Regression_Data`
* `Regression_User`
* `Regression_UserType`
* `Regression_AicTest`
* `Regression_AicDiff`
* `Regression_PVAicTest`
* `Regression_TLimit`
* `Regression_Chi2Test`
* `Regression_Chi2TestCV`
* `Regression_Print`
* `Regression_Save`
* `Regression_SaveLog`

### X11Regression Spec 

* `X11Regression_Variables`
* `X11Regression_Data`
* `X11Regression_User`
* `X11Regression_UserType`
* `X11Regression_AicTest`
* `X11Regression_AicDiff`
* `X11Regression_TDPrior`
* `X11Regression_Prior`
* `X11Regression_Span`
* `X11Regression_Sigma`
* `X11Regression_Critical`
* `X11Regression_OutlierMethod`
* `X11Regression_OutlierSpan`
* `X11Regression_Print`
* `X11Regression_Save`
* `X11Regression_SaveLog`

### Seats Spec 

* `Seats_AppendFcst`
* `Seats_HpCycle`
* `Seats_NoAdmiss`
* `Seats_QMax`
* `Seats_RMod`
* `Seats_Out`
* `Seats_StatSeas`
* `Seats_TabTables`
* `Seats_PrintPhtrf`
* `Seats_Print`
* `Seats_Save`
* `Seats_SaveLog`


## Description

### Bulding the Input File

With no options specified, all specs (see their list above) are empty,
meaning they are not included in the input file at all and the X13-ARIMA
default values (see the X13-ARIMA-SEATS manual) are assumed, with the
following exceptions:

* `Series_Start`, `Series_Data` and `Series_Period` are automatically
created based on the `inputSeries`;

* `Series_Precision` and `Series_Decimals` are both set to `5` (the
maximum precision accepted by the X13-ARIMA procedure);

* Either an `X11` spec or a pair of `Seat` and `Automdl` specs are
included to force the execution of the `X11` type of seasonal adjustment
(if `d..` types of output tables are requested in `Output`) or the
execution of the `SEAT` type of seasonal adjustment (if `x..` types of
output tables are requested in `Output`).


If no setting within a particular spec is not defined in the options, the
spec itself is not included in the input file. To force the inclusion of
an empty spec in the input file (assuming thus the default values for all
the settings within that spece), use the name of the spec as an option
and set it to `true`, e.g. `(..., "Automdl", true, ...)` to force the
estimation of an ARIMA model based on an automatic model selection
procedure.

If at least one setting from a particular spec is specified as an option
in the fuction call, that spec is included explicitly in the input file.


### Type of Seasonal Adjustment 

Two types of seasonal adjustments are available in X13-ARIMA: `X11` and
`SEATS`. Which one is invoked depends on the type of output requested in
the option `Output`: the output tables starting with a `d` refer to `X11`
(hence, the default `Output="d11"` invokes `X11` and returns the final
seasonally adjusted series) whereas the output tables starting with an
`s` refer to `SEATS`.

Depending on the output tables requested, the correct spec for the
respective seasonal adjustment procedure will be included in the input
file and invoked.

The two procedures cannot be combined together in one run; i.e. the
option `Output` cannot combine `d..` and `s..` output tables.


### Output Tables (Output Series)

The following output tables (i.e. output series) can be requested in the option `Output`:

| Name in option `Output`  | Output table in X13 | Description                                                            |
|--------------------------|---------------------|------------------------------------------------------------------------|
| `"d10"`                  | `X11_d10`           | `X11` final seasonal factors                                           |
| `"d11"`                  | `X11_d11`           | `X11` final seasonally adjusted series                                 |
| `"d12"`                  | `X11_d12`           | `X11` final trend-cycle                                                |
| `"d13"`                  | `X11_d13`           | `X11` final irregular component                                        |
| `"d16"`                  | `X11_d16`           | `X11` final combined seasonal and trading day factors                  |
| `"d18"`                  | `X11_d18`           | `X11` combined holiday and trading day factors                         |
| `"s10"`                  | `Seats_s10`         | `SEATS` final seasonal component                                       |
| `"s11"`                  | `Seats_s11`         | `SEATS` final seasonal adjustment component                            |
| `"s12"`                  | `Seats_s12`         | `SEATS` final trend component                                          |
| `"s13"`                  | `Seats_s13`         | `SEATS` final irregular component                                      |
| `"s14"`                  | `Seats_s14`         | `SEATS` final transitory component                                     |
| `"s16"`                  | `Seats_s16`         | `SEATS` final combined adjustment component                            |
| `"s18"`                  | `Seats_s18`         | `SEATS` final adjustment ratio                                         |
| `"cyc"`                  | `Seats_cyc`         | `SEATS` cycle component                                                |
| `"a18"`                  | `Series_a18`        | Original series adjusted for regARIMA calendar effects                 |
| `"a19"`                  | `Series_a19`        | Original series adjusted for regARIMA outliers                         |
| `"b1"`                   | `Series_b1`         | Original series, adjusted for prior effects and forecast extended      |
| `"mva"`                  | `Series_mva`        | Original series with missing values replaced by regARIMA estimates     |
| `"saa"`                  | `Force_saa`         | Final seasonally adjusted series with constrained yearly totals        |
| `"rnd"`                  | `Force_rnd`         | Rounded final seasonally adjusted series                               |
| `"fct"`                  | `Forecast_fct`      | Point forecasts on the original scale                                  |
| `"bct"`                  | `Forecast_bct`      | Point backcasts on the original scale                                  |
| `"ftr"`                  | `Forecast_ftr`      | Point forecasts on the transformed scale                              |
| `"btr"`                  | `Forecast_btr`      | Point backcasts on the transformed scale                              |


## Example

A plain vanilla call

```matlab
xsa = x13.season(x)
```

or

```matlab
[xsa, info] = x13.season(x)
```

produces a seasonally adjusted series `xsa` with all default settings
(hence no ARIMA model estimated).


## Example

Estimate an ARIMA model based on an automatic model selection
procedures, use the ARIMA information in the seasonal
adjustment, and return the estimated ARIMA model in the output `info`
struct:

```
[xsa, info] = x13.season(x, "Automdl", true, "Estimate_Save", "mdl")
```


## Example

Request additional output series: the seasonally adjusted series, the
seasonal factors and the trend cycle component:

```matlab
[xsa, xsf, xtc, info] = x13.season(x, "Output", ["d11", "d10", "d12"]);
```


## Example

Run seasonal adjustment based on an automatically selected ARIMA model
with dummy variables of additive outliers in period 2017Q3, 2017Q4 and
2018Q1:

```matlab
xsa = x13.season(x ...
    , "Automdl", true ...
    , "Regression_Variables", "aos2017.3-2018.1" ...
);
```

This call is equivalent to creating the dummies manually (a time series
object with three columns), and using the option `Regression_Data`
instead:

```matlab
dummy = Series(startDate:endDate, zeros(1, 3));
dummy(qq(2017,3), 1) = 1;
dummy(qq(2017,4), 2) = 1;
dummy(qq(2018,1), 3) = 1;

xsa = x13.season(x ...
    , "Automdl", true ...
    , "Regression_Data", dummy ...
);
```

