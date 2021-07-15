function [summaryTable, json, info] = datasets(options)

% >=R2019b
%(
arguments
    options.URL (1, 1) string = databank.fromIMF.Config.URL + "DataFlow"
    options.WebOptions = databank.fromIMF.Config.WebOptions
    options.WriteTable (1, 1) string = ""
end
%)
% >=R2019b

[response, request] = databank.fromIMF.Config.request( ...
    options.URL, "", options.WebOptions ...
);

try
    json = response.Structure.Dataflows.Dataflow;
catch
    exception.error([
        "Databank:IMF:InvalidResponse"
        "This request returned no reponse or an invalid response: %s"
    ], request);
end

numDatasets = numel(json);

datasetNames = string.empty(0, 1);
datasetIds = string.empty(0, 1);

for i = 1 : numDatasets
    datasetNames(end+1, 1) = string(json{i}.Name.x_text);
    datasetIds(end+1, 1) = string(json{i}.KeyFamilyRef.KeyFamilyID);
end % for

summaryTable = table(datasetIds, datasetNames);
summaryTable.Properties.VariableNames = {'ID', 'Description'};

if strlength(options.WriteTable)>0
    databank.fromIMF.Config.writeSummaryTable(options.WriteTable, summaryTable);
end

info = struct();
info.Request = request;
info.Response = response;

end%

%
% Local function
%

