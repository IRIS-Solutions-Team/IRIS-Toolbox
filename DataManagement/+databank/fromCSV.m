% >=R2019b
%{
function [outputDb, info] = fromCSV(fileName, opt)

arguments
    fileName (1, :) string 

    opt.AddToDatabank {validate.mustBeDatabank(opt.AddToDatabank, [])} = []
    opt.Case (1, 1) string {mustBeMember(opt.Case, ["", "lower", "upper"])} = ""
    opt.CommentsHeader = ["CommentRow", "Comment", "Comments", "CommentsRow"]
        opt.CommentRow__CommentsHeader = []
    opt.Continuous = false
    opt.Delimiter (1, 1) string = ","
    opt.FirstDateOnly (1, 1) logical = false
    opt.NamesHeader = ["", "Variables", "Time"]
        opt.NameRow__NamesHeader = []
        opt.NamesRow__NamesHeader = []
        opt.LeadingRow__NamesHeader = []
    opt.NameFunc = []
        opt.NamesFunc__NameFunc = []
    opt.NaN (1, 1) string = "NaN"
    opt.OutputType (1, 1) string {mustBeMember(opt.OutputType, ["__auto__", "struct", "Dictionary"])} = "__auto__"
    opt.Preprocess = []
    opt.RemoveFromData (1, :) string = string.empty(1, 0)
    opt.Select (1, :) string = "__all__"
    opt.SkipRows (1, :) = string.empty(1, 0)
    opt.DatabankUserData = Inf
        opt.UserData__DatabankUserData = []
    opt.UserDataField (1, 1) string = "."
    opt.UserDataFieldList (1, :) string = string.empty(1, 0)
    opt.VariableNames (1, :) string = "__auto__"

    opt.Postprocess = []

    opt.DateFormat = @auto
    opt.EnforceFrequency = false
        opt.Frequency__EnforceFrequency = []
    opt.Months = iris.Configuration.Months
end
%}
% >=R2019b


% <=R2019a
%(
function outputDb = fromCSV(fileName, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();

    addParameter(ip, "AddToDatabank", []);
    addParameter(ip, "Case", "");
    addParameter(ip, "CommentsHeader", ["CommentRow", "Comment", "Comments", "CommentsRow"]);
        addParameter(ip, "CommentRow__CommentsHeader", []);
    addParameter(ip, "Continuous", false);
    addParameter(ip, "Delimiter", ",");
    addParameter(ip, "FirstDateOnly", false);
    addParameter(ip, "NamesHeader", ["", "Variables", "Time"]);
        addParameter(ip, "NameRow__NamesHeader", []);
        addParameter(ip, "NamesRow__NamesHeader", []);
        addParameter(ip, "LeadingRow__NamesHeader", []);
    addParameter(ip, "NameFunc", []);
        addParameter(ip, "NamesFunc__NameFunc", []);
    addParameter(ip, "NaN", "NaN");
    addParameter(ip, "OutputType", "__auto__");
    addParameter(ip, "Preprocess", []);
    addParameter(ip, "RemoveFromData", string.empty(1, 0));
    addParameter(ip, "Select", "__all__");
    addParameter(ip, "SkipRows", string.empty(1, 0));
    addParameter(ip, "DatabankUserData", Inf);
        addParameter(ip, "UserData__DatabankUserData", []);
    addParameter(ip, "UserDataField", ".");
    addParameter(ip, "UserDataFieldList", string.empty(1, 0));
    addParameter(ip, "VariableNames", "__auto__");

    addParameter(ip, "Postprocess", []);

    addParameter(ip, "DateFormat", @auto);
    addParameter(ip, "EnforceFrequency", false);
        addParameter(ip, "Frequency__EnforceFrequency", []);
    addParameter(ip, "Months", iris.Configuration.Months);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


opt = iris.utils.resolveOptionAliases(opt, [], Except("Frequency"));


fileName = textual.stringify(fileName);
fileName = fileName(strlength(fileName)>0);

% Check consistency of options AddToDatabank= and OutputFormat=
outputDb = databank.backend.ensureTypeConsistency( ...
    opt.AddToDatabank, ...
    opt.OutputType ...
);

info = struct();

if isempty(fileName)
    return
end

% Loop over all input databanks subcontracting `databank.fromCSV` and
% merging the resulting databanks in one.
if numel(fileName)>1
    cellOptions = cell.empty(1, 0);
    for n = textual.fields(opt)
        cellOptions = [cellOptions, {n, opt.(n)}];
    end
    for n = textual.stringify(fileName)
        outputDb = databank.fromCSV( ...
            n, cellOptions{:}, ...
            "addToDatabank", outputDb ...
        );
    end
    return
end


if isequal(opt.FirstDateOnly, true)
    opt.Continuous = 'Ascending';
end

% Preprocess options
here_processOptions( );


% Read the CSV file, and apply user-supplied function(s) to pre-process the
% raw text file.
file = '';


%==========================================================================
here_readAndPreprocessFile();
%==========================================================================


% Replace non-comma delimiter with comma; applies only to CSV files
if opt.Delimiter~=","
    file = replace(file, sprintf(opt.Delimiter), ",");
end

% **Read Headers**
nameRow = string.empty(1, 0);
classRow = { };
commentRow = { };
start = 1;
databankUserDataValueString = '';
databankUserDataFieldName = '';
isUserData = false;
seriesUserdata = struct( );


%==========================================================================
here_readHeaders( );
%==========================================================================


% Trim the headers
if start>1
    file = file(start:end);
end

classRow = strip(classRow);
commentRow = strip(commentRow);
nameRow = strip(nameRow);

if numel(classRow)<numel(nameRow)
    classRow(numel(classRow)+1:numel(nameRow)) = {''};
end
if numel(commentRow)<numel(nameRow)
    commentRow(numel(commentRow)+1:numel(nameRow)) = {''};
end

testForAll = @(x) isequal(x, @all) || isequal(x, "__all__") || isequal(x, '__all__');

% Apply user selection, white out all names that user did not select
if testForAll(opt.Select)
    % Pass
else
    if ischar(opt.Select)
        opt.Select = regexp(opt.Select, '\w+', 'match');
    end
    opt.Select = textual.stringify(opt.Select);
    for i = 1 : numel(nameRow)
        if nameRow(i)~=opt.Select
            nameRow(i) = "";
        end
    end
end


%==========================================================================
[data, inxMissing, datesColumn] = here_readNumericData( );
%==========================================================================


%
% Parse dates
%
[dates, inxNaNDates] = here_parseDates( );

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
here_changeNames( );

% Make sure the databank entry names are all valid and unique Matlab names.
here_checkNames( );

% Populated the user data field; this is NOT Series user data, but a
% separate entry in the output databank
if ~isempty(opt.DatabankUserData) && isUserData
    here_createUserdataField( );
end


%
% Create database
% Populate the output databank with Series and numeric data
%
[outputDb, info.NamesCreated] = here_populateDatabank(outputDb);


%
% Apply postprocess function
%
outputDb = databank.backend.postprocess(outputDb, info.NamesCreated, opt.Postprocess);


return

    function here_readAndPreprocessFile( )
        %(
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
            if isa(func{ii}, 'function_handle')
                file = func{ii}(file);
            end
        end
        %)
    end%


    function here_processOptions( )
        % Headers for rows to be skipped
        if validate.text(opt.SkipRows)
            opt.SkipRows = textual.stringify(opt.SkipRows);
        end
        if ~isempty(opt.SkipRows) && ~isnumeric(opt.SkipRows)
            for ii = 1 : numel(opt.SkipRows)
                n = opt.SkipRows(ii);
                if isempty(n)
                    continue
                end
                if ~startsWith(n, "^")
                    n = "^" + n;
                end
                if ~endsWith(n, "$")
                    n = n + "$";
                end
            end
        end
        % Headers for comment rows
        if validate.text(opt.CommentsHeader)
            opt.CommentsHeader = textual.stringify(opt.CommentsHeader);
        end
    end%




    function here_readHeaders( )
        isDate = false;
        isNameRowDone = false;
        ident = '';
        rowCount = 0;

        if ~all(strcmpi(opt.VariableNames, '__auto__'))
            nameRow = textual.stringify(opt.VariableNames);
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
                here_moveToNextEol( );
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
                here_moveToNextEol( );
                continue
            end

            if here_testNameRow( )
                nameRow = textual.stringify(tkn(2:end));
                isNameRowDone = true;
                here_moveToNextEol( );
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
                opt.UserDataFieldList = textual.stringify(opt.UserDataFieldList);
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

            if contains(ident, "UserData", "ignoreCase", true)
                databankUserDataFieldName = getUserdataFieldName(tkn{1});
                databankUserDataValueString = tkn{2};
                isUserData = true;
                isDate = false;
            elseif contains(ident, "Class[Size]", "ignoreCase", true)
                classRow = tkn(2:end);
                isDate = false;
            elseif here_testCommentsHeader( )
                commentRow = tkn(2:end);
                isDate = false;
            elseif contains(ident, "Units", "ignoreCase", true)
                isDate = false;
            elseif isstring(opt.SkipRows) ...
                    && any(strlength(regexp(ident, opt.SkipRows, "match", "once"))>0)
                isDate = false;
            elseif startsWith(ident, "%") || isempty(ident) || strlength(ident)==0
                isDate = false;
            end

            if ~isDate
                here_moveToNextEol( );
            end
        end%

        return


            function here_moveToNextEol( )
                if ~isempty(eol)
                    file(eol) = ' ';
                    start = eol + 1;
                else
                    file = '';
                end
            end%


            function flag = here_testNameRow( )
                if isNameRowDone
                    flag = false;
                    return
                elseif isnumeric(opt.NamesHeader) && isequal(opt.NamesHeader, rowCount)
                    flag = true;
                    return
                elseif validate.text(opt.NamesHeader) && any(lower(opt.NamesHeader)==lower(opt.NamesHeader))
                    flag = true;
                    return
                end
                flag = false;
            end%


            function flag = here_testCommentsHeader( )
                if isnumeric(opt.CommentsHeader) && any(opt.CommentsHeader==rowCount)
                    flag = true;
                    return
                elseif validate.text(opt.CommentsHeader) && any(lower(ident)==lower(opt.CommentsHeader))
                    flag = true;
                    return
                end
                flag = false;
            end%
    end%




    function [data, inxMissing, datesColumn] = here_readNumericData( )
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
        for n = textual.stringify(opt.RemoveFromData)
            if strlength(n)>0
                file = replace(file, n, "");
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




    function [dates, inxNaDates] = here_parseDates( )
        numDates = numel(datesColumn);
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
                        "Option EnforceFrequency must be specified whenever DateFormat=""ISO""."
                    ]);
                end
                dates(~inxEmptyDates) ...
                    = dater.fromIsoString(opt.EnforceFrequency, string(datesColumn(~inxEmptyDates)));
            else
                dates(~inxEmptyDates) = str2dat( ...
                    datesColumn(~inxEmptyDates) ...
                    , "dateFormat", opt.DateFormat ...
                    , "months", opt.Months ...
                    , "enforceFrequency", opt.EnforceFrequency ...
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




    function [outputDb, namesCreated] = here_populateDatabank(outputDb)
        TEMPLATE_SERIES = Series();
        count = 0;
        lenNameRow = numel(nameRow);
        seriesUserdataList = fieldnames(seriesUserdata);
        numSeriesUserData = numel(seriesUserdataList);
        namesCreated = string.empty(1, 0);
        while count<lenNameRow
            name = nameRow(count+1);
            if numSeriesUserData>0
                thisUserData = here_createSeriesUserdata( );
            end
            if strlength(name)==0
                % Skip columns with empty names
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
                    comment__ = commentRow(count+(1:numColumns));
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
            namesCreated = [namesCreated, string(name)];
            count = count + numColumns;
        end

        return


        function userData = here_createSeriesUserdata( )
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




    function here_changeNames( )
        % Apply user function(s) to each name.
        if ~isempty(opt.NameFunc)
            func = opt.NameFunc;
            if ~iscell(func)
                func = {func};
            end
            for ii = 1 : numel(nameRow)
                for jj = 1 : numel(func)
                    if isa(func{jj}, 'function_handle')
                        nameRow(ii) = func{jj}(nameRow(ii));
                    end
                end
            end
        end
        if ~isstring(nameRow)
            throw( exception.Base('Dbase:InvalidOptionNameFunc', 'error') );
        end
        if startsWith(opt.Case, "lower", "ignoreCase", true)
            nameRow = lower(nameRow);
        elseif startsWith(opt.Case, "upper", "ignoreCase", true)
            nameRow = upper(nameRow);
        end
    end%


    function here_checkNames( )
        inxEmpty = strlength(nameRow)==0;
        if isstruct(outputDb)
            inxValid = strlength(regexp(nameRow, "^[a-zA-Z]\w*$", "once", "match"))>0;
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

    function here_createUserdataField( )
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

%
% Local functions
%

function s = getSize(c)
% Read the size string 1-by-1-by-1 etc. as a vector.
% New style of saving size: [1-by-1-by-1].
% Old style of saving size: [1][1][1].
    %( 
    c = char(c);
    c = replace(c(2:end-1), '][', '-by-');
    s = reshape(sscanf(c, '%g-by-'), 1, []);
    %)
end%


function name = getUserdataFieldName(c)
    %(
    name = regexp(c, '\[([^\]]+)\]', 'once', 'tokens');
    if ~isempty(name)
        name = name{1};
    else
        name = '';
    end
    %)
end%

