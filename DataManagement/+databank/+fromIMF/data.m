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

