% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function [outputDb, info] = data(dataset, freq, areas, items, counters, options, nameOptions)

% >=R2019b
%(
arguments
    dataset (1, 1) string
    freq (1, 1) Frequency {locallyValidateFrequency}
    areas (1, :) string
    items (1, :) 
    counters (1, :) string = string.empty(1, 0)

    options.AddToDatabank (1, 1) {validate.mustBeDatabank} = struct( )
    options.StartDate (1, 1) double {locallyValidateDate(options.StartDate, freq)} = -Inf
    options.EndDate (1, 1) double {locallyValidateDate(options.EndDate, freq)} = Inf
    options.URL (1, 1) string = databank.fromIMF.Config.URL + "CompactData/"
    options.WebOptions = databank.fromIMF.Config.WebOptions
    options.ApplyMultiplier (1, 1) logical = true

    nameOptions.IncludeArea (1, 1) logical = true
    nameOptions.IncludeCounter (1, 1) logical = true
    nameOptions.Separator (1, 1) string = "_"
    nameOptions.NameFunc = [ ]
end
%)
% >=R2019b

if ~endsWith(options.URL, "/")
    options.URL = options.URL + "/";
end

[areas, areaMap, areasString] = locallyCreateNameMap(areas);

if iscell(items)
    items(cellfun(@isempty, items)) = {""};
    itemsString = cellfun(@(x) join(x, "+"), items);
    itemMap = [];
else
    [items, itemMap, itemsString] = locallyCreateNameMap(items);
end

if isempty(counters) || counters==""
    counters = [];
    counterMap = [];
    countersString = [];
else
    [counters, counterMap, countersString] = locallyCreateNameMap(counters);
end

dimensions = join([Frequency.toIMFLetter(freq), areasString, itemsString, countersString], ".");
request = upper(dataset + "/" + dimensions + "?");

if ~isinf(options.StartDate) 
    request = request + "&startPeriod=" + DateWrapper.toIMFString(options.StartDate);
end

if ~isinf(options.EndDate) 
    request = request + "&endPeriod=" + DateWrapper.toIMFString(options.EndDate);
end

outputDb = options.AddToDatabank;

request = options.URL + request;
response = webread(request, options.WebOptions);

outputDb = locallyCreateSeriesFromResponse( ...
    outputDb, freq, response, request, areaMap, itemMap, counterMap, options, nameOptions ...
);

info = struct( );
info.Request = request;
info.Response = response;

end%

%
% Local Functions
%

function outputDb = locallyCreateSeriesFromResponse(outputDb, freq, response, request, areaMap, itemMap, counterMap, options, nameOptions)
    try
        allResponseData = response.CompactData.DataSet.Series;
    catch
        exception.error([
            "Databank:IMF:Data:NoObservationsReturned"
            "This request did not return any data: %s"
        ], request);
    end

    isDictionary = isa(outputDb, 'Dictionary');
    for i = 1 : numel(allResponseData)
        responseData = hereGetIthReponse( );
        name = hereCreateName( );
        if isstruct(responseData) && isfield(responseData, "Obs")
            [dates, values] = hereGetDatesValues( );
            series = Series(dates, values, "", rmfield(responseData, "Obs"), "--skip");
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
            if nameOptions.IncludeArea  
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
            if nameOptions.IncludeCounter
                try
                    counter = string(responseData.x_COUNTERPART_AREA);
                    try
                        counter = counterMap.(counter);
                    end
                end
            end

            name = join([area, item, counter], nameOptions.Separator); 

            if isa(nameOptions.NameFunc, 'function_handle')
                name = nameOptions.NameFunc(name);
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
            dates = DateWrapper.fromIMFString(freq, string(dates));
            values = double(string(values));
            if options.ApplyMultiplier && multiplier~=1
                values = values * 10^multiplier;
            end
        end%
end%


function [list, map, requestString] = locallyCreateNameMap(list)
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

function locallyValidateFrequency(freq)
    if any(freq==[Frequency.YEARLY, Frequency.QUARTERLY, Frequency.MONTHLY])
        return
    end
    error("Frequency needs to be one of {YEARLY, QUARTERLY, MONTHLY}.");
end%


function locallyValidateDate(date, freq)
    if isinf(date)
        return
    end
    if dater.getFrequency(date)==double(freq)
        return
    end
    error("Options StartDate and EndDate need to be regular dates complying with Frequency.");
end%

