function [summaryTable, dimTables, json, info] = dimensions(dataset, options)

% >=R2019b
%(
arguments
    dataset (1, 1) string

    options.URL (1, 1) string = databank.fromIMF.Config.URL + "DataStructure/"
    options.WebOptions = databank.fromIMF.Config.WebOptions
    options.WriteTable (1, 1) string = ""
end
%)
% >=R2019b

[response, request] = databank.fromIMF.Config.request( ...
    options.URL, upper(dataset), options.WebOptions ...
);

try
    json = response.Structure.CodeLists.CodeList;
catch
    exception.error([
        "Databank:IMF:InvalidResponse"
        "This request returned no reponse or an invalid response: %s"
    ], request);
end

numDimensions = numel(json);
dimTables = cell(1, numDimensions);

summaryID = string.empty(0, 1);
summaryName = string.empty(0, 1);

for i = 1 : numDimensions
    codes = reshape(string({json{i}.Code(:).x_value}), [], 1);
    descriptions = [json{i}.Code(:).Description];
    descriptions = reshape(string({descriptions.x_text}), [], 1);
    summaryID(end+1, 1) = json{i}.x_id;
    summaryName(end+1, 1) = json{i}.Name.x_text;
    dimTables{i} = table(codes, descriptions);
    dimTables{i}.Properties.Description = json{i}.Name.x_text;
    dimTables{i}.Properties.VariableNames = { 'Code', json{i}.Name.x_text };
end % for

summaryTable = table(summaryID, summaryName);
summaryTable.Properties.VariableNames = {'ID', 'Name'};

if strlength(options.WriteTable)>0
    fileName = databank.fromIMF.Config.writeSummaryTable(options.WriteTable, summaryTable);
    locallyWriteDimTables(fileName, dimTables, json);
end % if

info = struct();
info.Request = request;
info.Response = response;

end%

%
% Local function
%

function locallyWriteDimTables(fileName, dimTables, json)
    %(
    for i = 1 : numel(dimTables)
        writetable( ...
            dimTables{i}, fileName ...
            , "fileType", "spreadsheet" ...
            , "writeMode", "overwritesheet" ...
            , "sheet", json{i}.x_id ...
        );
    end % for
    %)
end%

