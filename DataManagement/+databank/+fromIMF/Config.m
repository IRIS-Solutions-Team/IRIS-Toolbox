classdef Config
    properties (Constant)
        URL (1, 1) string = "http://dataservices.imf.org/REST/SDMX_JSON.svc/"
        WebOptions = weboptions("timeOut", 9999)
    end


    methods (Static)
        function [response, r] = request(url, query, webOptions)
            arguments
                url (1, 1) string
                query (1, 1) string
                webOptions
            end
            if strlength(query)>0
                if ~endsWith(url, "/")
                    url = url + "/";
                end
            else
                if endsWith(url, "/")
                    url = extractBefore(url, strlength(url));
                end
            end
            r = url + query;
            response = webread(r, webOptions);
        end%


        function fileName = writeSummaryTable(fileName, summaryTable)
            %(
            arguments 
                fileName (1, 1) string
                summaryTable table
            end % arguments


            [filePath, fileTitle, fileExt] = fileparts(fileName);
            if strlength(fileExt)==0
                fileExt = ".xlsx";
            end % if
            fileName = fullfile(filePath, fileTitle+fileExt);
            writetable( ...
                summaryTable, fileName ...
                , "fileType", "spreadsheet" ...
                , "writeMode", "replacefile" ...
                , "sheet", "Summary" ...
            );
            %)
        end%
    end
end
