classdef Serialize ...
    < matlab.mixin.Copyable

    properties
        Name (1, 1) string = "Name"
        Dates (1, 1) string = "Dates"
        Values (1, 1) string = "Values"
        Frequency (1, 1) string = "Frequency"
        Comment (1, 1) string  = "Comment"
        UserData = ""
        StartDateOnly = true
        Format = ""
        ScalarAsArray = false
        ReadDateFunc = @dater.fromIsoString
        WriteDateFunc = @dater.toIsoString
        WriteFrequencyFunc = @writeFrequency
    end


    methods 
        function outputSeries = seriesFromJson(this, inputRecord, name)
            %(
            if ~isempty(this.Frequency) && strlength(this.Frequency)>0 && isfield(inputRecord, this.Frequency)
                freq = frequencyFromLetter(this, inputRecord.(this.Frequency));
            else
                freq = [];
            end
            dateStrings = reshape(string(inputRecord.(this.Dates)), [ ], 1);
            values = reshape(inputRecord.(this.Values), [ ], 1);
            if ~isempty(dateStrings) && ~isempty(values)
                dates = this.ReadDateFunc(freq, dateStrings);
            else
                dates = double.empty(0, 1);
                values = double.empty(0, 1);
            end
            comment = "";
            if ~isempty(this.Comment) && ~isequal(this.Comment, false) && isfield(inputRecord, this.Comment)
                comment = inputRecord.(this.Comment);
            elseif nargin>=3
                comment = name;
            end
            fieldsToRemove = [this.Dates, this.Values, this.Frequency];
            fieldsToRemove(strlength(fieldsToRemove)==0) = [];
            userData = rmfield(inputRecord, fieldsToRemove);
            outputSeries = Series(dates, values, comment, userData, "--skip");
            %)
        end%


        function outputRecord = jsonFromSeries(this, inputSeries, name)
            %(
            outputRecord = struct( );

            if strlength(this.Name)>0
                if nargin>=3 && ~isempty(name) && strlength(name)>0
                    outputRecord.(this.Name) = char(name);
                else
                    outputRecord.(this.Name) = '';
                end
            end

            if this.StartDateOnly
                outputDate = inputSeries.StartAsNumeric;
            else
                outputDate = reshape(inputSeries.RangeAsNumeric, [ ], 1);
            end

            if ~isempty(inputSeries.Data)
                % Nonempty time series
                if ~isempty(outputDate)
                    outputRecord.(this.Dates) = cellstr(this.WriteDateFunc(outputDate));
                else
                    outputRecord.(this.Dates) = outputDate;
                end
                outputRecord.(this.Values) = jsonFromValues(this, inputSeries.Data);
                if strlength(this.Frequency)>0 
                    outputRecord.(this.Frequency) = this.WriteFrequencyFunc(this, inputSeries.Frequency);
                end
            else
                % Empty time series
                outputRecord.(this.Dates) = string.empty(1, 0);
                outputRecord.(this.Values) = double.empty(1, 0);
                if strlength(this.Frequency)>0
                    outputRecord.(this.Frequency) = NaN;
                end
            end

            if strlength(this.Comment)>0
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


        function outputValues = jsonFromValues(this, inputData)
            %(
            outputValues = inputData;
            if isa(this.Format, 'function_handle')
                outputValues = this.Format(outputValues);
            elseif ~isequal(this.Format, false) && strlength(this.Format)>0
                outputValues = compose(this.Format, outputValues);
            end
            if this.ScalarAsArray && isscalar(outputValues)
                outputValues = { outputValues };
            else
                outputValues = reshape(outputValues, [ ], 1);
            end
            %)
        end%


        function db = jsonFromDatabank(this, db)
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
                x__ = this.jsonFromSeries(x__, name);
                if isa(db, 'Dictionary')
                    store(db, name, x__);
                else
                    db.(name) = x__;
                end
            end
            %)
        end%


        function db = databankFromJson(this, db, varargin)
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
                x__ = this.seriesFromJson(x__, name);
                if isa(db, 'Dictionary')
                    store(db, name, x__);
                else
                    db.(name) = x__;
                end
            end
            %)
        end%


        function freq = frequencyFromLetter(this, freq)
            %(
            if isnumeric(freq)
                freq = Frequency(freq); %#ok<CPROPLC>
            else
                freq = upper(string(freq));
            end
            if numel(freq)>1
                if ~all(freq==freq(1))
                    exception.error([
                        "Serialize:NonHomogeneousArrayOfFrequencies"
                        "If entered as an array, date frequencies must be all the same."
                    ]);
                end
                freq = freq(1);
            end
            if isnumeric(freq)
                return
            end
            switch upper(string(freq))
                case "I"
                    freq = Frequency.INTEGER;  %#ok<PROPLC>
                case {"A", "Y"}
                    freq = Frequency.YEARLY;  %#ok<PROPLC>
                case "H"
                    freq = Frequency.HALFYEARLY;  %#ok<PROPLC>
                case "Q"
                    freq = Frequency.QUARTERLY;  %#ok<PROPLC>
                case "M"
                    freq = Frequency.MONTHLY;  %#ok<PROPLC>
                case "W"
                    freq = Frequency.WEEKLY;  %#ok<PROPLC>
                case {"D", "B"}
                    freq = Frequency.DAILY;  %#ok<PROPLC>
                otherwise
                    freq = Frequency(NaN);  %#ok<CPROPLC>
            end
            %)
        end%


        function freq = writeFrequency(this, freq)
            %(
            freq = double(freq);
            %)
        end%


        function outputNames = mapNames(this, inputNames, varargin)
            %(
            if isempty(varargin)
                outputNames = inputNames;
                return
            end
            nameMap = varargin{1};
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
                exception.error([
                    "Serialize:InvalidNameMap"
                    "Invalid type of a name map for the Serialize object."
                ]);
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


        function saveJson(jsonStruct, fileName)
            %(
            fid = fopen(fileName, "w+t");
            fwrite(fid, string(jsonencode(jsonStruct)));
            fclose(fid);
            %)
        end%
    end
end

