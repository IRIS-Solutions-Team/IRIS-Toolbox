% Type `web +x13/season.md` for help on this function
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function varargout = season(inputSeries, range, opt, specs)

arguments
    inputSeries Series { local_validateInputSeries(inputSeries) }
    range {validate.rangeInput} = Inf 

    opt.Output (1, :) string = "d11"
    opt.Display (1, 1) logical = false
    opt.Cleanup (1, 1) logical = true

    specs.Series_Title string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Series_Span (1, :) { local_validateSpan(specs.Series_Span) } = double.empty(1, 0)
    specs.Series_ModelSpan (1, :) { local_validateSpan(specs.Series_ModelSpan) } = double.empty(1, 0)
    specs.Series_Precision { local_validatePrecision } = 5
    specs.Series_Decimals  { local_validatePrecision } = 5
    specs.Series_CompType string { local_validateCompType } = string.empty(1, 0)
    specs.Series_CompWeight { validate.mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.Series_AppendBcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Series_AppendFcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Series_Type string { local_validateSeriesType } = string.empty(1, 0)
    specs.Series_Save (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.X11_Mode { validate.mustBeScalarOrEmpty, local_validateX11Mode } = @auto 
    specs.X11_SeasonalMA (1, :) string = string.empty(1, 0)
    specs.X11_TrendMA { local_validateTrendMA } = double.empty(1, 0)
    specs.X11_SigmaLim (1, :) { mustBeNumeric, mustBePositive } = double.empty(1, 0)
    specs.X11_Title string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_AppendFcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.X11_AppendBcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.X11_Final string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_Print (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_Save (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.X11_SaveLog (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.Transform logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Transform_Function string { local_validateFunction } = string.empty(1, 0)
    specs.Transform_Power { validate.mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Transform_Adjust string { local_validateAdjust } = string.empty(1, 0)
    specs.Transform_Title string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Transform_AicDiff { validate.mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Transform_Print (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Transform_Save (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)
    specs.Transform_SaveLog (1, :) string { validate.mustBeScalarOrEmpty } = string.empty(1, 0)

    specs.Estimate logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Estimate_Tol { validate.mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.Estimate_MaxIter { validate.mustBeScalarOrEmpty, mustBePositive, mustBeInteger } = double.empty(1, 0)
    specs.Estimate_Exact string { local_validateExact } = string.empty(1, 0)
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
    specs.Force_Type string { local_validateForceType } = string.empty(1, 0)
    specs.Force_Lambda { local_validateForceLambda } = double.empty(1, 0)
    specs.Force_Rho { local_validateForceRho } = double.empty(1, 0)
    specs.Force_Round logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Force_Start { validate.mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Force_Target string { local_validateForceTarget } = string.empty(1, 0)
    specs.Force_UseFcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Force_Print (1, :) string = string.empty(1, 0)
    specs.Force_Save (1, :) string = string.empty(1, 0)

    specs.Forecast logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Forecast_MaxLead { validate.mustBeScalarOrEmpty, mustBeInteger, mustBeGreaterThanOrEqual(specs.Forecast_MaxLead, 0), mustBeLessThanOrEqual(specs.Forecast_MaxLead, 120) } = double.empty(1, 0)
    specs.Forecast_MaxBack { validate.mustBeScalarOrEmpty, mustBeInteger, mustBeGreaterThanOrEqual(specs.Forecast_MaxBack, 0), mustBeLessThanOrEqual(specs.Forecast_MaxBack, 120) } = double.empty(1, 0)
    specs.Forecast_Exclude { validate.mustBeScalarOrEmpty, mustBeInteger, mustBeGreaterThanOrEqual(specs.Forecast_Exclude, 0), mustBeLessThanOrEqual(specs.Forecast_Exclude, 100) } = double.empty(1, 0) % 0 to 100
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
    specs.Regression_PVAicTest { validate.mustBeScalarOrEmpty, mustBeNumeric, mustBeGreaterThanOrEqual(specs.Regression_PVAicTest, 0), mustBeLessThanOrEqual(specs.Regression_PVAicTest, 1) } = double.empty(1, 0) 
    specs.Regression_TLimit { validate.mustBeScalarOrEmpty, mustBeNumeric } = double.empty(1, 0)
    specs.Regression_Chi2Test logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Regression_Chi2TestCV { validate.mustBeScalarOrEmpty, mustBeNumeric, mustBeGreaterThanOrEqual(specs.Regression_Chi2TestCV, 0), mustBeLessThanOrEqual(specs.Regression_Chi2TestCV, 1) } = double.empty(1, 0) 
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
    specs.X11Regression_TDPrior (1, :) { mustBeNumeric, mustBeNonnegative, local_validateTDPrior(specs.X11Regression_TDPrior) } = double.empty(1, 0)
    specs.X11Regression_Prior logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.X11Regression_Span (1, :) { local_validateSpan(specs.X11Regression_Span) } = double.empty(1, 0)
    specs.X11Regression_Sigma { validate.mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.X11Regression_Critical { validate.mustBeScalarOrEmpty, mustBePositive } = double.empty(1, 0)
    specs.X11Regression_OutlierMethod string { local_validateOutlierMethod } = string.empty(1, 0)
    specs.X11Regression_OutlierSpan (1, :) { local_validateSpan(specs.X11Regression_OutlierSpan) } = double.empty(1, 0)
    specs.X11Regression_Print (1, :) string = string.empty(1, 0)
    specs.X11Regression_Save (1, :) string = string.empty(1, 0)
    specs.X11Regression_SaveLog (1, :) string = string.empty(1, 0)

    specs.Seats logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_AppendFcst logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_HpCycle logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_NoAdmiss logical { validate.mustBeScalarOrEmpty } = logical.empty(1, 0)
    specs.Seats_QMax { validate.mustBeScalarOrEmpty, mustBeNonnegative } = double.empty(1, 0)
    specs.Seats_RMod { validate.mustBeScalarOrEmpty, mustBeNonnegative } = double.empty(1, 0) % 0 to 1
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


% <=R2019a
%{
function varargout = season(inputSeries, range, varargin)

try, range;
    catch, range = Inf; end

persistent ip
if isempty(ip)
    ip = inputParser();

    addParameter(ip, "Output", "d11");
    addParameter(ip, "Display", false);
    addParameter(ip, "Cleanup", true);

    addParameter(ip, "Series_Title", string.empty(1, 0));
    addParameter(ip, "Series_Span", double.empty(1, 0));
    addParameter(ip, "Series_ModelSpan", double.empty(1, 0));
    addParameter(ip, "Series_Precision", 5);
    addParameter(ip, "Series_Decimals", 5);
    addParameter(ip, "Series_CompType", string.empty(1, 0));
    addParameter(ip, "Series_CompWeight", double.empty(1, 0));
    addParameter(ip, "Series_AppendBcst", logical.empty(1, 0));
    addParameter(ip, "Series_AppendFcst", logical.empty(1, 0));
    addParameter(ip, "Series_Type", string.empty(1, 0));
    addParameter(ip, "Series_Save", string.empty(1, 0));

    addParameter(ip, "X11_Mode", @auto % string.empty(1, 0));
    addParameter(ip, "X11_SeasonalMA", string.empty(1, 0));
    addParameter(ip, "X11_TrendMA", double.empty(1, 0));
    addParameter(ip, "X11_SigmaLim", double.empty(1, 0));
    addParameter(ip, "X11_Title", string.empty(1, 0));
    addParameter(ip, "X11_AppendFcst", logical.empty(1, 0));
    addParameter(ip, "X11_AppendBcst", logical.empty(1, 0));
    addParameter(ip, "X11_Final", string.empty(1, 0));
    addParameter(ip, "X11_Print", string.empty(1, 0));
    addParameter(ip, "X11_Save", string.empty(1, 0));
    addParameter(ip, "X11_SaveLog", string.empty(1, 0));

    addParameter(ip, "Transform", logical.empty(1, 0));
    addParameter(ip, "Transform_Function", string.empty(1, 0));
    addParameter(ip, "Transform_Power", double.empty(1, 0));
    addParameter(ip, "Transform_Adjust", string.empty(1, 0));
    addParameter(ip, "Transform_Title", string.empty(1, 0));
    addParameter(ip, "Transform_AicDiff", double.empty(1, 0));
    addParameter(ip, "Transform_Print", string.empty(1, 0));
    addParameter(ip, "Transform_Save", string.empty(1, 0));
    addParameter(ip, "Transform_SaveLog", string.empty(1, 0));

    addParameter(ip, "Estimate", logical.empty(1, 0));
    addParameter(ip, "Estimate_Tol", double.empty(1, 0));
    addParameter(ip, "Estimate_MaxIter", double.empty(1, 0));
    addParameter(ip, "Estimate_Exact", string.empty(1, 0));
    addParameter(ip, "Estimate_OutOfSample", logical.empty(1, 0));
    addParameter(ip, "Estimate_Print", string.empty(1, 0));
    addParameter(ip, "Estimate_Save", string.empty(1, 0));
    addParameter(ip, "Estimate_SaveLog", string.empty(1, 0));

    addParameter(ip, "Automdl", logical.empty(1, 0));
    addParameter(ip, "Automdl_MaxOrder", double.empty(1, 0));
    addParameter(ip, "Automdl_MaxDiff", double.empty(1, 0));
    addParameter(ip, "Automdl_Diff", double.empty(1, 0));
    addParameter(ip, "Automdl_AcceptDefault", logical.empty(1, 0));
    addParameter(ip, "Automdl_CheckMu", logical.empty(1, 0));
    addParameter(ip, "Automdl_LjungBoxLimit", double.empty(1, 0));
    addParameter(ip, "Automdl_Mixed", logical.empty(1, 0));
    addParameter(ip, "Automdl_Print", string.empty(1, 0));
    addParameter(ip, "Automdl_SaveLog", string.empty(1, 0));

    addParameter(ip, "Arima", logical.empty(1, 0));
    addParameter(ip, "Arima_Model", string.empty(1, 0));
    addParameter(ip, "Arima_AR", double.empty(1, 0));
    addParameter(ip, "Arima_MA", double.empty(1, 0));
    addParameter(ip, "Arima_Title", string.empty(1, 0));

    addParameter(ip, "Force", logical.empty(1, 0));
    addParameter(ip, "Force_Type", string.empty(1, 0));
    addParameter(ip, "Force_Lambda", double.empty(1, 0));
    addParameter(ip, "Force_Rho", double.empty(1, 0));
    addParameter(ip, "Force_Round", logical.empty(1, 0));
    addParameter(ip, "Force_Start", double.empty(1, 0));
    addParameter(ip, "Force_Target", string.empty(1, 0));
    addParameter(ip, "Force_UseFcst", logical.empty(1, 0));
    addParameter(ip, "Force_Print", string.empty(1, 0));
    addParameter(ip, "Force_Save", string.empty(1, 0));

    addParameter(ip, "Forecast", logical.empty(1, 0));
    addParameter(ip, "Forecast_MaxLead", double.empty(1, 0) % 0 to 120);
    addParameter(ip, "Forecast_MaxBack", double.empty(1, 0) % 0 to 120);
    addParameter(ip, "Forecast_Exclude", double.empty(1, 0) % 0 to 1000);
    addParameter(ip, "Forecast_LogNormal", logical.empty(1, 0));
    addParameter(ip, "Forecast_Print", string.empty(1, 0));
    addParameter(ip, "Forecast_Save", string.empty(1, 0));

    addParameter(ip, "Regression", logical.empty(1, 0));
    addParameter(ip, "Regression_Variables", string.empty(1, 0));
    addParameter(ip, "Regression_TestAllEaster", logical.empty(1, 0));
    addParameter(ip, "Regression_Data", Series.empty(0));
    addParameter(ip, "Regression_User", string.empty(1, 0));
    addParameter(ip, "Regression_UserType", string.empty(1, 0));
    addParameter(ip, "Regression_AicTest", string.empty(1, 0));
    addParameter(ip, "Regression_AicDiff", double.empty(1, 0));
    addParameter(ip, "Regression_PVAicTest", double.empty(1, 0) % 0 to 1);
    addParameter(ip, "Regression_TLimit", double.empty(1, 0));
    addParameter(ip, "Regression_Chi2Test", logical.empty(1, 0));
    addParameter(ip, "Regression_Chi2TestCV", double.empty(1, 0) % 0 to 1);
    addParameter(ip, "Regression_Print", string.empty(1, 0));
    addParameter(ip, "Regression_Save", string.empty(1, 0));
    addParameter(ip, "Regression_SaveLog", string.empty(1, 0));

    addParameter(ip, "X11Regression", logical.empty(1, 0));
    addParameter(ip, "X11Regression_Variables", string.empty(1, 0));
    addParameter(ip, "X11Regression_Data", Series.empty(0));
    addParameter(ip, "X11Regression_User", string.empty(1, 0));
    addParameter(ip, "X11Regression_UserType", string.empty(1, 0));
    addParameter(ip, "X11Regression_AicTest", string.empty(1, 0));
    addParameter(ip, "X11Regression_AicDiff", double.empty(1, 0));
    addParameter(ip, "X11Regression_TDPrior", double.empty(1, 0));
    addParameter(ip, "X11Regression_Prior", logical.empty(1, 0));
    addParameter(ip, "X11Regression_Span", double.empty(1, 0));
    addParameter(ip, "X11Regression_Sigma", double.empty(1, 0));
    addParameter(ip, "X11Regression_Critical", double.empty(1, 0));
    addParameter(ip, "X11Regression_OutlierMethod", string.empty(1, 0));
    addParameter(ip, "X11Regression_OutlierSpan", double.empty(1, 0));
    addParameter(ip, "X11Regression_Print", string.empty(1, 0));
    addParameter(ip, "X11Regression_Save", string.empty(1, 0));
    addParameter(ip, "X11Regression_SaveLog", string.empty(1, 0));

    addParameter(ip, "Seats", logical.empty(1, 0));
    addParameter(ip, "Seats_AppendFcst", logical.empty(1, 0));
    addParameter(ip, "Seats_HpCycle", logical.empty(1, 0));
    addParameter(ip, "Seats_NoAdmiss", logical.empty(1, 0));
    addParameter(ip, "Seats_QMax", double.empty(1, 0));
    addParameter(ip, "Seats_RMod", double.empty(1, 0) % 0 to 1
    addParameter(ip, "Seats_Out", double.empty(1, 0));
    addParameter(ip, "Seats_StatSeas", logical.empty(1, 0));
    addParameter(ip, "Seats_TabTables", string.empty(1, 0));
    addParameter(ip, "Seats_PrintPhtrf", double.empty(1, 0));
    addParameter(ip, "Seats_Print", string.empty(1, 0));
    addParameter(ip, "Seats_Save", string.empty(1, 0));
    addParameter(ip, "Seats_SaveLog", string.empty(1, 0));
end
parse(ip, varargin{:});
opt = ip.Results;
specs = rmfield(opt, ["Output", "Display", "Cleanup"]);
%}
% <=R2019a


if ~isequal(range, Inf)
    [from, to] = resolveRange(inputSeries, range);
    inputSeries = clip(inputSeries, from, to);
end

outputTables = x13.resolveOutputTables(opt.Output);
specs = local_writeOutputTablesToSpecs(specs, outputTables);

numOutputTables = numel(outputTables);

sizeData = size(inputSeries);
numColumns = prod(sizeData(2:end));

outputData = cell(numColumns, numOutputTables); 
outputInfo = [];
inxError = false(1, numColumns);

specs = local_removeEmptySpecs(specs);
x13.checkSpecsConflicts(specs);
specs = local_resolveDataAttributes(specs);
specs = local_requestArimaForSeats(specs);

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
    [specs__, flipSign__] = local_resolveAutoMode(data__, specs__);
    data__ = flipSign__*data__;
    data__ = local_adjustDataForNaNs(data__);
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
    % Run the X13 exectuable on the code, and capture the output files
    %
    [info__.Path, info__.Message] = x13.run(specsCode__, info__);
    if opt.Display
        disp(info__.Message);
    end

    [info__.OutputFiles, cleanup] = x13.captureOutputFiles(info__.Path);
    if opt.Cleanup
        for n = cleanup
            delete(n);
        end
    end


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

function specs = local_writeOutputTablesToSpecs(specs, outputTables)
    prefixes = extractBefore(outputTables, "_");
    attributes = extractAfter(outputTables, "_");
    for i = 1 : numel(outputTables)
        specs.(prefixes(i) + "_Save")(end+1) = attributes(i); 
    end
end%


function [specs, flipSign] = local_resolveAutoMode(data, specs)
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


function specs = local_removeEmptySpecs(specs)
    specsNames = reshape(string(fieldnames(specs)), 1, [ ]);
    inxRemove = structfun(@isempty, specs);
    specs = rmfield(specs, specsNames(inxRemove));
end%


function specs = local_resolveDataAttributes(specs)
    specsNames = reshape(string(fieldnames(specs)), 1, [ ]);
    inxData = endsWith(specsNames, "_Data");
    if ~any(inxData)
        return
    end
    invalidDataSpecs = string.empty(1, 0);
    for n = specsNames(inxData)
        prefix = extractBefore(n, "_");
        series = specs.(n);
        if ~isa(series, 'Series')
            invalidDataSpecs(end+1) = n; %#ok<AGROW>
            continue
        end
        specs.(n) = local_adjustDataForNaNs(series.Data);
        specs.(prefix + "_Start") = series.StartAsNumeric;
    end

    if ~isempty(invalidDataSpecs)
        exception.error([
            "X13:InvalidDataSpecs"
            "This data specs needs to be assigned a time series object: %s "
        ], invalidDataSpecs);
    end
end%


function data = local_adjustDataForNaNs(data)
    standin = -99999;
    data(data==standin) = standin - 0.01;
    data(~isfinite(data)) = standin;
end%

function specs = local_requestArimaForSeats(specs)
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

function local_validateInputSeries(x)
    if any(x.FrequencyAsNumeric==[2, 4, 6, 12])
        return
    end
    error("Local:Validator", "Invalid date frequency of the input time series.");
end%


function local_validateX11Mode(x)
    if isequal(x, @auto)
        return
    end
    mustBeMember(x, ["add", "mult", "pseudoadd", "logadd"]);
end%


function local_validateTDPrior(x)
    if isempty(x) || numel(x)==7
        return
    end
    error("Local:Validator", "X11Regression_TDPrior must be a 1-by-7 vector of non-negative numbers.");
end%


function local_validateSpan(x)
    if isempty(x) 
        return
    end
    if isnumeric(x) && numel(x)==2
        return
    end
    error("Local:Validator", "Time span must be a 1-by-2 vector of dates.");
end%


function local_validatePrecision(x)
    %(
    if isnumeric(x) && isscalar(x) && any(x==[0, 1, 2, 3, 4, 5])
        return
    end
    error("Input value must be 0, 1, 2, 3, 4, or 5.");
    %)
end%

function local_validateCompType(x)
    %(
    if isstring(x) && isempty(x)
        return
    end
    if isstring(x) && isscalar(x) && any(x==["add", "sub", "mult", "div", "none"])
        return
    end
    error("Input value must be empty or one of {""add"", ""sub"", ""mult"", ""div"", ""none""}.");
    %)
end%


function local_validateSeriesType(x)
    %(
    if isempty(x)
        return
    end
    if isstring(x) && isscalar(x) && any(x==["stock", "flow"])
        return
    end
    error("Input value must be empty or one of {""stock"", ""flow""}.");
    %)
end%


function local_validateTrendMA(x)
    %(
    if isempty(x)
        return
    end
    if isnumeric(x) && isscalar(x) && isinteger(x) && x>=3 && x<=101
        return
    end
    error("Input value must be an integer between 3 and 101.");
    %)
end%


function local_validateFunction(x)
    %(
    if isempty(x)
        return
    end
    if isstring(x) && isscalar(x) && any(x==["auto", "log", "sqrt", "inverse", "logistic", "none"])
        return
    end
    error("Input value must be one of {""auto"", ""log"", ""sqrt"", ""inverse"", ""logistic"", ""none""}.");
    %)
end%


function local_validateAdjust(x)
    %(
    if isempty(x)
        return
    end
    if isstring(x) && isscalar(x) && any(x==["lom", "loq", "lpyear"])
        return
    end
    error("Input value must be one of {""lom"", ""loq"", ""lpyear""}.");
    %)
end%


function local_validateExact(x)
    %(
    if isempty(x)
        return
    end
    if isstring(x) && isscalar(x) && any(x==["arma", "ma", "none"])
        return
    end
    error("Input value must be one of {""arma"", ""ma"", ""none""}.");
    %)
end%


function local_validateForceType(x)
    %(
    if isempty(x)
        return
    end
    if isstring(x) && isscalar(x) && any(x==["none", "regress", "denton"])
        return
    end
    error("Input value must be one of {""none"", ""regress"", ""denton""}.");
    %)
end%


function local_validateForceLambda(x)
    %(
    if isempty(x)
        return
    end
    if isnumeric(x) && isscalar(x) && x>=-3 && x<=3
        return
    end
    error("Input value must be a number between -3 and 3.");
    %)
end%


function local_validateForceRho(x)
    %(
    if isempty(x)
        return
    end
    if isnumeric(x) && isscalar(x) && x>=0 && x<=1
        return
    end
    error("Input value must be a number between 0 and 1.");
    %)
end%


function local_validateForceTarget(x)
    %(
    if isempty(x)
        return
    end
    if isstring(x) && isscalar(x) && any(x==["original", "caladjust", "permprioradj", "both"])
        return
    end
    error("Input value must be one of {""original"", ""caladjust"", ""permprioradj"", ""both""}.");
    %)
end%


function local_validateOutlierMethod(x)
    %(
    if isempty(x)
        return
    end
    if isstring(x) && isscalar(x) && any(x==["addone", "adddall"])
        return
    end
    error("Input value must be one of {""addone"", ""addall""}.");
    %)
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

if ~verLessThan('matlab', '9.9')
    sa = x13.season(d.x);
    assertClass(testCase, sa, "Series");
    assertEqual(testCase, sa.StartAsNumeric, d.x.StartAsNumeric, "AbsTol", 1e-10);
    assertEqual(testCase, sa.EndAsNumeric, d.x.EndAsNumeric, "AbsTol", 1e-10);
end


%% Test Multiple Outputs

if ~verLessThan('matlab', '9.9')
    [sa, sf, tc, ir, info] = x13.season( ...
        d.x ...
        , "Output", ["d11", "d10", "d12", "d13", "fct"] ...
        , "X11_Mode", "add" ...
    );
    assertEqual(testCase, getData(d.x, Inf), getData(sf+tc+ir, Inf), "AbsTol", 1e-10);
end


%% Test Multiple Inputs

if ~verLessThan('matlab', '9.9')
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

if ~verLessThan('matlab', '9.9')
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

if ~verLessThan('matlab', '9.9')
    [fct, info] = x13.season( ...
        d.x ...
        , "Output", "fct" ...
        , "Automdl", true ...
        , "Forecast_MaxLead", 24 ...
    );
    %
    assertSize(testCase, fct, [24, 1]);
    %
    [fct, bct, info] = x13.season( ...
        [d.x, d.y, d.z] ...
        , "Output", ["fct", "bct"] ...
        , "Automdl", true ...
        , "Forecast_MaxLead", 24 ...
    );
    %
    assertSize(testCase, fct, [30, 3]);
    assertSize(testCase, bct, [0, 3]);
end


%% Test Backcast

if ~verLessThan('matlab', '9.9')
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

if ~verLessThan('matlab', '9.9')
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

if ~verLessThan('matlab', '9.9')
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
