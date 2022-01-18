function [outputDb, info] = data(dataset, skeys, opt, nameOpt)

arguments
    dataset (1, 1) string
    skeys (1, :) 

    opt.Attributes (1, 1) logical = true
    opt.AddToDatabank = []
    opt.OutputType = "__auto__"
    opt.DimensionSeparator = "_"
    opt.CommentFrom = "TITLE"
    opt.Postprocess = []

    opt.URL (1, 1) string = databank.fromECB.Config.URL
    opt.WebOptions = databank.fromECB.Config.WebOptions

    nameOpt.NameFunc = {}
end

info = struct();

params = struct();
if ~opt.Attributes
    params.detail = "dataonly";
end
info.Request = databank.fromECB.Config.createRequest(opt.URL, "data", dataset, skeys, params);
response = webread(info.Request, opt.WebOptions);
info.Response = jsondecode(response);

outputDb = databank.backend.ensureTypeConsistency( ...
    opt.AddToDatabank, ...
    opt.OutputType ...
);


%
% Parse JSON to output databank
%
[outputDb, info.NamesCreated] = locallyOutputFromResponse(outputDb, info.Response, opt, nameOpt);


%
% Apply postprocess function
%
outputDb = databank.backend.postprocess(outputDb, info.NamesCreated, opt.Postprocess);


end%

%
% Local functions
%

function [db, namesCreated] = locallyOutputFromResponse(db, response, opt, nameOpt)
    %(
    if ~iscell(nameOpt.NameFunc) && ~isempty(nameOpt.NameFunc)
        nameOpt.NameFunc = {nameOpt.NameFunc};
    end

    refDates = reshape(string({response.structure.dimensions.observation.values.id}), [], 1);;
    refDates = dater.fromSdmxString([], refDates);
    if opt.Attributes
        refAttribs = response.structure.attributes.series;
    end
    dimSeries = response.structure.dimensions.series;
    data = response.dataSets.series;
    namesCreated = string.empty(1, 0);
    for raw = textual.fields(data)
        x = data.(raw).observations;
        outputName = locallyDecodeSkey(raw, dimSeries, opt);
        for i = 1 : numel(nameOpt.NameFunc)
            if ~isempty(nameOpt.NameFunc{i})
                outputName = nameOpt.NameFunc{i}(outputName);
            end
        end
        namesCreated = [namesCreated, outputName];
        values = struct2cell(x);
        if isempty(values)
            db.(outputName) = Series();
            continue
        end
        values = [values{:}];
        values = reshape(values(1, :), [], 1);
        dates = locallyDecodeDates(textual.fields(x, [], 1), refDates);
        comment = "";
        userData = [];
        if opt.Attributes
            [comment, userData] = locallyDecodeAttribs(data.(raw).attributes, refAttribs, opt);
        end
        db.(outputName) = Series(dates, values, comment, userData);
    end
    %)
end%


function skey = locallyDecodeSkey(raw, dimSeries, opt)
    %(
    raw = 1 + double(split(extractAfter(raw, 1), "_"));
    skey = "";
    for i = 1 : numel(raw)
        skey = skey + opt.DimensionSeparator + dimSeries(i).values(raw(i)).id;
    end
    skey = extractAfter(skey, opt.DimensionSeparator);
    %)
end%


function dates = locallyDecodeDates(raw, refDates)
    raw = 1 + double(extractAfter(raw, 1));
    dates = refDates(raw);
end%


function [comment, userData] = locallyDecodeAttribs(raw, refAttribs, opt)
    %(
    raw = 1 + raw;
    userData = struct();
    comment = "";
    for i = reshape(find(isfinite(raw)), 1, [])
        id = string(refAttribs(i).id); 
        value = refAttribs(i).values(raw(i)).name;
        if ischar(value)
            value = string(value);
        end
        userData.(id) = value;
        if id==opt.CommentFrom
            comment = string(value);
        end
    end
    %)
end%

