% Type `web +databank/fromCSV.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function outputDb = fromCSV(fileName, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.fromCSV');
    addRequired(pp, 'fileName', @validate.list);

    addParameter(pp, 'AddToDatabank', [ ], @(x) isequal(x, [ ]) || validate.databank(x));
    addParameter(pp, {'Case', 'ChangeCase'}, "", @(x) isempty(x) || (validate.stringScalar(x) && any(lower(x)==["", "lower", "upper"])));
    addParameter(pp, {'CommentsHeader', 'CommentRow'}, {'CommentRow', 'Comment', 'Comments', 'CommentsRow'}, @(x) validate.text(x) || validate.roundScalar(x, 1, Inf));
    addParameter(pp, 'Continuous', false, @(x) isequal(x, false) || any(strcmpi(x, {'Ascending', 'Descending'})));
    addParameter(pp, 'Delimiter', ', ', @(x) ischar(x) && numel(sprintf(x))==1);
    addParameter(pp, 'FirstDateOnly', false, @validate.logicalScalar);
    addParameter(pp, {'NamesHeader', 'NameRow', 'NamesRow', 'LeadingRow'}, ["", "Variables", "Time"], @(x) validate.text(x) || validate.roundScalar(x, 1, Inf));
    addParameter(pp, {'NameFunc', 'NamesFunc'}, [ ], @(x) isempty(x) || isfunc(x) || (iscell(x) && all(cellfun(@isfunc, x))));
    addParameter(pp, 'NaN', "NaN", @validate.stringScalar);
    addParameter(pp, 'OutputType', @auto, @(x) isequal(x, @auto) || validate.anyString(x, 'struct', 'Dictionary'));
    addParameter(pp, 'Preprocess', [ ], @(x) isempty(x) || isa(x, 'function_handle') || (iscell(x) && all(cellfun(@isfunc, x))));
    addParameter(pp, 'RemoveFromData', cell.empty(1, 0), @(x) iscellstr(x) || ischar(x) || isa(x, 'string'));
    addParameter(pp, 'Select', @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x));
    addParameter(pp, {'SkipRows', 'skiprow'}, '', @(x) isempty(x) || ischar(x) || iscellstr(x) || isnumeric(x));
    addParameter(pp, {'DatabankUserData', 'UserData'}, Inf, @(x) isequal(x, Inf) || (ischar(x) && isvarname(x)));
    addParameter(pp, 'UserDataField', '.', @(x) ischar(x) && isscalar(x));
    addParameter(pp, 'UserDataFieldList', [], @(x) isempty(x) || validate.text(x) || isnumeric(x));
    addParameter(pp, 'VariableNames', @auto, @(x) isequal(x, @auto) || validate.list(x));
    addDateOptions(pp);
end
%)
opt = parse(pp, fileName, varargin{:});
fileName = cellstr(fileName);

% Check consistency of options AddToDatabank= and OutputFormat=
outputDb = databank.backend.ensureTypeConsistency( ...
    opt.AddToDatabank, ...
    opt.OutputType ...
);

% Loop over all input databanks subcontracting `databank.fromCSV` and
% merging the resulting databanks in one.
if numel(fileName)>1
    numFileNames = numel(fileName);
    for i = 1 : numFileNames
        outputDb = databank.fromCSV( ...
            fileName(i), varargin{:}, ...
            'AddToDatabank=', outputDb ...
        );
    end
    return
else
    fileName = fileName{1};
end


if isequal(opt.FirstDateOnly, true)
    opt.Continuous = 'Ascending';
end

% Preprocess options
hereProcessOptions( );

%--------------------------------------------------------------------------

% Read the CSV file, and apply user-supplied function(s) to pre-process the
% raw text file.
file = '';


%==========================================================================
hereReadFile( );
%==========================================================================


% Replace non-comma delimiter with comma; applies only to CSV files
if ~strcmp(opt.Delimiter, ',')
    file = replace(file, sprintf(opt.Delimiter), ',');
end

% **Read Headers**
nameRow = { };
classRow = { };
cmtRow = { };
start = 1;
databankUserDataValueString = '';
databankUserDataFieldName = '';
isUserData = false;
seriesUserdata = struct( );


%==========================================================================
hereReadHeaders( );
%==========================================================================


% Trim the headers
if start>1
    file = file(start:end);
end

classRow = strtrim(classRow);
cmtRow = strtrim(cmtRow);
if numel(classRow)<numel(nameRow)
    classRow(numel(classRow)+1:numel(nameRow)) = {''};
end
if numel(cmtRow)<numel(nameRow)
    cmtRow(numel(cmtRow)+1:numel(nameRow)) = {''};
end

% Apply user selection, white out all names that user did not select
if ~isequal(opt.Select, @all)
    if ischar(opt.Select)
        opt.Select = regexp(opt.Select, '\w+', 'match');
    end
    for i = 1 : numel(nameRow)
        if ~any(strcmp(nameRow{i}, opt.Select))
            nameRow{i} = ''; %#ok<AGROW>
        end
    end
end


%==========================================================================
[data, inxMissing, datesColumn] = hereReadNumericData( );
%==========================================================================


%
% Parse dates
%
[dates, inxNaNDates] = hereParseDates( );

if ~isempty(dates)
    maxDate = max(dates);
    minDate = min(dates);
    numPeriods = 1 + round(maxDate - minDate);
    posDates = 1 + round(dates - minDate);
else
    numPeriods = 0;
    posDates = [ ];
    minDate = NaN;
end

% Change variable names.
% * Apply user function to variables names.
% * Convert variable name case.
hereChangeNames( );

% Make sure the databank entry names are all valid and unique Matlab names.
hereCheckNames( );

% Populated the user data field; this is NOT Series user data, but a
% separate entry in the output databank
if ~isempty(opt.DatabankUserData) && isUserData
    hereCreateUserdataField( );
end


%
% Create database
% Populate the output databank with Series and numeric data
%
%==========================================================================
herePopulateDatabank( );
%==========================================================================

return


    function hereReadFile( )
        % Read CSV file to char
        file = fileread(fileName);
        file = textual.removeUTFBOM(file);
        file = textual.convertEndOfLines(file);
        if isempty(opt.Preprocess)
            return
        end
        % Preprocess raw text using user-supplied functions
        func = opt.Preprocess;
        if ~iscell(func)
            func = {func};
        end
        for ii = 1 : numel(func)
            file = func{ii}(file);
        end
    end%




    function hereProcessOptions( )
        % Headers for rows to be skipped
        if ischar(opt.SkipRows)
            opt.SkipRows = {opt.SkipRows};
        end
        if ~isempty(opt.SkipRows) && ~isnumeric(opt.SkipRows)
            for ii = 1 : numel(opt.SkipRows)
                if isempty(opt.SkipRows{ii})
                    continue
                end
                if opt.SkipRows{ii}(1)~='^'
                    opt.SkipRows{ii} = ['^', opt.SkipRows{ii}];
                end
                if opt.SkipRows{ii}(end)~='$'
                    opt.SkipRows{ii} = [opt.SkipRows{ii}, '$'];
                end
            end
        end
        % Headers for comment rows
        if validate.text(opt.CommentsHeader)
            opt.CommentsHeader = string(opt.CommentsHeader);
        end
    end%




    function hereReadHeaders( )
        isDate = false;
        isNameRowDone = false;
        ident = '';
        rowCount = 0;

        if ~isequal(opt.VariableNames, @auto)
            nameRow = cellstr(opt.VariableNames);
            isNameRowDone = true;
        end

        while ~isempty(file) && ~isDate
            rowCount = rowCount + 1;
            eol = regexp(file, '\n', 'start', 'once');
            if isempty(eol)
                line = file;
            else
                line = file(start:eol-1);
            end
            if validate.numericScalar(opt.NamesHeader) && rowCount<opt.NamesHeader
                hereMoveToNextEol( );
                continue
            end

            % Read individual comma-separated cells on the current line. Capture the
            % entire match (including separating commas and double quotes), not only
            % tokens -- this is a workaround for a bug in Octave.
            tkn = regexp(line, '[^",]*,|[^",]*$|"[^"]*",|"[^"]*"$', 'match');
            % Remove separating commas from the end of cells.
            tkn = regexprep(tkn, ',$', '', 'once');
            % Remove double quotes from beginning and end of each cell.
            tkn = regexprep(tkn, '^"', '', 'once');
            tkn = regexprep(tkn, '"$', '', 'once');

            if isempty(tkn) || all(cellfun(@isempty, tkn))
                ident = '%';
            else
                ident = erase(tkn{1}, "->");
                ident = strip(ident);
            end

            if isnumeric(opt.SkipRows) && any(rowCount==opt.SkipRows)
                hereMoveToNextEol( );
                continue
            end

            if hereTestNameRow( )
                nameRow = tkn(2:end);
                isNameRowDone = true;
                hereMoveToNextEol( );
                continue
            end


            isDate = true;

            %
            % ## User Data Fields
            %
            % Some of the user data fields can be reused as comments, hence
            % do this before anything else
            %
            if validate.text(opt.UserDataFieldList)
                opt.UserDataFieldList = string(opt.UserDataFieldList);
            end
            opt.UserDataFieldList = reshape(opt.UserDataFieldList, 1, []);

            if startsWith(ident, opt.UserDataField) ...
                    ...
                    || ( ...
                        isstring(opt.UserDataFieldList) ...
                        && ~isempty(opt.UserDataFieldList) ...
                        && any(lower(ident)==lower(opt.UserDataFieldList)) ...
                    ) ...
                    ...
                    || ( ...
                        isnumeric(opt.UserDataFieldList) ...
                        && ~isempty(opt.UserDataFieldList) ...
                        && any(rowCount==opt.UserDataFieldList) ...
                    )
                fieldName = regexprep(ident, '\W', '');
                fieldName = matlab.lang.makeUniqueStrings(fieldName);
                try %#ok<TRYNC>
                    seriesUserdata.(fieldName) = tkn(2:end);
                end
                isDate = false;
            end

            if startsWith(ident, "%") || isempty(ident) || strlength(ident)==0
                isDate = false;
            elseif contains(ident, "UserData", "ignoreCase", true)
                databankUserDataFieldName = getUserdataFieldName(tkn{1});
                databankUserDataValueString = tkn{2};
                isUserData = true;
                isDate = false;
            elseif contains(ident, "Class[Size]", "ignoreCase", true)
                classRow = tkn(2:end);
                isDate = false;
            elseif hereTestCommentsHeader( )
                cmtRow = tkn(2:end);
                isDate = false;
            elseif contains(ident, "Units", "ignoreCase", true)
                isDate = false;
            elseif ~isnumeric(opt.SkipRows) ...
                    && any(~cellfun(@isempty, regexp(ident, opt.SkipRows)))
                isDate = false;
            end

            if ~isDate
                hereMoveToNextEol( );
            end
        end%

        return


            function hereMoveToNextEol( )
                if ~isempty(eol)
                    file(eol) = ' ';
                    start = eol + 1;
                else
                    file = '';
                end
            end%


            function flag = hereTestNameRow( )
                if isNameRowDone
                    flag = false;
                    return
                elseif isequal(opt.NamesHeader, rowCount)
                    flag = true;
                    return
                elseif any(lower(opt.NamesHeader)==lower(opt.NamesHeader))
                    flag = true;
                    return
                end
                flag = false;
            end%


            function flag = hereTestCommentsHeader( )
                if isequal(opt.CommentsHeader, rowCount)
                    flag = true;
                    return
                elseif any(lower(ident)==lower(opt.CommentsHeader))
                    flag = true;
                    return
                end
                flag = false;
            end%
    end%




    function [data, inxMissing, datesColumn] = hereReadNumericData( )
        data = double.empty(0, 0);
        inxMissing = logical.empty(1, 0);
        datesColumn = cell.empty(1, 0);
        if isempty(file)
            return
        end

        % Read date column (first column)
        datesColumn = regexp(file, "^[^,]*?(,|$)", "match", "lineanchors");
        datesColumn = strip(datesColumn);
        datesColumn = erase(datesColumn, ",");

        % Remove leading or trailing single or double quotes.
        % Some programs save any text cells with single or double quotes.
        datesColumn = regexprep(datesColumn, '^["'']', '');
        datesColumn = regexprep(datesColumn, '["'']$', '');

        % Replace user-supplied NaN strings with 'NaN'. The user-supplied NaN
        % strings must not contain commas.
        file = erase(lower(file), " ");
        opt.NaN = strip(lower(string(opt.NaN)));

        % When replacing user-defined NaNs, there can be in theory conflict with
        % date strings. We do not resolve this conflict because it is not very
        % likely.
        if strcmpi(opt.NaN, "NaN")
            % Remove quotes from quoted NaNs
            file = replace(file, '"nan"', "NaN");
        else
            % We cannot have multiple NaN strings because of the way `strrep` handles
            % repeated patterns and because `strrep` is not able to detect word
            % boundaries. Handle quoted NaNs first.
            file = replace(file, """" + opt.NaN + """", "NaN");
            if strcmp(opt.NaN, ".")
                file = regexprep(file, "(?<=,)(\.)(?=(,|\n|\r))", "NaN");
            else
                file = replace(file, opt.NaN, "NaN");
            end
        end

        % Replace empty character cells with numeric NaNs
        file = replace(file, '""', "NaN");
        % Replace date highlights with numeric NaNs
        file = replace(file, '"***"', "NaN");
        % Define white spaces
        whiteSpace = sprintf(' \b\r\t');

        % Remove single and double quotes from the data part of the file
        if ~isempty(opt.RemoveFromData)
            for n = reshape(string(opt.RemoveFromData), 1, [])
                if strlength(n)>0
                    file = replace(file, n, "");
                end
            end
        end

        % Read numeric data; empty cells will be treated either as `NaN` or
        % `NaN+NaNi` depending on the presence or absence of complex
        % numbers in the rest of that particular row.
        data = textscan( ...
            file, '', -1 ...
            , 'Delimiter', ',', 'WhiteSpace', whiteSpace ...
            , 'HeaderLines', 0, 'HeaderColumns', 1, 'EmptyValue', -Inf ...
            , 'CommentStyle', 'Matlab', 'CollectOutput', true ...
        );
        if isempty(data)
            throw(exception.Base('Dbase:InvalidLoadFormat', 'error'), fileName); %#ok<GTARG>
        end
        data = data{1};
        inxMissing = false(size(data));
        % The value `-Inf` indicates a possible missing value (but may be a
        % genuine `-Inf`, too). Re-read the table again, with missing
        % values represented by `NaN` this time to pin down missing values.
        inxMaybeMissing = real(data)==-Inf;
        if nnz(inxMaybeMissing)>0
            data1 = textscan( ...
                file, '', -1 ...
                , 'Delimiter', ',', 'WhiteSpace', whiteSpace ...
                , 'HeaderLines', 0, 'HeaderColumns', 1, 'EmptyValue', NaN ...
                , 'CommentStyle', 'Matlab', 'CollectOutput', true ...
            );
            data1 = data1{1};
            inxMaybeMissing1 = isnan(real(data1));
            inxMissing(inxMaybeMissing & inxMaybeMissing1) = true;
        end
        if strcmpi(opt.Continuous, 'Descending')
            data = flipud(data);
            inxMissing = flipud(inxMissing);
            datesColumn = datesColumn(end:-1:1);
        end
    end%




    function [dates, inxNaDates] = hereParseDates( )
        numDates = numel(datesColumn);
        % dates = DateWrapper(nan(1, numDates));
        dates = nan(1, numDates);
        datesColumn = datesColumn(1:min(end, size(data, 1)));
        if ~isempty(datesColumn)
            if startsWith(string(opt.Continuous), "ascend", "ignoreCase", true)
                datesColumn(2:end) = {''};
            elseif startsWith(string(opt.Continuous), "descend", "ignoreCase", true)
                datesColumn(1:end-1) = {''};
            end
            % Rows with empty dates.
            inxEmptyDates = cellfun(@isempty, datesColumn);
        end
        % Convert date strings
        if ~isempty(datesColumn) && ~all(inxEmptyDates)
            if isequal(opt.DateFormat, @iso) || validate.anyText(opt.DateFormat, "ISO")
                if ~validate.numericScalar(opt.EnforceFrequency)
                    exception.error([
                        "Databank:EnforceFrequencyWhenIso"
                        "Option EnforceFrequency= must be specified whenever DateFormat=""ISO""."
                    ]);
                end
                dates(~inxEmptyDates) ...
                    = dater.fromIsoString(opt.EnforceFrequency, string(datesColumn(~inxEmptyDates)));
            else
                dates(~inxEmptyDates) = str2dat( ...
                    datesColumn(~inxEmptyDates), ...
                    "dateFormat", opt.DateFormat, ...
                    "months", opt.Months, ...
                    "enforceFrequency", opt.EnforceFrequency, ...
                    "freqLetters", opt.FreqLetters ...
                );
            end

            if startsWith(string(opt.Continuous), "ascend", "ignoreCase", true)
                dates = dater.plus(dates(1), 0 : numDates-1);
            elseif startsWith(string(opt.Continuous), "descend", "ignoreCase", true)
                dates = fliplr(dater.plus(dates(end), -(0 : numDates-1)));
            end

        end
        % Exclude NaN dates (that includes also empty dates), but keep all data
        % rows; this is because of non-time-series data
        inxNaDates = isnan(dates);
        dates(inxNaDates) = [ ];

        % Homogeneous frequency check
        if ~isempty(dates)
            freqDates = dater.getFrequency(dates);
            Frequency.checkMixedFrequency(freqDates, [ ], 'in CSV data files');
        end
    end%




    function herePopulateDatabank( )
        TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
        TEMPLATE_SERIES = TIME_SERIES_CONSTRUCTOR( );
        count = 0;
        lenNameRow = numel(nameRow);
        seriesUserdataList = fieldnames(seriesUserdata);
        numSeriesUserData = numel(seriesUserdataList);
        while count<lenNameRow
            name = nameRow{count+1};
            if numSeriesUserData>0
                thisUserData = hereCreateSeriesUserdata( );
            end
            if isempty(name)
                % Skip columns with empty names.
                count = count + 1;
                continue
            end
            tokens = regexp(classRow{count+1}, ...
                '^(\w+)((\[.*\])?)', 'tokens', 'once');
            if isempty(tokens)
                cls = '';
                tmpSize = [ ];
            else
                cls = tokens{1};
                tmpSize = getSize(tokens{2});
            end
            if isempty(cls)
                cls = 'Series';
            end
            if strcmpi(cls, 'Series') || strcmpi(cls, 'tseries')
                % Time series entry
                if isempty(tmpSize)
                    tmpSize = [Inf, 1];
                end
                numColumns = prod(tmpSize(2:end));
                if ~isempty(data)
                    if isreal(data(~inxNaNDates, count+(1:numColumns)))
                        unit = 1;
                    else
                        unit = 1 + 1i;
                    end
                    data__ = nan(numPeriods, numColumns)*unit;
                    inxMissing__ = false(numPeriods, numColumns);
                    data__(posDates, :) = data(~inxNaNDates, count+(1:numColumns));
                    inxMissing__(posDates, :) = inxMissing(~inxNaNDates, count+(1:numColumns));
                    data__(inxMissing__) = NaN*unit;
                    data__ = reshape(data__, [numPeriods, tmpSize(2:end)]);
                    comment__ = cmtRow(count+(1:numColumns));
                    comment__ = reshape(comment__, [1, tmpSize(2:end)]);
                    newEntry = replace(TEMPLATE_SERIES, data__, minDate, comment__);
                else
                    % Create an empty Series object with proper 2nd and higher
                    % dimensions
                    data__ = zeros([0, tmpSize(2:end)]);
                    newEntry = replace(TEMPLATE_SERIES, data__, NaN, '');
                end
                if numSeriesUserData>0
                    newEntry = userdata(newEntry, thisUserData);
                end
            elseif ~isempty(tmpSize)
                % Numeric data
                numColumns = prod(tmpSize(2:end));
                data__ = reshape(data(1:tmpSize(1), count+(1:numColumns)), tmpSize);
                inxMissing__ = reshape(inxMissing(1:tmpSize(1), count+(1:numColumns)), tmpSize);
                data__(inxMissing__) = NaN;
                fnClass = str2func(cls);
                newEntry = fnClass(data__);
            end
            outputDb.(char(name)) = newEntry;
            count = count + numColumns;
        end

        return


        function userData = hereCreateSeriesUserdata( )
            userData = struct( );
            for ii = 1 : numSeriesUserData
                try
                    userData.(seriesUserdataList{ii}) = ...
                        seriesUserdata.(seriesUserdataList{ii}){count+1};
                catch %#ok<CTCH>
                    userData.(seriesUserdataList{ii}) = '';
                end
            end
        end
    end%




    function hereChangeNames( )
        % Apply user function(s) to each name.
        if ~isempty(opt.NameFunc)
            func = opt.NameFunc;
            if ~iscell(func)
                func = {func};
            end
            for iname = 1 : numel(nameRow)
                for ifunc = 1 : numel(func)
                    nameRow{iname} = func{ifunc}(nameRow{iname});
                end
            end
        end
        if ~iscellstr(nameRow)
            throw( exception.Base('Dbase:InvalidOptionNameFunc', 'error') );
        end
        if startsWith(opt.Case, "lower", "ignoreCase", true)
            nameRow = lower(nameRow);
        elseif startsWith(opt.Case, "upper", "ignoreCase", true)
            nameRow = upper(nameRow);
        end
    end%




    function hereCheckNames( )
        inxEmpty = cellfun(@isempty, nameRow);
        if isstruct(outputDb)
            inxValid = cellfun(@isvarname, nameRow);
        else
            inxValid = true(size(nameRow));
        end
        % Index of non-empty, invalid names that need to be regenerated
        inxToGenerate = ~inxEmpty & ~inxValid;
        % Index of valid names that will be protected
        inxToProtect = ~inxEmpty & inxValid;
        % `genvarname` now guarantees uniqueness of names by appending `1`, `2`,
        % etc. at the end of the string; did not use to be the case in older
        % versions of Matlab.
        if any(inxToGenerate)
            nameRow(inxToGenerate) = genvarname(nameRow(inxToGenerate), nameRow(inxToProtect));
        end
    end%




    function hereCreateUserdataField( )
        if ischar(opt.DatabanUserData) || isempty(databankUserDataFieldName)
            databankUserDataFieldName = opt.DatabankUserData;
        end
        try
            userDataField = eval(databankUserDataValueString);
        catch err
            throw( exception.Base('Dbase:ErrorLoadingUserData', 'error'), ...
                   fileName, err.message ); %#ok<GTARG>
        end
        outputDb.(char(databankUserDataFieldName)) = userDataField;
    end%
end%




function s = getSize(c)
% Read the size string 1-by-1-by-1 etc. as a vector.
% New style of saving size: [1-by-1-by-1].
% Old style of saving size: [1][1][1].
    c = strrep(c(2:end-1), '][', '-by-');
    s = sscanf(c, '%g-by-');
    s = s(:).';
end%




function name = getUserdataFieldName(c)
    name = regexp(c, '\[([^\]]+)\]', 'once', 'tokens');
    if ~isempty(name)
        name = name{1};
    else
        name = '';
    end
end%

