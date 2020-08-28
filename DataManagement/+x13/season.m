% x13.season  Interface to X13-Arima seasonal adjustment procedure
%{ 
% Syntax
%--------------------------------------------------------------------------
%
%     [outputSeries, outputSeries, ..., info] = x13.season(inputSeries, ...)
%
%>    Optional input arguments are entered as name-value pairs (with the
%>    names being strings enclosed in single or double quotes and no equal
%>    sign allowed), with the option names case-insensitive and with
%>    partial match enabled (i.e.  only the beginning of an option name
%>    sufficient to uniquelly identify the option name needs to be typed).
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`inputSeries`__ [ Series ]
%
%>    Input time series that will be subjected to a X13-ARIMA seasonal
%>    adjustment procedure.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`outputSeries`__ [ Series ]
%
%>    One or more output time series that correspond to the type of output
%>    requested in the option `Output`.
%
%
% __`info`__ [ struct ] 
%
%>    Information struct with details on the X13-ARIMA procedure run. The
%>    `info` struct includes the following fields and nested fields:
%>
%>    * `InputFiles` - a struct with nested fields named after the
%>    extensions of the individual input files, with the content of the
%>    these input files.
%>
%>    * `OutputFiles` - a struct with with nested fields named after the
%>    extensions of the individual output files produced by the X13-ARIMA
%>    procedure, with the content of these output files.  The output files
%>    always included are `.log`, `.out`, and `.err`.  Additional output
%>    files are included based on the output series (output tables)
%>    requested in the option `Output`.
%>
%>    * `Message` - the screen output of the X13-ARIMA procedure; this
%>    output is also printed on the screen when the option `Display=true`.
%>
%>    * `OutputSpecs` - selected specs based on the information captured
%>    from some output files; the output specs may include
%>    `OutputSpecs.X11_Mode`, `OutputSpecs.Arima_Model`,
%>    `OutputSpecs.Arima_AR`, `OutputSPecs.Arima_MA`.
%>
%>    * `Path` - the entire path to the input and output files, including
%>    the file name wkithout and extension (the same file name with
%>    different extensions is used for both input and output files); when
%>    `Cleanup=true`, the input and output files are all deleted
%>    automatically.
%
%
% General Options
%--------------------------------------------------------------------------
%
% __`Output="d10"`__ [ string ]
%
%>    Types of output requested to be returned as time series from the
%>    X13-ARIMA procedure; see the Output Tables in Description; the number
%>    of the `outputSeries` arguments corresponds to the number of elements
%>    in this option.
%
%
% __`Range=Inf`__ [ Dater ]
%
%>    Date range that will be extracted from the `inputSeries` before
%>    running the X13-ARIMA procedure; the observations outside the range
%>    will be discarded.
%
%
% __`Display=false`__ [ `true` | `false` ]
%
%>    Print the screen output produced by the X13-ARIMA procedure; the
%>    message is also captured in the output argument `info.Message`.
%
%
% __`Cleanup=true`__ [ `true` | `false` ]
%
%>    Delete all input and output files automatically.
%
%
% X13-ARIMA Options
%--------------------------------------------------------------------------
%
% Below are listed the X13-ARIMA specs that are supported in the current
% implemenation; refer to the X13-ARIMA-SEATS manual for details and
% explanation. To assign values to the individual specs and their settings,
% follow these rules:
%
% * if a numeric scalar or vector is expected, assign the option a numeric
% scalar or vector;
%
% * if a "yes" or "no" value is expected, assign a `true` or `false`;
%
% * if a text value or a list of more than onetext values is expected (such
% as `log` in `Transform_Function`, or `td lpyear` in
% `Regression_Variables`), enter a single double-quoted string, or an array
% of strings (such as `"log"` or `["td", "lpyear"]`);
%
% * if time series data are expected (such as in `Regression_Data`), enter
% a time series object;
%
% * if a fixed numeric value is expected (such as fixed coefficients in
% `Arima_AR`, as opposed to initial values in the same spec), enter an
% imaginary value (such as `0.8i`); imaginary values will be printed with
% an extra `F` in the input files (such as `0.8F`);
%
%
% ### Series Spec ###
%
% * `Series_Title`
% * `Series_Span`
% * `Series_ModelSpan`
% * `Series_Precision`
% * `Series_Decimals`
% * `Series_CompType`
% * `Series_CompWeight`
% * `Series_AppendBcst`
% * `Series_AppendFcst`
% * `Series_Type`
% * `Series_Save`
%
% ### X11 Spec ###
%
% * `X11_SeasonalMA`
% * `X11_TrendMA`
% * `X11_SigmaLim`
% * `X11_Title`
% * `X11_AppendFcst`
% * `X11_AppendBcst`
% * `X11_Final`
% * `X11_Print`
% * `X11_Save`
% * `X11_SaveLog`
%
% ### Transform Spec ###
%
% * `Transform_Function`
% * `Transform_Power`
% * `Transform_Adjust`
% * `Transform_Title`
% * `Transform_AicDiff`
% * `Transform_Print`
% * `Transform_Save`
% * `Transform_SaveLog`
%
% ### Estiamate Spec ###

% * `Estimate_Tol`
% * `Estimate_MaxIter`
% * `Estimate_Exact`
% * `Estimate_OutOfSample`
% * `Estimate_Print`
% * `Estimate_Save`
% * `Estimate_SaveLog`
%
% ### Automdl Spec ###
%
% * `Automdl_MaxOrder`
% * `Automdl_MaxDiff`
% * `Automdl_Diff`
% * `Automdl_AcceptDefault`
% * `Automdl_CheckMu`
% * `Automdl_LjungBoxLimit`
% * `Automdl_Mixed`
% * `Automdl_Print`
% * `Automdl_SaveLog`
%
% ### Arima Spec ###
%
% * `Arima_Model`
% * `Arima_AR`
% * `Arima_MA`
% * `Arima_Title`
%
% ### Force Spec ###
%
% * `Force_Type`
% * `Force_Lambda`
% * `Force_Rho`
% * `Force_Round`
% * `Force_Start`
% * `Force_Target`
% * `Force_UseFcst`
% * `Force_Print`
% * `Force_Save`
%
% ### Forecast Spec ###
%
% * `Forecast_MaxLead`
% * `Forecast_MaxBack`
% * `Forecast_Exclude`
% * `Forecast_LogNormal`
% * `Forecast_Print`
% * `Forecast_Save`
%
% ### Regression Spec ###
%
% * `Regression_Variables`
% * `Regression_TestAllEaster`
% * `Regression_Data`
% * `Regression_User`
% * `Regression_UserType`
% * `Regression_AicTest`
% * `Regression_AicDiff`
% * `Regression_PVAicTest`
% * `Regression_TLimit`
% * `Regression_Chi2Test`
% * `Regression_Chi2TestCV`
% * `Regression_Print`
% * `Regression_Save`
% * `Regression_SaveLog`
%
% ### X11Regression Spec ###
%
% * `X11Regression_Variables`
% * `X11Regression_Data`
% * `X11Regression_User`
% * `X11Regression_UserType`
% * `X11Regression_AicTest`
% * `X11Regression_AicDiff`
% * `X11Regression_TDPrior`
% * `X11Regression_Prior`
% * `X11Regression_Span`
% * `X11Regression_Sigma`
% * `X11Regression_Critical`
% * `X11Regression_OutlierMethod`
% * `X11Regression_OutlierSpan`
% * `X11Regression_Print`
% * `X11Regression_Save`
% * `X11Regression_SaveLog`
%
% ### Seats Spec ###
%
% * `Seats_AppendFcst`
% * `Seats_HpCycle`
% * `Seats_NoAdmiss`
% * `Seats_QMax`
% * `Seats_RMod`
% * `Seats_Out`
% * `Seats_StatSeas`
% * `Seats_TabTables`
% * `Seats_PrintPhtrf`
% * `Seats_Print`
% * `Seats_Save`
% * `Seats_SaveLog`
%
%
% Description
%--------------------------------------------------------------------------
%
% ### Bulding the Input File ###
%
% With no options specified, all specs (see their list above) are empty,
% meaning they are not included in the input file at all and the X13-ARIMA
% default values (see the X13-ARIMA-SEATS manual) are assumed, with the
% following exceptions:
%
% * `Series_Start`, `Series_Data` and `Series_Period` are automatically
% created based on the `inputSeries`;
%
% * `Series_Precision` and `Series_Decimals` are both set to `5` (the
% maximum precision accepted by the X13-ARIMA procedure);
%
% * Either an `X11` spec or a pair of `Seat` and `Automdl` specs are
% included to force the execution of the `X11` type of seasonal adjustment
% (if `d..` types of output tables are requested in `Output`) or the
% execution of the `SEAT` type of seasonal adjustment (if `x..` types of
% output tables are requested in `Output`).
%
%
% If no setting within a particular spec is not defined in the options, the
% spec itself is not included in the input file. To force the inclusion of
% an empty spec in the input file (assuming thus the default values for all
% the settings within that spece), use the name of the spec as an option
% and set it to `true`, e.g. `(..., "Automdl", true, ...)` to force the
% estimation of an ARIMA model based on an automatic model selection
% procedure.
%
% If at least one setting from a particular spec is specified as an option
% in the fuction call, that spec is included explicitly in the input file.
% 
%
% ### Type of Seasonal Adjustment ###
%
% Two types of seasonal adjustments are available in X13-ARIMA: `X11` and
% `SEATS`. Which one is invoked depends on the type of output requested in
% the option `Output`: the output tables starting with a `d` refer to `X11`
% (hence, the default `Output="d11"` invokes `X11` and returns the final
% seasonally adjusted series) whereas the output tables starting with an
% `s` refer to `SEATS`.
%
% Depending on the output tables requested, the correct spec for the
% respective seasonal adjustment procedure will be included in the input
% file and invoked.
%
% The two procedures cannot be combined together in one run; i.e. the
% option `Output` cannot combine `d..` and `s..` output tables.
%
%
% ### Output Tables (Output Series) ###
%
% The following output tables (i.e. output series) can be requested in the option `Output`:
%
% | Name in option `Output`  | Output table in X13 | Description                                                            |
% |--------------------------|---------------------|------------------------------------------------------------------------|
% | `"d10"`                  | `X11_d10`           | `X11` final seasonal factors                                           |
% | `"d11"`                  | `X11_d11`           | `X11` final seasonally adjusted series                                 |
% | `"d12"`                  | `X11_d12`           | `X11` final trend-cycle                                                |
% | `"d13"`                  | `X11_d13`           | `X11` final irregular component                                        |
% | `"d16"`                  | `X11_d16`           | `X11` final combined seasonal and trading day factors                  |
% | `"d18"`                  | `X11_d18`           | `X11` combined holiday and trading day factors                         |
% | `"s10"`                  | `Seats_s10`         | `SEATS` final seasonal component                                       |
% | `"s11"`                  | `Seats_s11`         | `SEATS` final seasonal adjustment component                            |
% | `"s12"`                  | `Seats_s12`         | `SEATS` final trend component                                          |
% | `"s13"`                  | `Seats_s13`         | `SEATS` final irregular component                                      |
% | `"s14"`                  | `Seats_s14`         | `SEATS` final transitory component                                     |
% | `"s16"`                  | `Seats_s16`         | `SEATS` final combined adjustment component                            |
% | `"s18"`                  | `Seats_s18`         | `SEATS` final adjustment ratio                                         |
% | `"cyc"`                  | `Seats_cyc`         | `SEATS` cycle component                                                |
% | `"a18"`                  | `Series_a18`        | Original series adjusted for regARIMA calendar effects                 |
% | `"a19"`                  | `Series_a19`        | Original series adjusted for regARIMA outliers                         |
% | `"b1"`                   | `Series_b1`         | Original series, adjusted for prior effects and forecast extended      |
% | `"mva"`                  | `Series_mva`        | Original series with missing values replaced by regARIMA estimates     |
% | `"saa"`                  | `Force_saa`         | Final seasonally adjusted series with constrained yearly totals        |
% | `"rnd"`                  | `Force_rnd`         | Rounded final seasonally adjusted series                               |
% | `"fct"`                  | `Forecast_fct`      | Point forecasts on the original scale                                  |
% | `"bct"`                  | `Forecast_bct`      | Point backcasts on the original scale                                  |
% | `"ftr"`                  | `Forecast_ftr`      |  Point forecasts on the transformed scale                              |
% | `"btr"`                  | `Forecast_btr`      |  Point backcasts on the transformed scale                              |
%
%
% Example
%--------------------------------------------------------------------------
%
% A plain vanilla call
%
%     xsa = x13.season(x)
%
% or
%
%     [xsa, info] = x13.season(x)
%
% produces a seasonally adjusted series `xsa` with all default settings
% (hence no ARIMA model estimated).
%
%
% Example
%--------------------------------------------------------------------------
%
% Estimate an ARIMA model based on an automatic model selection
% procedures, use the ARIMA information in the seasonal
% adjustment, and return the estimated ARIMA model in the output `info`
% struct:
%
%     [xsa, info] = x13.season(x, "Automdl", true, "Estimate_Save", "mdl")
%
%
% Example
%--------------------------------------------------------------------------
%
% Request additional output series: the seasonally adjusted series, the
% seasonal factors and the trend cycle component:
%
%     [xsa, xsf, xtc, info] = x13.season(x, "Output", ["d11", "d10", "d12"]);
%
%
% Example
%--------------------------------------------------------------------------
%
% Run seasonal adjustment based on an automatically selected ARIMA model
% with dummy variables of additive outliers in period 2017Q3, 2017Q4 and
% 2018Q1:
%
%     xsa = x13.season(x ...
%         , "Automdl", true ...
%         , "Regression_Variables", "aos2017.3-2018.1" ...
%     );
%
% This call is equivalent to creating the dummies manually (a time series
% object with three columns), and using the option `Regression_Data`
% instead:
%
%     dummy = Series(startDate:endDate, zeros(1, 3));
%     dummy(qq(2017,3), 1) = 1;
%     dummy(qq(2017,4), 2) = 1;
%     dummy(qq(2018,1), 3) = 1;
%
%     xsa = x13.season(x ...
%         , "Automdl", true ...
%         , "Regression_Data", dummy ...
%     );
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function varargout = season(inputSeries, opt, specs)

%(
arguments
    inputSeries Series { locallyValidateInputSeries(inputSeries) }

    opt.Range { mustBeNumeric } = Inf
    opt.Output (1, :) string = "d11"
    opt.Display (1, 1) logical = false
    opt.Cleanup (1, 1) logical = true

    specs.Series_Title string { mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Series_Span (1, :) { locallyValidateSpan(specs.Series_Span) } = double.empty(1, 0)
    specs.Series_ModelSpan (1, :) { locallyValidateSpan(specs.Series_ModelSpan) } = double.empty(1, 0)
    specs.Series_Precision { mustBeInteger, mustBeScalarOrEmpty, mustBeInRange(specs.Series_Precision, 0, 5) } = 5
    specs.Series_Decimals  { mustBeInteger, mustBeScalarOrEmpty, mustBeInRange(specs.Series_Decimals, 0, 5) } = 5
    specs.Series_CompType string { mustBeScalarOrEmpty, validate.mustBeAnyString(specs.Series_CompType, ["add", "sub", "mult", "div", "none"]) } = string.empty(1, 0)
    specs.Series_CompWeight { mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.Series_AppendBcst logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Series_AppendFcst logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Series_Type string { mustBeScalarOrEmpty, validate.mustBeAnyString(specs.Series_Type, ["stock", "flow"]) } = string.empty(1, 0)
    specs.Series_Save (1, :) string { mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.X11_Mode { mustBeScalarOrEmpty, locallyValidateX11Mode } = string.empty(1, 0)
    specs.X11_SeasonalMA (1, :) string = string.empty(1, 0)
    specs.X11_TrendMA { mustBeScalarOrEmpty, mustBeInteger, mustBeInRange(specs.X11_TrendMA, 3, 101) } = double.empty(1, 0)
    specs.X11_SigmaLim (1, :) { mustBeNumeric, mustBePositive } = double.empty(1, 0)
    specs.X11_Title string { mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_AppendFcst logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.X11_AppendBcst logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.X11_Final string { mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_Print (1, :) string { mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_Save (1, :) string { mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_SaveLog (1, :) string { mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.Transform logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Transform_Function string { mustBeScalarOrEmpty, validate.mustBeAnyString(specs.Transform_Function, ["auto", "log", "sqrt", "inverse", "logistic", "none"]) } = string.empty(1, 0)
    specs.Transform_Power { mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Transform_Adjust string { mustBeScalarOrEmpty, validate.mustBeAnyString(specs.Transform_Adjust, ["lom", "loq", "lpyear"]) } = string.empty(1, 0)
    specs.Transform_Title string { mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Transform_AicDiff { mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Transform_Print (1, :) string { mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Transform_Save (1, :) string { mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Transform_SaveLog (1, :) string { mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.Estimate logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Estimate_Tol { mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.Estimate_MaxIter { mustBeScalarOrEmpty, mustBePositive, mustBeInteger } = double.empty(1, 0)
    specs.Estimate_Exact string { mustBeScalarOrEmpty, validate.mustBeAnyString(specs.Estimate_Exact, ["arma", "ma", "none"]) } = string.empty(1, 0)
    specs.Estimate_OutOfSample logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Estimate_Print (1, :) string = string.empty(1, 0)
    specs.Estimate_Save (1, :) string = string.empty(1, 0)
    specs.Estimate_SaveLog (1, :) string = string.empty(1, 0)

    specs.Automdl logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Automdl_MaxOrder (1, :) { mustBeInteger, mustBePositive } = double.empty(1, 0)
    specs.Automdl_MaxDiff (1, :) { mustBeInteger, mustBePositive } = double.empty(1, 0)
    specs.Automdl_Diff (1, :) { mustBeInteger, mustBePositive } = double.empty(1, 0)
    specs.Automdl_AcceptDefault logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Automdl_CheckMu logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Automdl_LjungBoxLimit { mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.Automdl_Mixed logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Automdl_Print (1, :) string { mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Automdl_SaveLog (1, :) string { mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.Arima logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Arima_Model (1, :) string { mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Arima_AR (1, :) { mustBeNumeric } = double.empty(1, 0)
    specs.Arima_MA (1, :) { mustBeNumeric } = double.empty(1, 0)
    specs.Arima_Title string { mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.Force logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Force_Type string { mustBeScalarOrEmpty, validate.mustBeAnyString(specs.Force_Type, ["none", "regress", "denton"]) } = string.empty(1, 0)
    specs.Force_Lambda { mustBeScalarOrEmpty, mustBeNumeric, mustBeInRange(specs.Force_Lambda, -3, 3) } = double.empty(1, 0)
    specs.Force_Rho { mustBeScalarOrEmpty, mustBeNumeric, mustBeInRange(specs.Force_Rho, 0, 1) } = double.empty(1, 0)
    specs.Force_Round logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Force_Start { mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Force_Target string { mustBeScalarOrEmpty, validate.mustBeAnyString(specs.Force_Target, ["original", "caladjust", "permprioradj", "both"]) } = string.empty(1, 0)
    specs.Force_UseFcst logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Force_Print (1, :) string = string.empty(1, 0)
    specs.Force_Save (1, :) string = string.empty(1, 0)

    specs.Forecast logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Forecast_MaxLead { mustBeScalarOrEmpty, mustBeInteger, mustBeInRange(specs.Forecast_MaxLead, 0, 120) } = double.empty(1, 0)
    specs.Forecast_MaxBack { mustBeScalarOrEmpty, mustBeInteger, mustBeInRange(specs.Forecast_MaxBack, 0, 120) } = double.empty(1, 0)
    specs.Forecast_Exclude { mustBeScalarOrEmpty, mustBeInteger, mustBeInRange(specs.Forecast_Exclude, 0, 10000) } = double.empty(1, 0)
    specs.Forecast_LogNormal logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Forecast_Print (1, :) string = string.empty(1, 0)
    specs.Forecast_Save (1, :) string = string.empty(1, 0)

    specs.Regression logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Regression_Variables (1, :) string = string.empty(1, 0)
    specs.Regression_TestAllEaster logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Regression_Data Series = Series.empty(0)
    specs.Regression_User (1, :) string = string.empty(1, 0)
    specs.Regression_UserType (1, :) string = string.empty(1, 0)
    specs.Regression_AicTest (1, :) string = string.empty(1, 0)
    specs.Regression_AicDiff (1, :) { mustBeNumeric } = double.empty(1, 0)
    specs.Regression_PVAicTest { mustBeScalarOrEmpty, mustBeNumeric, mustBeInRange(specs.Regression_PVAicTest, 0, 1) } = double.empty(1, 0)
    specs.Regression_TLimit { mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Regression_Chi2Test logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Regression_Chi2TestCV { mustBeScalarOrEmpty, mustBeNumeric, mustBeInRange(specs.Regression_Chi2TestCV, 0, 1) } = double.empty(1, 0)
    specs.Regression_Print (1, :) string = string.empty(1, 0)
    specs.Regression_Save (1, :) string = string.empty(1, 0)
    specs.Regression_SaveLog (1, :) string = string.empty(1, 0)

    specs.X11Regression logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.X11Regression_Variables (1, :) string = string.empty(1, 0)
    specs.X11Regression_Data Series = Series.empty(0)
    specs.X11Regression_User (1, :) string = string.empty(1, 0)
    specs.X11Regression_UserType (1, :) string = string.empty(1, 0)
    specs.X11Regression_AicTest (1, :) string = string.empty(1, 0)
    specs.X11Regression_AicDiff (1, :) { mustBeNumeric } = double.empty(1, 0)
    specs.X11Regression_TDPrior (1, :) { mustBeNumeric, mustBeNonnegative, locallyValidateTDPrior(specs.X11Regression_TDPrior) } = double.empty(1, 0)
    specs.X11Regression_Prior logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.X11Regression_Span (1, :) { locallyValidateSpan(specs.X11Regression_Span) } = double.empty(1, 0)
    specs.X11Regression_Sigma { mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.X11Regression_Critical { mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.X11Regression_OutlierMethod string { mustBeScalarOrEmpty, validate.mustBeAnyString(specs.X11Regression_OutlierMethod, ["addone", "addall"]) } = string.empty(1, 0)
    specs.X11Regression_OutlierSpan (1, :) { locallyValidateSpan(specs.X11Regression_OutlierSpan) } = double.empty(1, 0)
    specs.X11Regression_Print (1, :) string = string.empty(1, 0)
    specs.X11Regression_Save (1, :) string = string.empty(1, 0)
    specs.X11Regression_SaveLog (1, :) string = string.empty(1, 0)

    specs.Seats logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_AppendFcst logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_HpCycle logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_NoAdmiss logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_QMax { mustBeScalarOrEmpty, mustBeNonnegative } = double.empty(1, 0)
    specs.Seats_RMod { mustBeScalarOrEmpty, mustBeNonnegative, mustBeInRange(specs.Seats_RMod, 0, 1) } = double.empty(1, 0)
    specs.Seats_Out { mustBeScalarOrEmpty, mustBeMember(specs.Seats_Out, [0, 1, 2]) } = double.empty(1, 0)
    specs.Seats_StatSeas logical { mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_TabTables (1, :) string = string.empty(1, 0)
    specs.Seats_PrintPhtrf { mustBeScalarOrEmpty, mustBeMember(specs.Seats_PrintPhtrf, [0, 1]) } = double.empty(1, 0)
    specs.Seats_Print (1, :) string = string.empty(1, 0)
    specs.Seats_Save (1, :) string = string.empty(1, 0)
    specs.Seats_SaveLog (1, :) string = string.empty(1, 0)
end
%)

if ~isequal(opt.Range, Inf)
    [from, to] = resolveRange(inputSeries, opt.Range);
    inputSeries = clip(inputSeries, from, to);
end

outputTables = x13.resolveOutputTables(opt.Output);
specs = locallyWriteOutputTablesToSpecs(specs, outputTables);

numOutputTables = numel(outputTables);

sizeData = size(inputSeries);
numColumns = prod(sizeData(2:end));

outputData = cell(numColumns, numOutputTables); 
outputInfo = [ ];
inxError = false(1, numColumns);

specs = locallyRemoveEmptySpecs(specs);
x13.checkSpecsConflicts(specs);
specs = locallyResolveDataAttributes(specs);
specs = locallyRequestArimaForSeats(specs);

[dataColumns, startDates, freq] = x13.splitDataColumns(inputSeries);

for i = find(~isnan(startDates))
    specs__ = specs;

    data__ = double(dataColumns{i});
    start__ = double(startDates(i));

    %
    % Prepare the attribute Data for the spec Series; the existence of the
    % attribute Data in Series ensures that Series will be always included
    % in the spc file
    %
    [specs__, flipSign__] = locallyResolveAutoMode(data__, specs__);
    data__ = flipSign__*data__;
    data__ = locallyAdjustDataForNaNs(data__);
    specs__.Series_Start = double(start__);
    specs__.Series_Period = double(freq);
    specs__.Series_Data = double(data__);

    info__ = struct( );

    %
    % Translate the specs struct into a specs code
    %
    specsCode__ = x13.encodeSpecs(specs__);
    info__.InputFiles.spc = specsCode__;

    %
    % Run the X13 exectuable on the code
    %
    [info__.Path, info__.Message] = x13.run(specsCode__, info__, opt);
    info__.OutputFiles = x13.captureOutputFiles(info__.Path, opt);

    %
    % Extract the contents of output files into the OutputFiles struct
    %
    outputData(i, :) = x13.captureOutputTables( ...
        info__.OutputFiles, outputTables, flipSign__, freq ...
    );

    %
    % Extract some more info from output files
    %
    if nargout>=numOutputTables+1
        info__.OutputSpecs = x13.extractInfo(info__.OutputFiles);
    end

    inxError(i) = contains(info__.Message, ["ERROR:", "Check error file"]);
    outputInfo = [outputInfo, info__]; %#ok<AGROW>
end


%
% Concatenate output series when multiple columns
%
if numColumns==1
    varargout = outputData;
else
    varargout = cell(1, numOutputTables);
    for i = 1 : numOutputTables
        varargout{i} = horzcat(outputData{:, i});
    end
end
varargout{end+1} = outputInfo;


if any(inxError)
    exception.warning([
        "X13:RuntimeError"
        "No seasonal adjustment performed on some of the time series "
        "columns because X13 failed with an error. Check out the messages "
        "in info.Message and info.OutputFiles.err"
    ]);
end

end%

%
% Local Functions
%

function specs = locallyWriteOutputTablesToSpecs(specs, outputTables)
    prefixes = extractBefore(outputTables, "_");
    attributes = extractAfter(outputTables, "_");
    for i = 1 : numel(outputTables)
        specs.(prefixes(i) + "_Save")(end+1) = attributes(i); 
    end
end%


function [specs, flipSign] = locallyResolveAutoMode(data, specs)
    flipSign = 1;
    if isfield(specs, "X11_Mode") && isequal(specs.X11_Mode, @auto)
        inxNaN = ~isfinite(data);
        if all(data(~inxNaN)>0)
            specs.X11_Mode = "mult";
        elseif all(data(~inxNaN)<0)
            specs.X11_Mode = "mult";
            flipSign = -1;
        else
            specs.X11_Mode = "add";
        end
    end
end%


function specs = locallyRemoveEmptySpecs(specs)
    specsNames = reshape(string(fieldnames(specs)), 1, [ ]);
    inxRemove = structfun(@isempty, specs);
    specs = rmfield(specs, specsNames(inxRemove));
end%


function specs = locallyResolveDataAttributes(specs)
    specsNames = reshape(string(fieldnames(specs)), 1, [ ]);
    inxData = endsWith(specsNames, "_Data");
    if ~any(inxData)
        return
    end
    invalidDataSpecs = string.empty(1, 0);
    for n = specsNames(inxData)
        prefix = extractBefore(n, "_");
        series = specs.(n);
        if ~isa(series, "Series")
            invalidDataSpecs(end+1) = n;
            continue
        end
        specs.(n) = locallyAdjustDataForNaNs(series.Data);
        specs.(prefix + "_Start") = series.StartAsNumeric;
    end

    if ~isempty(invalidDataSpecs)
        exception.error([
            "X13:InvalidDataSpecs"
            "This data specs needs to be assigned a time series object: %s "
        ], invalidDataSpecs);
    end
end%


function data = locallyAdjustDataForNaNs(data)
    standin = -99999;
    data(data==standin) = standin - 0.01;
    data(~isfinite(data)) = standin;
end%

function specs = locallyRequestArimaForSeats(specs)
% Does not make sense to run Seats without an ARIMA model; make sure either
% Arima or Automdl is included when Seats is unless Automld=false by the
% user.
    specsNames = reshape(string(fieldnames(specs)), 1, [ ]);
    if ~any(startsWith(specsNames, "Seats", "IgnoreCase", true))
        return
    end

    if any(startsWith(specsNames, "Arima", "IgnoreCase", true)) ...
        || any(startsWith(specsNames, "Automdl", "IgnoreCase", true))
        return
    end

    if isfield(specs, "Automdl") && isequal(specs.Automdl, false)
        return
    end

    specs.Automdl = true;
    exception.warning([
        "X13:ForceAutomdlForSeats"
        "An Automdl spec with default settings was included in this X13 run "
        "to force an ARIMA model to be estimated for the Seats spec. "
    ]);
end%


%
% Local Validators
%

function locallyValidateInputSeries(x)
    if any(x.FrequencyAsNumeric==[2, 4, 6, 12])
        return
    end
    error("Local:Validator", "Invalid date frequency of the input time series.");
end%


function locallyValidateX11Mode(x)
    if isequal(x, @auto)
        return
    end
    mustBeMember(x, ["add", "mult", "pseudoadd", "logadd"]);
end%


function locallyValidateTDPrior(x)
    if isempty(x) || numel(x)==7
        return
    end
    error("Local:Validator", "X11Regression_TDPrior must be a 1-by-7 vector of non-negative numbers.");
end%


function locallyValidateSpan(x)
    if isempty(x) 
        return
    end
    if isnumeric(x) && numel(x)==2
        return
    end
    error("Local:Validator", "Time span must be a 1-by-2 vector of dates.");
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=x13/seasonUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);


% Set up Once

d = struct( );
d.x = Series(qq(2002,1), [447.924; 488.926; 503.106; 504.475; 476.584; 506.641; 522.494; 534.332; 525.144; 570.763; 584.736; 591.95; 568.276; 605.741; 616.934; 630.013; 612.312; 652.196; 663.098; 653.885; 630.297; 666.682; 678.601; 670.391; 630.586; 660.254; 667.159; 629.053; 532.98; 542.934; 579.899; 592.762; 572.684; 636.328; 672.832; 661.919; 633.079; 675.741; 694.481; 683.819; 659.703; 700.919; 708.03; 691.199; 654.445; 709.837; 722.323; 715.841; 684.272; 744.107; 751.67; 762.45; 730.599; 781.817; 793.546; 788.83; 747.013; 788.477; 803.988; 806.402; 776.546; 829.074; 834.472; 852.272; 811.231; 857.899; 876.732; 881.349; 826.41; 882.253; 892.011; 863.515; 789.285; 678.542]);
d.y = d.x{-Inf:qq(2018,4)};
d.z = d.x{qq(2005,3):Inf};


%% Test Plain Vanilla

sa = x13.season(d.x);
assertClass(testCase, sa, "Series");
assertEqual(testCase, sa.StartAsNumeric, d.x.StartAsNumeric, "AbsTol", 1e-10);
assertEqual(testCase, sa.EndAsNumeric, d.x.EndAsNumeric, "AbsTol", 1e-10);


%% Test Multiple Outputs

[sa, sf, tc, ir, info] = x13.season( ...
    d.x ...
    , "Output", ["d11", "d10", "d12", "d13", "fct"] ...
    , "X11_Mode", "add" ...
);

assertEqual(testCase, getData(d.x, Inf), getData(sf+tc+ir, Inf), "AbsTol", 1e-10);


%% Test Multiple Inputs

[sa, sf, info] = x13.season( ...
    [d.x, d.y, d.z] ...
    , "Output", ["d11", "d10"] ...
    , "X11_Mode", "add" ...
);

assertSize(testCase, sa{:, 1}, size(d.x));
assertSize(testCase, sa{:, 2}, size(d.y));
assertSize(testCase, sa{:, 3}, size(d.z));

assertSize(testCase, sf{:, 1}, size(d.x));
assertSize(testCase, sf{:, 2}, size(d.y));
assertSize(testCase, sf{:, 3}, size(d.z));

%% Test Model

[sa, info] = x13.season( ...
    d.x ...
    , "X11_Mode", "add" ...
    , "Estimate_Save", "mdl" ...
);

assertEqual(testCase, info.OutputSpecs.Arima_Model, "(0,0,0)");
assertSize(testCase, info.OutputSpecs.Arima_AR, [1, 0]);
assertSize(testCase, info.OutputSpecs.Arima_MA, [1, 0]);

[sa, info] = x13.season( ...
    d.y ...
    , "X11_Mode", "add" ...
    , "Automdl", true ...k
    , "Estimate_Save", "mdl" ...
);

assertEqual(testCase, info.OutputSpecs.Arima_Model, "(0,1,1)(0,1,1)");
assertEqual(testCase, info.OutputSpecs.Arima_AR, double.empty(1, 0));
assertSize(testCase, info.OutputSpecs.Arima_MA, [1, 2]);


%% Test Forecast

[fct, info] = x13.season( ...
    d.x ...
    , "Output", "fct" ...
    , "Automdl", true ...
    , "Forecast_MaxLead", 24 ...
);

assertSize(testCase, fct, [24, 1]);

[fct, bct, info] = x13.season( ...
    [d.x, d.y, d.z] ...
    , "Output", ["fct", "bct"] ...
    , "Automdl", true ...
    , "Forecast_MaxLead", 24 ...
);

assertSize(testCase, fct, [30, 3]);
assertSize(testCase, bct, [0, 3]);


%% Test Backcast

[bct, info] = x13.season( ...
    d.x ...
    , "Output", "bct" ...
    , "Automdl", true ...
    , "Forecast_MaxBack", 24 ...
    , "Forecast_MaxLead", 0 ...
);

assertSize(testCase, bct, [24, 1]);

[fct, bct, info] = x13.season( ...
    [d.x, d.y, d.z] ...
    , "Output", ["fct", "bct"] ...
    , "Automdl", true ...
    , "Forecast_MaxBack", 24 ...
    , "Forecast_MaxLead", 0 ...
);

assertSize(testCase, bct, [38, 3]);
assertSize(testCase, fct, [0, 3]);


%% Test Arima 

[sa, info] = x13.season( ...
    d.x ...
    , "Arima_Model", "(0 1 1)(0 1 1)" ...
    , "Estimate_Save", "mdl" ...
);

assertEqual(testCase, info.OutputSpecs.Arima_Model, "(0,1,1)(0,1,1)");

[sa2, info2] = x13.season( ...
    d.x ...
    , "Arima_Model", "(0 1 1)(0 1 1)" ...
    , "Arima_MA", round(info.OutputSpecs.Arima_MA, 1)*1i ...
    , "Estimate_Save", "mdl" ...
);

assertEqual(testCase, info2.OutputSpecs.Arima_MA, round(info.OutputSpecs.Arima_MA, 1), "AbsTol", 1e-10);


%% Test Dummies

[sa, info] = x13.season( ...
    [d.x, d.y] ...
    , "X11_Mode", "add" ...
    , "Automdl", true ...
    , "Regression_Variables", ["aos2013.1-2013.4"] ...
    , "Forecast_MaxLead", 0 ...
);

dummy = Series(d.x.Range, [0, 0, 0, 0]);
for k = 1 : 4
    dummy(qq(2013,k), k) = 1;
end

[sa2, info2] = x13.season( ...
    [d.x, d.y] ...
    , "X11_Mode", "add" ...
    , "Automdl", true ...
    , "Regression_Data", dummy ...
    , "Regression_User", ["a","b","c","d"] ...
    , "Forecast_MaxLead", 0 ...
);

assertEqual(testCase, sa.Data, sa2.Data, "AbsTol", 1e-10);

##### SOURCE END #####
%}
