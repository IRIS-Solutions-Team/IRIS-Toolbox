function [outputDb, status, info] = fromFred(fredSeriesId, varargin)

exception.warning([
    "Deprecated"
    "Function databank.fromFred is obsolete and will be removed from IrisT in the future. "
    "Use databank.fromFred.data and databank.fromFred.vintages."
]);

FRED_API_KEY = databank.fromFred.Config.Key;
REQUEST = "?series_id=%s&api_key=%s&file_type=json";
FREQUENCY_CONVERSION = "&frequency=%s&aggregation_method=%s";
VINTAGE = "&vintage_dates=%s";

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.fromFred');
    pp.KeepUnmatched = true;
    addRequired(pp,  'fredSeriesId', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));

    addParameter(pp, 'AddToDatabank', [ ], @(x) isequal(x, [ ]) || validate.databank(x));
    addParameter(pp, "AggregationMethod", "avg", @(x) validate.anyString(x, ["avg", "sum", "eop"]));
    addParameter(pp, 'Frequency', '', @locallyValidateFrequency);
    addParameter(pp, 'MaxRequestAttempts', 3, @(x) validate.numericScalar(x, 1, Inf));
    addParameter(pp, 'OutputType', @auto, @(x) isequal(x, @auto) || validate.databankType(x));
    addParameter(pp, 'Progress', false, @validate.logicalScalar);
    addParameter(pp, 'Request', "Observations", @(x) startsWith(x, ["Observation", "Vintage"], "IgnoreCase", true));
    addParameter(pp, {'Vintage', 'Vintages', 'VintageDate', 'VintageDates'}, "", @(x) isempty(x) || isstring(x) || ischar(x) || iscellstr(x) || isnumeric(x));
    addParameter(pp, 'URL', "https://api.stlouisfed.org/fred", @(x) validate.stringScalar(x) && strlength(x)>0);
end
%)
opt = parse(pp, fredSeriesId, varargin{:});

outputDb = databank.backend.ensureTypeConsistency( ...
    opt.AddToDatabank, opt.OutputType ...
);

opt.Request = string(opt.Request);
if startsWith(opt.Request, "Observation", "IgnoreCase", true)
    if isempty(opt.Vintage)
        opt.Vintage = "";
    elseif isnumeric(opt.Vintage)
        opt.Vintage = dater.toIsoString(opt.Vintage);
    else
        opt.Vintage = string(opt.Vintage);
    end
else
    opt.Vintage = "";
end

opt.URL = string(opt.URL);
if ~endsWith(opt.URL, "/")
    opt.URL = opt.URL + "/";
end
URL_INFO = opt.URL + "series";
URL_OBSERVATIONS = opt.URL + "series/observations";
URL_VINTAGE_DATES = opt.URL + "series/vintagedates";

opt.AggregationMethod = strip(string(opt.AggregationMethod));

%--------------------------------------------------------------------------

numVintages = numel(opt.Vintage);

if isnumeric(opt.Frequency)
    opt.Frequency = Frequency.toFredLetter(opt.Frequency);
else
    opt.Frequency = strip(string(opt.Frequency));
end
if opt.Frequency~=""
    opt.Frequency = extractBetween(opt.Frequency, 1, 1);
    FREQUENCY_CONVERSION = sprintf( ...
        FREQUENCY_CONVERSION, lower(opt.Frequency), lower(opt.AggregationMethod) ...
    );
    REQUEST = REQUEST + FREQUENCY_CONVERSION;
end

fredSeriesId = string(fredSeriesId);
numSeries = numel(fredSeriesId);

responseError = string.empty(1, 0);
dataError = string.empty(1, 0);
countAttempts = double.empty(1, 0);

if opt.Progress
    if startsWith(opt.Request, "Observation", "IgnoreCase", true)
        numRuns = numSeries * numVintages;
    else
        numRuns = numSeries;
    end
    progress = ProgressBar('[IrisToolbox] +databank/fromFred Progress', numRuns);
end


% /////////////////////////////////////////////////////////////////////////
for i = 1 : numSeries
    fredSeriesId__ = fredSeriesId(i);
    matches = regexp(fredSeriesId__, '\w+', 'match');
    if numel(matches)==1
        databankName__ = string(matches{1});
        fredSeriesId__ = string(matches{1});
    else
        databankName__ = string(matches{2});
        fredSeriesId__ = string(matches{1});
    end

    if startsWith(opt.Request, "Observation", "IgnoreCase", true)
        if opt.Vintage=="*"
            [opt.Vintage, responseError__, dataError__, countAttempts(end+1)] = hereRequestVintageDates( );
            if ~isempty(responseError__)
                responseError(end+1) = responseError__;
                continue
            end
            if ~isempty(dataError__)
                dataError(end+1) = dataError__;
                continue
            end
        end

        x = [ ];
        count = 0;
        for v = opt.Vintage
            [x__, responseError__, dataError__] = hereRequestObservations( );
            if ~isempty(responseError__)
                responseError(end+1) = responseError__;
                break
            end
            if ~isempty(dataError__)
                dataError(end+1) = dataError__;
                break
            end
            x = [x, x__];
            count = count + 1;
            if opt.Progress
                increment(progress);
            end
        end
        if opt.Vintage~=""
            x = assignUserData(x, "Vintages", opt.Vintage);
        end
    else
        [x, responseError__, dataError__] = hereRequestVintageDates( );
        if ~isempty(responseError__)
            responseError(end+1) = responseError__;
            continue
        end
        if ~isempty(dataError__)
            dataError(end+1) = dataError__;
            continue
        end
        if opt.Progress
            increment(progress);
        end
    end

    if isempty(responseError__) && isempty(dataError__)
        outputDb.(databankName__) = x;
    end
end
% /////////////////////////////////////////////////////////////////////////


if ~isempty(responseError)
    hereReportResponseError( );
end
if ~isempty(dataError)
    hereReportDataError( );
end

status = isempty(responseError) && isempty(dataError);
info = struct( );
info.CountAttempts = countAttempts;

return

    function hereReportResponseError( )
        %(
        if opt.Progress
            done(progress);
        end
        thisError = [
            "Databank:NoResponseFromFred"
            "Request for this series did not receive a valid response from Fred: %s "
        ];
        throw(exception.Base(thisError, 'error'), responseError);
        %)
    end%


    function hereReportDataError( )
        %(
        if opt.Progress
            done(progress);
        end
        thisError = [
            "Databank:NoResponseFromFred"
            "Invalid data from the Fred response to the request for this series: %s "
        ];
        throw(exception.Base(thisError, 'error'), dataError);
        %)
    end%


    function [output, responseError, dataError] = hereRequestObservations( )
        %(
        output = [ ];
        responseError = string.empty(1, 0);
        dataError = string.empty(1, 0);

        errorItem = fredSeriesId__;
        if v~=""
            errorItem = "[Vintage:" + v + "] " + errorItem;
        end

        request__ = sprintf(REQUEST, fredSeriesId__, FRED_API_KEY);
        if strlength(v)>0
            request__ = request__ + sprintf(VINTAGE, v);
        end
        countAttempts = 1;
        success = false;
        while countAttempts<=opt.MaxRequestAttempts
            countAttempts = countAttempts + 1;
            try
                jsonInfo = webread(URL_INFO + request__);
                jsonData = webread(URL_OBSERVATIONS + request__);
                success = true;
                break
            end
        end
        if ~success
            responseError = errorItem;
            return
        end

        try
            output = locallyExtractDataFromJson(jsonInfo, jsonData, v, opt);
        catch
            dataError = errorItem;
            return
        end
        %)
    end%


    function [vintageDates, responseError, dataError, countAttempts] = hereRequestVintageDates( )
        %(
        vintageDates = [ ];
        responseError = string.empty(1, 0);
        dataError = string.empty(1, 0);

        request__ = sprintf(REQUEST, fredSeriesId__, FRED_API_KEY);
        countAttempts = 1;
        success = false;
        while countAttempts<=opt.MaxRequestAttempts
            countAttempts = countAttempts + 1;
            try
                jsonVintages = webread(URL_VINTAGE_DATES + request__);
                success = true;
                break
            end
        end
        if ~success
            responseError = "[Vintage Request] " + fredSeriesId__;
            return
        end

        try
            vintageDates = reshape(string(jsonVintages.vintage_dates), 1, [ ]);
        catch
            dataError = "[Vintage Request] " + fredSeriesId__;
            return
        end
        %)
    end%
end%

%
% Local Functions
%

function outputSeries = locallyExtractDataFromJson(jsonInfo, jsonData, vintage, opt)
    %(
    freq = locallyGetFrequencyFromJsonInfo(jsonInfo, opt);
    dates = dater.fromIsoString(freq, {jsonData.observations.date});
    numPeriods = numel(jsonData.observations);
    values = nan(numPeriods, 1);
    for i = 1 : numPeriods
        value__ = sscanf(jsonData.observations(i).value, "%g");
        if isnumeric(value__) && numel(value__)==1
            values(i) = value__;
        end
    end
    comment = string(jsonInfo.seriess.title);
    if strlength(vintage)>0
        comment = "[Vintage:" + vintage + "] " + comment;
    end
    outputSeries = Series( ...
        dates, values, comment, jsonInfo.seriess, "--skip" ...
    );
    %)
end%


function freq = locallyGetFrequencyFromJsonInfo(jsonInfo, opt)
    %(
    if opt.Frequency~=""
        frequencyLetter = opt.Frequency;
    else
        frequencyLetter = jsonInfo.seriess.frequency_short;
    end
    frequencyLetter = lower(string(frequencyLetter));
    switch frequencyLetter
        case "m" 
            freq = Frequency.MONTHLY;
        case "q"
            freq = Frequency.QUARTERLY;
        case "sa"
            freq = Frequency.HALFYEARLY;
        case "a"
            freq = Frequency.YEARLY;
        case "d"
            freq = Frequency.DAILY;
        otherwise
            throw(exception.Base('Databank:CannotDetermineFrequencyFromJson', 'error'));
    end
    %)
end%


function flag = locallyValidateFrequency(input)
    %(
    FREQUENCIES_ALLOWED = [ 
        Frequency.YEARLY
        Frequency.HALFYEARLY
        Frequency.QUARTERLY
        Frequency.MONTHLY
    ];
    if isempty(input)
        flag = true;
        return
    end
    if isnumeric(input) && any(input==FREQUENCIES_ALLOWED)
        flag = true;
        return
    end
    if any(upper(input)==["M", "Q", "SA", "A"])
        flag = true;
        return
    end
    flag = false;
    %)
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=databank/fromFredUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up Once


%% Test Plain Vanilla

    db = databank.fromFred(["GDPC1", "PCE"]);
    assertEqual(testCase, sort(keys(db)), sort(["GDPC1", "PCE"]));
    assertEqual(testCase, db.GDPC1.Frequency, Frequency.QUARTERLY);
    assertEqual(testCase, db.PCE.Frequency, Frequency.MONTHLY);

    db = databank.fromFred(["GDPC1", "PCE"], "Frequency", "Q");
    assertEqual(testCase, db.GDPC1.Frequency, Frequency.QUARTERLY);
    assertEqual(testCase, db.PCE.Frequency, Frequency.QUARTERLY);

    db = databank.fromFred(["GDPC1->gdp", "PCE->pc"]);
    assertEqual(testCase, sort(keys(db)), sort(["gdp", "pc"]));


%% Test Alias

    db = databank.fromFred(["GDPC1->gdp", "TB3MS->r3m"]);
    assertEqual(testCase, sort(keys(db)), sort(["gdp", "r3m"]));


%% Test Vintage Dates

    db = databank.fromFred( ...
        "GDPC1", "Vintage", ["2001-09-11", "2019-12-30", "2019-12-31"] ...
    );
    assertEqual(testCase, db.GDPC1(:, 2), db.GDPC1(:, 3));


%% Test All Vintages

    v = databank.fromFred(["GDPC1", "TB3MS"], "Request", "VintageDates");

    db = databank.fromFred("GDPC1", "Vintage", v.GDPC1(end-5:end));
    assertEqual(testCase, size(db.GDPC1, 2), 6);
    assertTrue(testCase, all(startsWith(string(db.GDPC1.Comment), "[Vintage:")));

    db = databank.fromFred("TB3MS", "Vintage", v.TB3MS(end-5:end));
    assertEqual(testCase, size(db.TB3MS, 2), 6);
    assertTrue(testCase, all(startsWith(string(db.TB3MS.Comment), "[Vintage:")));


%% Test AddToDatabank

    db1 = databank.fromFred(["GDPC1", "TB3MS"]);
    db2 = databank.fromFred("GDPC1");
    db2 = databank.fromFred("TB3MS", "AddToDatabank", db2);
    assertEqual(testCase, sort(keys(db1)), sort(keys(db2)));
    for k = keys(db1)
        assertEqual(testCase, db1.(k).Data, db2.(k).Data);
    end


%% Test Progress Bar

    vintages = ["2001-09-11", "2005-11-15", "2007-05-31", "2008-09-15", "2011-03-09"];
    db = databank.fromFred(["GDPC1", "TB3MS"], "Vintage", vintages, "Progress", true);


##### SOURCE END #####
%}

