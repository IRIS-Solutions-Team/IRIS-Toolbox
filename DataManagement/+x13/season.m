% Type `web +x13/season.md` for help on this function
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function varargout = season(inputSeries, range, opt, specs)

% >=R2019b
%(
arguments
    inputSeries Series { locallyValidateInputSeries(inputSeries) }
    range {validate.rangeInput} = Inf 

    opt.Output (1, :) string = "d11"
    opt.Display (1, 1) logical = false
    opt.Cleanup (1, 1) logical = true

    specs.Series_Title string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Series_Span (1, :) { locallyValidateSpan(specs.Series_Span) } = double.empty(1, 0)
    specs.Series_ModelSpan (1, :) { locallyValidateSpan(specs.Series_ModelSpan) } = double.empty(1, 0)
    specs.Series_Precision { mustBeInteger, validate.mustBeScalarOrEmpty, validate.mustBeInRange(specs.Series_Precision, 0, 5) } = 5
    specs.Series_Decimals  { mustBeInteger, validate.mustBeScalarOrEmpty, validate.mustBeInRange(specs.Series_Decimals, 0, 5) } = 5
    specs.Series_CompType string { validate.mustBeScalarOrEmpty, validate.mustBeAnyStringOrEmpty(specs.Series_CompType, ["add", "sub", "mult", "div", "none"]) } = string.empty(1, 0)
    specs.Series_CompWeight { validate.mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.Series_AppendBcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Series_AppendFcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Series_Type string { validate.mustBeScalarOrEmpty, validate.mustBeAnyStringOrEmpty(specs.Series_Type, ["stock", "flow"]) } = string.empty(1, 0)
    specs.Series_Save (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.X11_Mode { validate.mustBeScalarOrEmpty, locallyValidateX11Mode } = @auto % string.empty(1, 0)
    specs.X11_SeasonalMA (1, :) string = string.empty(1, 0)
    specs.X11_TrendMA { validate.mustBeScalarOrEmpty, mustBeInteger, validate.mustBeInRange(specs.X11_TrendMA, 3, 101) } = double.empty(1, 0)
    specs.X11_SigmaLim (1, :) { mustBeNumeric, mustBePositive } = double.empty(1, 0)
    specs.X11_Title string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_AppendFcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.X11_AppendBcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.X11_Final string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_Print (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_Save (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_SaveLog (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.Transform logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Transform_Function string { validate.mustBeScalarOrEmpty, validate.mustBeAnyStringOrEmpty(specs.Transform_Function, ["auto", "log", "sqrt", "inverse", "logistic", "none"]) } = string.empty(1, 0)
    specs.Transform_Power { validate.mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Transform_Adjust string { validate.mustBeScalarOrEmpty, validate.mustBeAnyStringOrEmpty(specs.Transform_Adjust, ["lom", "loq", "lpyear"]) } = string.empty(1, 0)
    specs.Transform_Title string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Transform_AicDiff { validate.mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Transform_Print (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Transform_Save (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Transform_SaveLog (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.Estimate logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Estimate_Tol { validate.mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.Estimate_MaxIter { validate.mustBeScalarOrEmpty, mustBePositive, mustBeInteger } = double.empty(1, 0)
    specs.Estimate_Exact string { validate.mustBeScalarOrEmpty, validate.mustBeAnyStringOrEmpty(specs.Estimate_Exact, ["arma", "ma", "none"]) } = string.empty(1, 0)
    specs.Estimate_OutOfSample logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Estimate_Print (1, :) string = string.empty(1, 0)
    specs.Estimate_Save (1, :) string = string.empty(1, 0)
    specs.Estimate_SaveLog (1, :) string = string.empty(1, 0)

    specs.Automdl logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Automdl_MaxOrder (1, :) { mustBeInteger, mustBePositive } = double.empty(1, 0)
    specs.Automdl_MaxDiff (1, :) { mustBeInteger, mustBePositive } = double.empty(1, 0)
    specs.Automdl_Diff (1, :) { mustBeInteger, mustBePositive } = double.empty(1, 0)
    specs.Automdl_AcceptDefault logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Automdl_CheckMu logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Automdl_LjungBoxLimit { validate.mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.Automdl_Mixed logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Automdl_Print (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Automdl_SaveLog (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.Arima logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Arima_Model (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Arima_AR (1, :) { mustBeNumeric } = double.empty(1, 0)
    specs.Arima_MA (1, :) { mustBeNumeric } = double.empty(1, 0)
    specs.Arima_Title string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.Force logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Force_Type string { validate.mustBeScalarOrEmpty, validate.mustBeAnyStringOrEmpty(specs.Force_Type, ["none", "regress", "denton"]) } = string.empty(1, 0)
    specs.Force_Lambda { validate.mustBeScalarOrEmpty, mustBeNumeric, validate.mustBeInRange(specs.Force_Lambda, -3, 3) } = double.empty(1, 0)
    specs.Force_Rho { validate.mustBeScalarOrEmpty, mustBeNumeric, validate.mustBeInRange(specs.Force_Rho, 0, 1) } = double.empty(1, 0)
    specs.Force_Round logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Force_Start { validate.mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Force_Target string { validate.mustBeScalarOrEmpty, validate.mustBeAnyStringOrEmpty(specs.Force_Target, ["original", "caladjust", "permprioradj", "both"]) } = string.empty(1, 0)
    specs.Force_UseFcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Force_Print (1, :) string = string.empty(1, 0)
    specs.Force_Save (1, :) string = string.empty(1, 0)

    specs.Forecast logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Forecast_MaxLead { validate.mustBeScalarOrEmpty, mustBeInteger, validate.mustBeInRange(specs.Forecast_MaxLead, 0, 120) } = double.empty(1, 0)
    specs.Forecast_MaxBack { validate.mustBeScalarOrEmpty, mustBeInteger, validate.mustBeInRange(specs.Forecast_MaxBack, 0, 120) } = double.empty(1, 0)
    specs.Forecast_Exclude { validate.mustBeScalarOrEmpty, mustBeInteger, validate.mustBeInRange(specs.Forecast_Exclude, 0, 10000) } = double.empty(1, 0)
    specs.Forecast_LogNormal logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Forecast_Print (1, :) string = string.empty(1, 0)
    specs.Forecast_Save (1, :) string = string.empty(1, 0)

    specs.Regression logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Regression_Variables (1, :) string = string.empty(1, 0)
    specs.Regression_TestAllEaster logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Regression_Data Series = Series.empty(0)
    specs.Regression_User (1, :) string = string.empty(1, 0)
    specs.Regression_UserType (1, :) string = string.empty(1, 0)
    specs.Regression_AicTest (1, :) string = string.empty(1, 0)
    specs.Regression_AicDiff (1, :) { mustBeNumeric } = double.empty(1, 0)
    specs.Regression_PVAicTest { validate.mustBeScalarOrEmpty, mustBeNumeric, validate.mustBeInRange(specs.Regression_PVAicTest, 0, 1) } = double.empty(1, 0)
    specs.Regression_TLimit { validate.mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Regression_Chi2Test logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Regression_Chi2TestCV { validate.mustBeScalarOrEmpty, mustBeNumeric, validate.mustBeInRange(specs.Regression_Chi2TestCV, 0, 1) } = double.empty(1, 0)
    specs.Regression_Print (1, :) string = string.empty(1, 0)
    specs.Regression_Save (1, :) string = string.empty(1, 0)
    specs.Regression_SaveLog (1, :) string = string.empty(1, 0)

    specs.X11Regression logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.X11Regression_Variables (1, :) string = string.empty(1, 0)
    specs.X11Regression_Data Series = Series.empty(0)
    specs.X11Regression_User (1, :) string = string.empty(1, 0)
    specs.X11Regression_UserType (1, :) string = string.empty(1, 0)
    specs.X11Regression_AicTest (1, :) string = string.empty(1, 0)
    specs.X11Regression_AicDiff (1, :) { mustBeNumeric } = double.empty(1, 0)
    specs.X11Regression_TDPrior (1, :) { mustBeNumeric, mustBeNonnegative, locallyValidateTDPrior(specs.X11Regression_TDPrior) } = double.empty(1, 0)
    specs.X11Regression_Prior logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.X11Regression_Span (1, :) { locallyValidateSpan(specs.X11Regression_Span) } = double.empty(1, 0)
    specs.X11Regression_Sigma { validate.mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.X11Regression_Critical { validate.mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.X11Regression_OutlierMethod string { validate.mustBeScalarOrEmpty, validate.mustBeAnyStringOrEmpty(specs.X11Regression_OutlierMethod, ["addone", "addall"]) } = string.empty(1, 0)
    specs.X11Regression_OutlierSpan (1, :) { locallyValidateSpan(specs.X11Regression_OutlierSpan) } = double.empty(1, 0)
    specs.X11Regression_Print (1, :) string = string.empty(1, 0)
    specs.X11Regression_Save (1, :) string = string.empty(1, 0)
    specs.X11Regression_SaveLog (1, :) string = string.empty(1, 0)

    specs.Seats logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_AppendFcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_HpCycle logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_NoAdmiss logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_QMax { validate.mustBeScalarOrEmpty, mustBeNonnegative } = double.empty(1, 0)
    specs.Seats_RMod { validate.mustBeScalarOrEmpty, mustBeNonnegative, validate.mustBeInRange(specs.Seats_RMod, 0, 1) } = double.empty(1, 0)
    specs.Seats_Out { validate.mustBeScalarOrEmpty, mustBeMember(specs.Seats_Out, [0, 1, 2]) } = double.empty(1, 0)
    specs.Seats_StatSeas logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_TabTables (1, :) string = string.empty(1, 0)
    specs.Seats_PrintPhtrf { validate.mustBeScalarOrEmpty, mustBeMember(specs.Seats_PrintPhtrf, [0, 1]) } = double.empty(1, 0)
    specs.Seats_Print (1, :) string = string.empty(1, 0)
    specs.Seats_Save (1, :) string = string.empty(1, 0)
    specs.Seats_SaveLog (1, :) string = string.empty(1, 0)
end
%)
% >=R2019b

if ~isequal(range, Inf)
    [from, to] = resolveRange(inputSeries, range);
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
            invalidDataSpecs(end+1) = n; %#ok<AGROW>
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

if ~verLessThan("matlab", "9.9")
    sa = x13.season(d.x);
    assertClass(testCase, sa, "Series");
    assertEqual(testCase, sa.StartAsNumeric, d.x.StartAsNumeric, "AbsTol", 1e-10);
    assertEqual(testCase, sa.EndAsNumeric, d.x.EndAsNumeric, "AbsTol", 1e-10);
end


%% Test Multiple Outputs

if ~verLessThan("matlab", "9.9")
    [sa, sf, tc, ir, info] = x13.season( ...
        d.x ...
        , "Output", ["d11", "d10", "d12", "d13", "fct"] ...
        , "X11_Mode", "add" ...
    );
    assertEqual(testCase, getData(d.x, Inf), getData(sf+tc+ir, Inf), "AbsTol", 1e-10);
end


%% Test Multiple Inputs

if ~verLessThan("matlab", "9.9")
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
end


%% Test Model

if ~verLessThan("matlab", "9.9")
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
end

%% Test Forecast

if ~verLessThan("matlab", "9.9")
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
end


%% Test Backcast

if ~verLessThan("matlab", "9.9")
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
end


%% Test Arima 

if ~verLessThan("matlab", "9.9")
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
end


%% Test Dummies

if ~verLessThan("matlab", "9.9")
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
end

##### SOURCE END #####
%}
