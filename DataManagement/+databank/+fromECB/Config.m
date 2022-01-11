classdef Config
    properties (Constant)
        URL (1, 1) string = "https://sdw-wsrest.ecb.europa.eu/service/"
        WebOptions = weboptions("contentType", "auto", "timeOut", 9999)
        Parameters (1, 1) string = ""
    end


    methods (Static)
        function request = createRequest(url, resource, dataset, skeys, params)
            %(
            arguments
                url (1, 1) string
                resource (1, 1) string
                dataset (1, 1) string
                skeys (1, :)
                params (1, 1) struct
            end


            if ~endsWith(url, "/")
                url = url + "/";
            end
            skeys = databank.fromECB.Config.stringifySkeys(skeys);
            params = databank.fromECB.Config.stringifyParameters(params);
            request = url + resource + "/" + dataset + "/" + skeys + "?" + params;
            %)
        end%


        function paramString = stringifyParameters(paramStruct)
            %(
            validParams = [
                "startPeriod"
                "endPeriod"
                "updatedAfter"
                "firstNObservations"
                "lastNObservations"
            ];
            paramString = databank.fromECB.Config.Parameters;
            for n = textual.fields(paramStruct)
                inx = lower(n)==lower(validParams);
                if ~any(inx)
                    continue
                end
                paramString = paramString + "&" + validParams(inx) + string(paramStruct.(n));
            end
            %)
        end%


        function skeyString = stringifySkeys(skeys)
            %(
            if isstring(skeys)
                skeyString = join(skeys, ".");
                return
            end
            if iscell(skeys)
                skeyString = "";
                for s = skeys
                    skeyString = skeyString + "." + join(s{:}, "+");
                end
            end
            if startsWith(skeyString, ".")
                skeyString = extractAfter(skeyString, 1);
            end
            %)
        end%
    end
end
