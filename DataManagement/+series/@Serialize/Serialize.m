classdef Serialize ...
    < matlab.mixin.Copyable

    properties
        Name = "Name"
        Dates = "Dates"
        Values = "Values"
        Frequency = "Frequency"
        UserData = ""
    end


    methods 
        function outputSeries = decodeSeries(this, inputRecord, name)
            %(
            freq = decodeFrequency(this, inputRecord.(this.Frequency));
            isoDates = reshape(string(inputRecord.(this.Dates)), [ ], 1);
            dates = DateWrapper.fromIsoStringAsNumeric(freq, isoDates);
            values = reshape(inputRecord.(this.Values), [ ], 1);
            userData = rmfield(inputRecord, [this.Dates, this.Values, this.Frequency]);
            outputSeries = Series(dates, values, name, userData, "--SkipInputParser");
            %)
        end%


        function outputRecord = encodeSeries(this, inputSeries, name)
            %(
            outputRecord = struct( );
            outputRecord.(this.Name) = name;
            outputRecord.(this.Dates) = reshape(DateWrapper.toIsoString(inputSeries.Range), 1, [ ]);
            outputRecord.(this.Values) = reshape(inputSeries.Data, 1, [ ]);
            outputRecord.(this.Frequency) = this.encodeFrequency(inputSeries.Frequency);
            %
            % There are three options for what to do with UserData
            % * UserData will not be serialized at all (`false`)
            % * UserData will be added as a flat structure to the other fields (`""`)
            % * UserData will be nested within the specified field name (`"fieldName"`)
            %
            if isequal(this.UserData, false)
                return
            elseif isstring(this.UserData) 
                userData = inputSeries.Userdata;
                if strlength(this.UserData)>0
                    outputRecord.(this.UserData) = userData;
                else
                    if ~isempty(userData) && isstruct(userData) 
                        for name = reshape(string(fieldnames(userData)), 1, [ ])
                            if ~isfield(outputRecord, name)
                                outputRecord.(name) = userData.(name);
                            end
                        end
                    end
                end
            end
            %)
        end%


        function db = encodeDatabank(this, db)
            %(
            for name = reshape(string(fieldnames(db)), 1, [ ])
                if ~isa(db.(name), 'Series')
                    continue
                end
                db.(name) = this.encodeSeries(db.(name), name);
            end
            %)
        end%


        function db = decodeDatabank(this, db, nameMap)
            %(
            for name = reshape(string(fieldnames(db)), 1, [ ])
                if ~isa(db.(name), 'struct') ...
                    || ~isfield(db.(name), this.Name) ...
                    || ~isfield(db.(name), this.Dates) ...
                    || ~isfield(db.(name), this.Values) ...
                    || ~isfield(db.(name), this.Frequency)
                    continue
                end
                db.(name) = this.decodeSeries(db.(name), name);
            end
            %)
        end%


        function freq = decodeFrequency(this, freq)
            %(
            if isnumeric(freq)
                freq = Frequency(freq);
                return
            end
            switch upper(string(freq))
                case "I"
                    freq = Frequency.INTEGER;
                case {"A", "Y"}
                    freq = Frequency.YEARLY;
                case "H"
                    freq = Frequency.HALFYEARLY;
                case "Q"
                    freq = Frequency.QUARTERLY;
                case "M"
                    freq = Frequency.MONTHLY;
                case "W"
                    freq = Frequency.WEEKLY;
                case {"D", "B"}
                    freq = Frequency.DAILY;
            end
            %)
        end%


        function freq = encodeFrequency(this, freq)
            %(
            freq = double(freq);
            %)
        end%


        function outputNames = mapNames(this, inputNames, nameMap)
            %(
            if isa(nameMap, 'function_handle')
                outputNames = arrayfun(nameMap, inputNames);
            elseif isstring(nameMap)
                outputNames = nameMap;
            elseif isa(nameMap, 'Dictionary')
                outputNames = inputNames;
                for i = 1 : numel(outputNames)
                    outputNames(i) = retrieve(nameMap, inputNames(i));
                end
            else
                outputNames = inputNames;
            end
            %)
        end%
    end


    methods (Static)
        function jsonStruct = loadJsonAsStruct(fileName)
            %(
            jsonStruct = jsondecode(fileread(fileName));
            %)
        end%


        function saveStructAsJson(jsonStruct, fileName)
            %(
            fid = fopen(fileName, "w+");
            fwrite(fid, string(jsonencode(jsonStruct)));
            fclose(fid);
            %)
        end%
    end
end

