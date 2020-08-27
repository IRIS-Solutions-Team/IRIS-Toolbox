% x13.season  Interface to X13-Arima seasonal adjustment procedure

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
end
%)

if ~isequal(opt.Range, Inf)
    [from, to] = resolveRange(inputSeries, opt.Range);
    inputSeries = clip(inputSeries, from, to);
end

[outputTables, specs] = locallyResolveOutputTables(opt.Output, specs);
numOutputTables = numel(outputTables);

sizeData = size(inputSeries);
numColumns = prod(sizeData(2:end));

outputData = cell(numColumns, numOutputTables); 
outputInfo = [ ];
inxError = false(1, numColumns);

specs = locallyRemoveEmptySpecs(specs);
specs = locallyResolveDataAttributes(specs);

for i = 1 : numColumns
    specs__ = specs;
    [data__, specs__] ...
        = locallyResolveData(inputSeries.Data(:, i), inputSeries.StartAsNumeric, specs__);

    if isempty(data__)
        continue
    end

    %
    % Prepare the attribute Data for the spec Series; the existence of the
    % attribute Data in Series ensures that Series will be always included
    % in the spc file
    %
    [specs__, flipSign__] = locallyResolveAutoMode(data__, specs__);
    data__ = flipSign__*data__;
    data__ = locallyAdjustDataForNaNs(data__);
    specs__.Series_Data = data__;

    %
    % Manually force the spec X11 to be always included in the spc file
    %
    specs__.X11 = true;

    info__ = struct( );

    specsCode__ = x13.encodeSpecs(specs__);
    info__.InputFiles.spc = specsCode__;

    [info__.Path, info__.Message] = x13.run(specsCode__, info__, opt);
    info__.OutputFiles = x13.captureOutputFiles(info__.Path, opt);

    outputData(i, :) = x13.captureOutputTables( ...
        info__.OutputFiles, outputTables, flipSign__, inputSeries.FrequencyAsNumeric ...
    );

    info__ = locallyPopulateInfo(info__);

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
    exception.error([
        "X13:RuntimeError"
        "No seasonal adjustment performed on some of the time series "
        "columns because X13 failed with an error. Capture and check "
        "the info.OutputFIle.err output argument for details."
    ]);
end

end%

%
% Local Functions
%

function [outputTables, specs] = locallyResolveOutputTables(output, specs)
    map = struct( );
    map.sf = "X11_d10";
    map.sa = "X11_d11";
    map.tc = "X11_d12";
    map.irr = "X11_d13";

    map.a18 = "Series_a18";
    map.a19 = "Series_a19";
    map.b1 = "Series_b1";
    map.mva = "Series_mva";

    map.d10 = "X11_d10";
    map.d11 = "X11_d11";
    map.d12 = "X11_d12";
    map.d13 = "X11_d13";
    map.d16 = "X11_d16";
    map.d18 = "X11_d18";

    map.saa = "Force_saa";
    map.rnd = "Force_rnd";
    
    map.fct = "Forecast_fct";
    map.bct = "Forecast_bct";
    map.ftr = "Forecast_ftr";
    map.btr = "Forecast_btr";

    output = reshape(lower(string(output)), 1, [ ]);
    outputTables = string.empty(1, 0);
    for n = output
        outputTables(end+1) = map.(n); %#ok<AGROW>
        prefix = extractBefore(map.(n), "_");
        specs.(prefix + "_Save")(end+1) = lower(extractAfter(map.(n), "_")); 
    end
end%


function [data, specs] = locallyResolveData(inputSeries, startDate, specs)
    %(
    inxNaN = ~isfinite(inputSeries);
    first = find(~inxNaN, 1, 'First');
    last = find(~inxNaN, 1, 'Last');
    if isempty(first) || isempty(last)
        data = [ ];
        return
    end
    data = inputSeries(first:last);
    startDate = dater.plus(startDate, first-1);
    specs.Series_Start = double(startDate);
    specs.Series_Period = dater.getFrequency(startDate);
    %)
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
    for n = specsNames(inxData)
        prefix = extractBefore(n, "_");
        series = specs.(n);
        specs.(n) = locallyAdjustDataForNaNs(series.Data);
        specs.(prefix + "_Start") = series.StartAsNumeric;
    end
end%


function data = locallyAdjustDataForNaNs(data)
    standin = -99999;
    data(data==standin) = standin - 0.01;
    data(~isfinite(data)) = standin;
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

function info = locallyPopulateInfo(info)
    info.Mode = "?";
    if isfield(info.OutputFiles, "out") && strlength(info.OutputFiles.out)>0
        x = regexpi(info.OutputFiles.out, "Type of run\s*-\s*(\w+)", "tokens", "once");
        if ~isempty(x)
            if startsWith(x, "m", "IgnoreCase", true)
                info.Mode = "mult";
            elseif startsWith(x, "a", "IgnoreCase", true)
                info.Mode = "add";
            elseif startsWith(x, "p", "IgnoreCase", true)
                info.Mode = "pseudoadd";
            elseif startsWith(x, "l", "IgnoreCase", true)
                info.Mode = "logadd";
            else
                info.Mode = "unknown";
            end
        end
    end
end%

