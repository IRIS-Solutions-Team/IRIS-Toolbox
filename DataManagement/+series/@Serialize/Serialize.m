classdef Serialize ...
    < matlab.mixin.Copyable

    properties
        Name = "Name"
        Dates = "Dates"
        Values = "Values"
        Frequency = "Frequency"
        Comment = "Comment"
        UserData = ""
        StartDateOnly = true
        Format = ""
    end


    methods 
        function outputSeries = decodeSeries(this, inputRecord, name)
            %(
            freq = decodeFrequency(this, inputRecord.(this.Frequency));
            isoDates = reshape(string(inputRecord.(this.Dates)), [ ], 1);
            dates = dater.fromIsoString(freq, isoDates);
            values = reshape(inputRecord.(this.Values), [ ], 1);
            if ~isempty(this.Comment) && ~isequal(this.Comment, false) && isfield(inputRecord, this.Comment)
                comment = inputRecord.(this.Comment);
            else
                comment = name;
            end
            userData = rmfield(inputRecord, [this.Dates, this.Values, this.Frequency]);
            outputSeries = Series(dates, values, comment, userData, "--skip");
            %)
        end%


        function outputRecord = encodeSeries(this, inputSeries, name)
            %(
            outputRecord = struct( );

            if ~isempty(this.Name) && ~isequal(this.Name, false)
                outputRecord.(this.Name) = name;
            end

            if this.StartDateOnly
                outputDate = inputSeries.StartAsNumeric;
            else
                outputDate = reshape(inputSeries.RangeAsNumeric, 1, [ ]);
            end
            if ~isempty(outputDate)
                outputRecord.(this.Dates) = DateWrapper.toIsoString(outputDate);
                if isscalar(outputDate) && ~this.StartDateOnly
                    outputRecord.(this.Dates) = { outputRecord.(this.Dates) };
                end
            else
                outputRecord.(this.Dates) = NaN;
            end
            
            outputRecord.(this.Values) = encodeValues(this, inputSeries.Data);

            outputRecord.(this.Frequency) = this.encodeFrequency(inputSeries.Frequency);
            if ~isequal(this.Comment, false)
                outputRecord.(this.Comment) = inputSeries.Comment;
            end
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


        function outputValues = encodeValues(this, inputData);
            %(
            outputValues = inputData;
            if isa(this.Format, 'function_handle')
                outputValues = this.Format(outputValues);
            elseif ~isequal(this.Format, false) && strlength(this.Format)>0
                outputValues = compose(this.Format, outputValues);
            end
            if isscalar(outputValues)
                outputValues = { outputValues };
            else
                outputValues = reshape(outputValues, 1, [ ]);
            end
            %)
        end%


        function db = encodeDatabank(this, db)
            %(
            for name = keys(db)
                if isa(db, 'Dictionary')
                    x__ = retrieve(db, name);
                else
                    x__ = db.(name);
                end
                if ~isa(x__, 'Series')
                    continue
                end
                x__ = this.encodeSeries(x__, name);
                if isa(db, 'Dictionary')
                    store(db, name, x__);
                else
                    db.(name) = x__;
                end
            end
            %)
        end%


        function db = decodeDatabank(this, db, nameMap)
            %(
            for name = keys(db)
                if isa(db, 'Dictionary')
                    x__ = retrieve(db, name);
                else
                    x__ = db.(name);
                end
                if ~isa(x__, 'struct') ...
                    || ~isfield(x__, this.Name) ...
                    || ~isfield(x__, this.Dates) ...
                    || ~isfield(x__, this.Values) ...
                    || ~isfield(x__, this.Frequency)
                    continue
                end
                x__ = this.decodeSeries(x__, name);
                if isa(db, 'Dictionary')
                    store(db, name, x__);
                else
                    db.(name) = x__;
                end
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

