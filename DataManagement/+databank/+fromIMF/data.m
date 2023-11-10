%{
% 
% # `databank.fromIMF.data`
% 
% {== Download databank of time series from IMF Data Portal ==}
% 
% 
% ## Syntax for plain vanilla requests (most datasets)
% 
%     [outputDb, info] = databank.fromIMF.data(dataset, frequency, areas, indicators, ...)
% 
% 
% ## Syntax for requests that need more dimensions
% 
%     [outputDb, info] = databank.fromIMF.data(dataset, frequency, areas, dimensions, ...)
% 
% 
% ## Input Arguments
% 
% __`dataset`__ [ string ]
% > 
% > IMF dataset ID; only one dataset is allowed in one data request.
% > 
% 
% __`frequency`__ [ Frequency ]
% > 
% > Date frequency for the output time series; the `frequency` must be
% > yearly, quarterly or monthly; only one frequency is allowed in one data
% > request.
% > 
% 
% __`areas`__ [ string ]
% > 
% > List of reference areas for which the output time series will be
% > retrieved; an empty string or emtpy array means all reference areas.
% > 
% 
% __`indicators`__ [ string ]
% > 
% > List of indicators that will be retrieved for each of the `areas`.
% > 
% 
% __`dimensions`__ [ cell ]
% > 
% > Cell array of string arrays; each element of the cell array stands for one
% > particular dimension that needs to be specified in the request (depending
% > on the dataset).
% > 
% 
% __`counter=empty`__ [ string ]
% > 
% > List of counterparty reference areas for which the output time series
% > will be retrieved; counterparty reference areas are needed for only some
% > of the IMF databanks, such as Directions of Trade Statistics (DOT); an
% > empty string or empty array means all counterparty reference areas.
% > 
% 
% ## Output arguments
% 
% __`outputDb`__ [ struct | Dictionary ]
% > 
% > Output databank with time series retrieved from an IMF databank.
% > 
% 
% __`info`__ [ struct ]
% > 
% > Output information struct with the following fields:
% > 
% > * `.Request` - the entire request string (including the URL)
% > 
% > * `.Response` - a JSON struct with the IMF data portal response
% > 
% 
% ## Options for HTTP Request
% 
% 
% __`EndDate=-Inf`__ [ Dater ]
% > 
% > End date for the data requested; `-Inf` means the date of the latest
% > observation for each series.
% > 
% 
% __`StartDate=-Inf`__ [ Dater ]
% > 
% > Start date for the data requested; `-Inf` means the date of the earliest
% > observation for each series.
% > 
% 
% __`URL="http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/"`__ [ string ]
% > 
% > URL for the IMF data portal HTTP request.
% > 
% 
% __`WebOptions=weboptions("Timeout", 9999)`__ [ weboption ]
% > 
% > A weboptions object with HTTP settings.
% > 
% 
% __`WhenEmpty="warning"`__ [ `"error"` | `"warning"` ]
% > 
% > How to report an empty response from the server:
% > 
% > * `"error"` means an error is thrown and the execution of the function
% >   stops;
% > 
% > * `"warning"` means a warning is thrown and an empty databank is return
% >   without interrupting the execution of the function.
% > 
% 
% ## Options for output databank
% 
% __`AddToDatabank=struct()`__ [ struct | Dictionary ]
% > 
% > Add the output time series to this databank.
% > 
% 
% __`ApplyMultiplier=true`__ [ `true` | `false` ]
% > 
% > Apply the unit multiplier to the output time series data, scaling them to
% > basic units (e.g. from millions).
% > 
% 
% ## Options for output time series names
% 
% __`NameFunc=[]`__ [ empty | function_handle ]
% > 
% > Function that will be applied to each time series name before it is
% > stored in the `outputDb`.
% > 
% 
% __`IncludeArea=true`__ [ `true` | `false` ]
% > 
% > Include the respective reference area code as a prefix in the name of
% > each output time series.
% > 
% 
% __`IncludeCounter=true`__ [ `true` | `false` ]
% > 
% > Three-dimensional requests only (with counterparty reference area):
% > Include the respective counterparty reference area code as a suffix in
% > the name of each output time series.
% > 
% 
% __`Separator="_"`__ [ string ]
% > 
% > Separator used in the area prefix and/or the counterparty area suffix in
% > the output time series names.
% > 
% 
% ## Description
% 
% This function returns a databank of time series from the IMF data portal.
% To create a data request, you need to know the IMF dataset code, the
% reference area code(s), the indicator code(s), and for three-dimensional
% requests, also the counterparty reference area code(s).
% 
% Leaving the reference area code, the indicator code or the counterparty
% reference area code empty will return data for all of those that exist in
% that dimension.
% 
% The IMF data portal has bandwith restrictions. Sometimes, requests
% returning larger amounts of data need to be split into smaller, more
% specific requests. Sometimes, the function needs to be called several times
% before an actual data response is returned.
% 
% 
% ## Examples
% 
% ### Plain vanilla three-dimensional requests
% 
% Most of the IMF datasets need three dimensions to be specified: 
% 
% * date frequency (only one single date frequency can be specified)
% * reference area(s)
% * indicator(s)
% 
% From the IMF IFS dataset, retrieve quarterly nominal GDP in localy currency
% for the US:
% 
% ```matlab
% d = databank.fromIMF.data("IFS", Frequency.QUARTERLY, "US", "NGDP_XDC")
% ```
% 
% Retrieve nominal GDP in localy currency for all areas (countries and
% regions) for which this indicator is available:
% 
% ```matlab
% d = databank.fromIMF.data("IFS", Frequency.QUARTERLY, [], "NGDP_XDC")
% ```
% 
% 
% Retrieve all indicators available from the IMF IFS databank for the US; do
% not include the country prefix (here, "US_") in the names of the output
% time series:
% 
% ```matlab
% d = databank.fromIMF.data("IFS", Frequency.QUARTERLY, "US", [], "includeArea", false)
% ```
% 
% ### Multi-dimensional requests
% 
% Some IMF datasets require some extra dimensions; for instance, the IMF
% Directions of Trade Statistics dataset (code `DOT`) needs an extra
% dimension for the counterparty following after the indicator dimension; the
% IMF Government Finance Statistics - Main Aggregates and Balances dataset
% (code `GFSMAB`) needs a government sector dimension and a unit of
% measurement dimension, both preceding the indicator dimension.
% 
% Retrieve yearly exports from US (code `US`) to Euro Area (code `U2`):
% 
% ```matlab
% d = databank.fromIMF.data("DOT", Frequency.YEARLY, "US", {"TXG_FOB_USD", "U2"});
% ```
% 
% From the IMF DOT databank (Directions of Trade Statistics), retrieve
% yearly exports from US to all reported areas:
% 
% ```matlab
% d = databank.fromIMF.data("DOT", Frequency.YEARLY, "US", "TXG_FOB_USD", []);
% ```
% 
%}
% --8<--


% >=R2019b
%{
function [outputDb, info] = data(dataset, freq, areas, items, counters, opt)

arguments
    dataset (1, 1) string
    freq (1, 1) Frequency {local_validateFrequency}
    areas (1, :) string
    items (1, :) 
    counters (1, :) string = string.empty(1, 0)

    opt.AddToDatabank (1, 1) {validate.mustBeDatabank} = struct( )
    opt.StartDate (1, 1) double {local_validateDate(opt.StartDate, freq)} = -Inf
    opt.EndDate (1, 1) double {local_validateDate(opt.EndDate, freq)} = Inf
    opt.URL (1, 1) string = databank.fromIMF.Config.URL + "CompactData/"
    opt.WebOptions = databank.fromIMF.Config.WebOptions
    opt.ApplyMultiplier (1, 1) logical = true
    opt.WhenEmpty (1, 1) string {mustBeMember(opt.WhenEmpty, ["error", "warning", "silent"])} = "warning" 

    opt.IncludeArea (1, 1) logical = true
    opt.IncludeCounter (1, 1) logical = true
    opt.Separator (1, 1) string = "_"
    opt.NameFunc = [ ]
end
%}
% >=R2019b


% <=R2019a
%(
function [outputDb, info] = data(dataset, freq, areas, items, counters, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "AddToDatabank", struct( ));
    addParameter(ip, "StartDate", -Inf);
    addParameter(ip, "EndDate", Inf);
    addParameter(ip, "URL", databank.fromIMF.Config.URL + "CompactData/");
    addParameter(ip, "WebOptions", databank.fromIMF.Config.WebOptions);
    addParameter(ip, "ApplyMultiplier", true);
    addParameter(ip, "WhenEmpty", "warning" );

    addParameter(ip, "IncludeArea", true);
    addParameter(ip, "IncludeCounter", true);
    addParameter(ip, "Separator", "_");
    addParameter(ip, "NameFunc", []);
end
parse(ip, varargin{:});
opt = ip.Results;

try, counters; catch, counters = string.empty(1, 0); end
%)
% <=R2019a


if ~endsWith(opt.URL, "/")
    opt.URL = opt.URL + "/";
end

[areas, areaMap, areasString] = local_createNameMap(areas);

if iscell(items)
    items(cellfun(@isempty, items)) = {""};
    itemsString = cellfun(@(x) join(x, "+"), items);
    itemMap = [];
else
    [items, itemMap, itemsString] = local_createNameMap(items);
end

if isempty(counters) || counters==""
    counters = [];
    counterMap = [];
    countersString = [];
else
    [counters, counterMap, countersString] = local_createNameMap(counters);
end

dimensions = join([Frequency.toIMFLetter(freq), areasString, itemsString, countersString], ".");
request = upper(dataset + "/" + dimensions + "?");

if ~isinf(opt.StartDate) 
    request = request + "&startPeriod=" + Dater.toIMFString(opt.StartDate);
end

if ~isinf(opt.EndDate) 
    request = request + "&endPeriod=" + Dater.toIMFString(opt.EndDate);
end

outputDb = opt.AddToDatabank;

request = opt.URL + request;
response = webread(request, opt.WebOptions);

outputDb = local_createSeriesFromResponse( ...
    outputDb, freq, response, request, areaMap, itemMap, counterMap, opt ...
);

info = struct();
info.Request = request;
info.Response = response;

end%

%
% Local functions
%

function outputDb = local_createSeriesFromResponse(outputDb, freq, response, request, areaMap, itemMap, counterMap, opt)
    %(
    try
        allResponseData = response.CompactData.DataSet.Series;
    catch
        if lower(opt.WhenEmpty)==lower("silent")
            return
        elseif lower(opt.WhenEmpty)==lower("error")
            func = @exception.error;
        else
            func = @exception.warning;
        end
        func([
            "Databank:IMF:Data:NoObservationsReturned"
            "This request did not return any data: %s"
        ], request);
        return
    end

    isDictionary = isa(outputDb, 'Dictionary');
    for i = 1 : numel(allResponseData)
        responseData = hereGetIthReponse( );
        name = hereCreateName( );
        if isstruct(responseData) && isfield(responseData, 'Obs')
            [dates, values] = hereGetDatesValues( );
            series = Series(dates, values, '', rmfield(responseData, 'Obs'), '--skip');
        else
            series = Series();
        end
        if isDictionary
            store(outputDb, name, series);
        else
            if ~isvarname(name)
                name = genvarname(name);
            end
            outputDb.(name) = series;
        end
    end

    return

        function responseData = hereGetIthReponse( )
            if iscell(allResponseData)
                responseData = allResponseData{i};
            else
                responseData = allResponseData(i);
            end
        end%


        function name = hereCreateName( )
            responseFields = textual.stringify(fieldnames(responseData));

            area = string.empty(1, 0);
            if opt.IncludeArea  
                area = string(responseData.x_REF_AREA);
                try
                    area = areaMap.(area);
                end
            end

            %
            % The indicator code for the series is either in x_INDICATOR or
            % x_INDICATOR_CODE
            %
            inx = startsWith(responseFields, "x_INDICATOR");
            if nnz(inx)~=1
                exception.error([
                    "Databank:IMF:Data:InvalidDataStructure"
                    "This request returned invalid data structure: %s"
                ], request);
            end
            item = string(responseData.(responseFields(inx)));

            try
                item = itemMap.(item);
            end

            counter = string.empty(1, 0);
            if opt.IncludeCounter
                try
                    counter = string(responseData.x_COUNTERPART_AREA);
                    try
                        counter = counterMap.(counter);
                    end
                end
            end

            name = join([area, item, counter], opt.Separator); 

            if isa(opt.NameFunc, 'function_handle')
                name = opt.NameFunc(name);
            end
        end%


        function [dates, values] = hereGetDatesValues( )
            multiplier = 1;
            if isfield(responseData, "x_UNIT_MULT")
                multiplier = double(string(responseData.x_UNIT_MULT));
            end
            if isstruct(responseData.Obs)
                % Struct array
                if isfield(responseData.Obs, "x_TIME_PERIOD") && isfield(responseData.Obs, "x_OBS_VALUE")
                    dates = {responseData.Obs.x_TIME_PERIOD};
                    values = {responseData.Obs.x_OBS_VALUE};
                else
                    dates = double.empty(0, 1);
                    values = double.empty(0, 1);
                    return
                end
                if isempty(dates) || isempty(values) || numel(dates)~=numel(values)
                    dates = double.empty(0, 1);
                    values = double.empty(0, 1);
                    return
                end
            else
                % Cell array of structs
                dates = cell.empty(0, 1);
                values = cell.empty(0, 1);
                for obs = reshape(responseData.Obs, 1, [ ])
                    try
                        addDates = obs{:}.x_TIME_PERIOD;
                        addValues = obs{:}.x_OBS_VALUE;
                        if isempty(addDates) || isempty(addValues)
                            continue
                        end
                        dates = [dates; {addDates}];
                        values = [values; {addValues}];
                    end
                end
            end
            dates = Dater.fromIMFString(freq, string(dates));
            values = double(string(values));
            if opt.ApplyMultiplier && multiplier~=1
                values = values * 10^multiplier;
            end
        end%
end%


function [list, map, requestString] = local_createNameMap(list)
    if isempty(list)
        map = list;
        requestString = "";
        return
    end
    map = struct( );
    inx = contains(list, "->");
    if any(inx)
        [inputName, outputName] = textual.split(list(inx), "->");
        inputName = strip(inputName);
        outputName = strip(outputName);
        for i = 1 : numel(inputName)
            map.(inputName(i)) = outputName(i);
        end
        list(inx) = inputName(inx);
    end
    requestString = join(list, "+");
end%

%
% Local Validators
%

function local_validateFrequency(freq)
    %(
    if any(freq==[Frequency.YEARLY, Frequency.QUARTERLY, Frequency.MONTHLY])
        return
    end
    error("Frequency needs to be one of {YEARLY, QUARTERLY, MONTHLY}.");
    %)
end%


function local_validateDate(date, freq)
    %(
    if isinf(date)
        return
    end
    if dater.getFrequency(date)==double(freq)
        return
    end
    error("Options StartDate and EndDate need to be regular dates complying with Frequency.");
    %)
end%

