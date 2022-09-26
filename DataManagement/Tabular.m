classdef (CaseInsensitiveProperties=true) Tabular < handle

    properties (Constant)
        EndFile (1, 1) string = "__eof__"
        IsEndFile = @(n) string(n)==string(Tabular.EndFile)
        IsDatesColumn = @(n) startsWith(string(n), "__") && ~Tabular.IsEndFile(n)
        HeaderFromFrequency = @(x) "__"+lower(string(Frequency(x)))+"__"
        FrequencyFromHeader = @(n) Frequency.(upper(erase(n, "_")))
        SheetSeparator (1, 1) string = "::"
        Multivariate (1, 1) string = "*"
    end


    properties
        FileName (1, 1) string = ""
        Sheet = []
        WhenMissing (1, 1) string = "warning"
        SourceNames = @all
        TargetNames = []
        Frequencies = @all
        NumDividers (1, 1) double = 1
        IncludeComments (1, 1) logical = true
        AddToDatabank = struct()
        StartDateOnly (1, 1) logical = false
        NaN (1, 1) string {ismember(NaN, ["NaN", ""])} = "NaN"
        WriteCellSettings (1, :) cell = cell.empty(1, 0)
        ReadCellSettings (1, :) cell = cell.empty(1, 0)
    end


    properties (Hidden)
        CurrentDatesColumn = NaN
        Header (:, :) cell = {}
        Values (:, :) cell = {}
    end


    properties 
        NamesRow
        CommentsRow
    end


    methods
        function getNamesRow(this)
            if isempty(this.Header)
                this.NamesRow = string.empty(1, 0);
                return
            end
            x = this.Header(1, :);
            inxFix = cellfun(@(x) (~isstring(x) && ~ischar(x)) || isempty(x) || strlength(x)==0 || any(ismissing(x)), x);
            x(inxFix) = {''};
            this.NamesRow = strip(string(x));
        end%


        function x = getCommentsRow(this)
            if isempty(this.Header) || ~this.IncludeComments
                this.CommentsRow = string.empty(1, 0);
                this.IncludeComments = false;
                return
            end
            x = this.Header(2, :);
            inxFix = cellfun(@(x) (~isstring(x) && ~ischar(x)) || isempty(x) || strlength(x)==0 || any(ismissing(x)), x);
            x(inxFix) = {''};
            this.CommentsRow = strip(string(x));
        end%
    end


    methods
        function dates = getDates(this, column)
            dates = this.CurrentDatesColumn;
        end%
    end


    methods
        function output = handleMissingNames(this, output, variablesFound)
            if ~isequal(this.SourceNames, @all)
                missingNames = setdiff(this.SourceNames, variablesFound);
                missingNames = reshape(string(missingNames), 1, []);
                if isempty(missingNames)
                    return
                end
                if ismember(this.WhenMissing, ["warning", "error"])
                    disp(reshape(missingNames, [], 1));
                    feval(this.WhenMissing, "Names printed above were not found in the input source.");
                end
                EMPTY_SERIES = Series();
                for name = missingNames
                    output.(name) = EMPTY_SERIES;
                end
            end
        end%


        function outputNames = fromDatabank(this, db)
            this.Header = cell.empty(1, 0);
            if this.IncludeComments
                this.Header = [this.Header; cell.empty(1, 0)];
            end
            this.Values = cell.empty(0, 0);

            fields = textual.fields(db);
            outputNames = databank.filterFields(db, "value", @(x) isa(x, 'Series'));
            if isstring(this.SourceNames)
                outputNames = intersect(outputNames, this.SourceNames, 'stable');
            end

            db = rmfield(db, setdiff(fields, outputNames));
            outputNames = textual.fields(db);

            freqs = reshape(structfun(@getFrequencyAsNumeric, db, 'uniformOutput', true), 1, []);
            freqs(isnan(freqs)) = Inf;
            if ~isequal(this.Frequencies, @all)
                includeFrequencies = reshape(double(Frequency(this.Frequencies)), 1, []);
                includeFrequencies(isnan(includeFrequencies)) = Inf;
                freqs = intersect(freqs, includeFrequencies);
            end

            for f = sort(unique(freqs))
                writeFrequency(this, db, f, outputNames(freqs==f));
            end

            writeEof(this);
        end%


        function save(this)
            sheetSettings = getSheetSettings(this);
            writecell([this.Header; this.Values], this.FileName, sheetSettings{:}, this.WriteCellSettings{:});
        end%


        function writeFrequency(this, db, freq, names)
            if isinf(freq)
                freq = NaN;
            end

            missingCell = {''};
            nanCell = {char(this.NaN)};

            header = {this.HeaderFromFrequency(freq)};

            if ~isnan(freq)
                range = databank.range(db, "sourceNames", names, "frequency", freq, "multifrequencies", false);
                range = reshape(range, [], 1);
            else
                range = NaN;
            end

            inxNaN = isnan(range);
            dates = cellstr(dater.toDefaultString(range));
            dates(inxNaN) = nanCell;

            if this.IncludeComments
                header = [header; missingCell];
            end
            this.Header = [this.Header, header];

            numPer = numel(dates);
            numValues = size(this.Values, 1);
            dates(end+1:numValues, 1) = missingCell;
            if ~isempty(this.Values)
                this.Values(end+1:numPer, :) = missingCell;
            end
            this.Values = [this.Values, dates];

            for n = names
                if ~isnan(freq)
                    values = getDataFromTo(db.(n), range);
                else
                    size__ = size(db.(n));
                    size__(1) = 1;
                    values = nan(size__);
                end
                values = values(:, :);
                inxNaN = isnan(values);
                values = num2cell(values);
                values(inxNaN) = nanCell;
                values(end+1:numValues, :) = missingCell;

                this.Values = [this.Values, values];

                targetName = getTargetName(this, n);
                numColumns = size(values, 2);
                header = [{char(targetName)}, repmat({char(this.Multivariate)}, 1, numColumns-1)];
                if this.IncludeComments
                    header = [header; cellstr(comment(db.(n)))];
                end
                this.Header = [this.Header, header];
            end

            if this.NumDividers>1
                this.Header(:, end+(1:this.NumDividers)) = missingCell;
                this.Values(:, end+(1:this.NumDividers)) = missingCell;
            end
        end%


        function writeEof(this)
            missingCell = {''};
            numHeaderRows = size(this.Header, 1);
            numValuesRows = size(this.Values, 1);
            this.Header = [this.Header, repmat({this.EndFile}, numHeaderRows, 1)];
            this.Values = [this.Values, repmat({this.EndFile}, numValuesRows, 1)];
        end%


        function outputDb = toDatabank(this)
            %(
            outputDb = this.AddToDatabank;

            numHeaderColumns = size(this.Header, 2);
            numDataColumns = size(this.Values, 2);
            if numHeaderColumns~=numDataColumns
                error( ...
                    "Invalid structure of the input data spreadsheet: \nNumber of header columns (%g) does not match number of data columns (%g)." ...
                    , numHeaderColumns, numDataColumns ...
                );
            end

            variablesFound = string.empty(1, 0);

            column = 0;
            while column<numDataColumns
                column = column + 1;
                name = this.NamesRow(column);

                if name==""
                    continue
                end

                if this.IsEndFile(name)
                    break
                end

                if this.IsDatesColumn(name)
                    this.CurrentDatesColumn = extractDatesColumn(this, name, column);
                    continue
                end

                if ~isequal(this.SourceNames, @all) && ~ismember(name, this.SourceNames)
                    continue
                end

                variablesFound(end+1) = name;
                values = extractValuesColumn(this, column);
                comments = extractComment(this, column);

                while column<numDataColumns && this.NamesRow(column+1)==this.Multivariate
                    column = column + 1;
                    values = [values, extractValuesColumn(this, column)];
                    comments = [comments, extractComment(this, column)];
                end

                inxKeep = ~all(isnan([this.CurrentDatesColumn, values]), 2);

                targetName = getTargetName(this, name);
                outputDb.(targetName) = Series(this.CurrentDatesColumn(inxKeep, :), values(inxKeep, :), comments);
            end

            outputDb = handleMissingNames(this, outputDb, variablesFound);
            %)
        end%


        function targetName = getTargetName(this, sourceName)
            %(
            targetName = sourceName;
            if isempty(this.TargetNames)
                return
            end
            if isa(this.TargetNames, 'function_handle')
                targetName = this.TargetNames(targetName);
                return
            end
            if isstruct(this.TargetNames) && isfield(this.TargetNames, sourceName)
                targetNama = this.TargetNames.(sourceNames);
                return
            end
            %)
        end%


        function outputDates = extractDatesColumn(this, name, column)
            %(
            isIsoString = @(x) ischar(x) && strlength(x)==10 && x(5)=='-' &&  x(8)=='-';

            freq = this.FrequencyFromHeader(name);
            dates = this.Values(:, column);

            inxMiss = cellfun(@(x) any(ismissing(x)) || isempty(x), dates);
            if all(inxMiss)
                outputDates = nan(size(dates));
                return
            end
            pos = find(~inxMiss, 1);

            if isa(dates{pos}, 'datetime')
                if any(inxMiss)
                    dates(inxMiss) = {NaT};
                end
                dates = reshape([dates{:}], [], 1);
                try
                    outputDates = dater.fromMatlab(freq, dates);
                    return
                end
            end

            if ischar(dates{pos})
                dates = reshape(dates, [], 1);
                outputDates = nan(size(dates));
                if isnan(freq)
                    return
                end
                if isIsoString(dates{pos})
                    try
                        outputDates(~inxMiss) = dater.fromIsoString(freq, dates(~inxMiss));
                        return
                    end
                end
                try
                    outputDates(~inxMiss) = dater.fromDefaultString(freq, dates(~inxMiss));
                    return
                end
            end

            exception.error([
                "Tabular"
                "Invalid dates in column %s. "
            ], name);
            %)
        end%


        function comment = extractComment(this, column)
            %(
            if ~this.IncludeComments
                comment = "";
                return
            end
            comment = this.CommentsRow(column);
            %)
        end%


        function values = extractValuesColumn(this, column)
            values = this.Values(:, column);
            for i = 1 : numel(values)
                if ~isnumeric(values{i}) || ~isscalar(values{i})
                    values{i} = NaN;
                end
            end
            values = reshape(double([values{:}]), [], 1);
        end%


        function this = load(this)
            %( 
            sheetSettings = getSheetSettings(this);
            numHeaderRows = 1 + double(this.IncludeComments);
            headerRange = sprintf("1:%g", numHeaderRows);
            this.Header = readcell(this.FileName, sheetSettings{:}, "range", headerRange, this.ReadCellSettings{:});
            this.Values = readcell(this.FileName, sheetSettings{:}, "numHeaderLines", numHeaderRows, this.ReadCellSettings{:});
            getNamesRow(this);
            getCommentsRow(this);
            %)
        end%


        function sheetSettings = getSheetSettings(this)
            %(
            sheetSettings = cell.empty(1, 0);
            if ~isempty(this.Sheet)
                sheetSettings = {"sheet", this.Sheet, "useExcel", false};
            end
            %)
        end%
    end
end

