function outputDatabank = fromCSV(fileName, varargin)
% fromCSV  Create databank by loading CSV file
%{
% ## Syntax ##
%
%
%     outputDatabank = databank.fromCSV(fileName, ...)
%
%
% ## Input Arguments ##
%
%
% __`fileName`__ [ char | cellstr ] 
% >
% Name of the Input CSV data file or a cell array of CSV file names that
% will be combined.
%
%
% ## Output Arguments ##
%
%
% __`outputDatabank`__ [ struct ]
% >
% Database created from the input CSV file(s).
%
%
% ## Options ##
%
%
% __`AddToDatabank`__ [ struct | Dictionary ]
% >
% Add the data loaded from the input file to an existing databank (struct
% or Dictionary); the format (Matlab class) of `AddToDatabank=` must comply
% with option `OutputType=`.
%
%
% __`Case=''`__ [ `'lower'` | `'upper'` | empty ] 
% >
% Change case of variable names.
%
%
% __`CommentRow={'Comment', 'Comments'}`__ [ char | cellstr | numeric ] 
% >
% Label at the start of row that will be used to create comments in time
% series.
%
%
% __`Continuous=false`__ [ false | `'Descending'` | `'Ascending'` ]
% >
% Indicate that dates are a continuous range, either acending or
% descending.
%
%
% __`DateFormat='YYYYFP'`__ [ char ] 
% >
% Format of dates in first column.
%
%
% __`Delimiter=','`__ [ char ] 
% >
% Delimiter separating the individual values (cells) in the CSV file; if
% different from a comma, all occurences of the delimiter will replaced
% with commas -- note that this will also affect text in comments.
%
%
% __`FirstDateOnly=false`__ [ `true` | `false` ] 
% >
% Read and parse only the first date string, and fill in the remaining
% dates assuming a range of consecutive dates.
%
%
% __`EnforceFrequency=false`__ [ Frequency | `false` ]
% >
% Advise frequency of dates; if empty, frequency will be automatically
% recognised.
%
%
% __`FreqLetters=@config`__ [ char | @config ] 
% >
% Letters representing frequency of dates in date column.
%
%
% __`InputFormat='auto'`__ [ `'auto'` | `'csv'` | `'xls'` ] 
% >
% Format of input data file; `'auto'` means the format will be determined
% by the file extension.
%
%
% __`NamesHeader=["", "Variables", "Time"]`__ [ string | numeric ] 
% >
% String, or an array of strings, that is at the beginning
% (in the first cell) of the row with variable names, or the line number at
% which the row with variable names appears (first row is numbered 1).
%
%
% __`NameFunc=[ ]`__ [ cell | function_handle | empty ] 
% >
% Function used to change or transform the variable names. If a cell array
% of function handles, each function will be applied in the given order.
%
%
% __`NaN="NaN"`__ [ string ] 
% >
% String representing missing observations (case insensitive).
%
%
% __`OutputType='struct'`__ [ `'struct'` | `'Dictionary'` ]
% >
% Format (Matlab class) of the output databank.
%
%
% __`Preprocess=[ ]`__ [ function_handle | cell | empty ] 
% >
% Apply this function, or cell array of functions, to the raw text file
% before parsing the data.
%
%
% __`Select={ }`__ [ char | cellstr | empty ] 
% >
% Only databank entries included on this list will be read in and returned
% in the output databank `outputDatabank`; entries not on this list will be
% discarded.
%
%
% __`SkipRows=[ ]`__ [ char | cellstr | numeric | empty ] 
% >
% Skip rows whose first cell matches the string or strings (regular
% expressions); or, skip a vector of row numbers.
%
%
% __`DatabankUserData=Inf`__ [ char | `Inf` ] 
% >
% Field name under which the databank-wide user data loaded from the CSV
% file (if they exist) will be stored in the output databank; `Inf` means
% the field name will be read from the CSV file (and will be thus identical
% to the originally saved databank).
%
%
% __`UserDataField='.'`__ [ char ] 
% >
% A leading character denoting user data fields for individual time series;
% if empty, no user data fields will be read in and created.
%
%
% __`UserDataFieldList={ }`__ [ cellstr | numeric | empty ] 
% >
% List of row headers, or vector of row numbers, that will be included as
% user data in each time series.
%
%
% ## Description ##
%
%
% Use the `'EnforeFrequency='` option whenever there is ambiguity in intepreting
% the date strings, and IRIS is not able to determine the frequency
% correctly (see Example).
%
% ### Structure of CSV data files_###
%
% The minimalist structure of a CSV data file has a leading row with
% variables names, a leading column with dates in the basic IRIS format, 
% and individual columns with numeric data:
%
%     |         |       Y |       P |
%     |---------|---------|---------|--
%     |  2010Q1 |       1 |      10 |
%     |  2010Q2 |       2 |      20 |
%     |         |         |         |
%
% You can add a comment row (must be placed before the data part, and start
% with a label 'Comment' in the first cell) that will also be read in and
% assigned as comments to the individual Series objects created in the
% output databank.
%
%     |         |       Y |       P |
%     |---------|---------|---------|--
%     | Comment |  Output |  Prices |
%     |  2010Q1 |       1 |      10 |
%     |  2010Q2 |       2 |      20 |
%     |         |         |         |
%
% You can use a different label in the first cell to denote a comment row;
% in that case you need to set the option `CommentRow=` accordingly.
%
% All CSV rows whose names start with a character specified in the option
% `UserDataField=` (a dot by default) will be added to output Series
% objects as fields of their user data.
%
%     |         |       Y |       P |
%     |---------|---------|---------|--
%     | Comment |  Output |  Prices |
%     | .Source |   Stat  |  IMFIFS |
%     | .Update | 17Feb11 | 01Feb11 |
%     | .Units  | Bil USD |  2010=1 |
%     |  2010Q1 |       1 |      10 |
%     |  2010Q2 |       2 |      20 |
%     |         |         |         |
%
%
% ## Example ##
%
%
% Typical example of using the `EnforeFrequency=` option is a quarterly
% databank with dates represented by the corresponding months, such as a
% sequence 2000-01-01, 2000-04-01, 2000-07-01, 2000-10-01, etc. In this
% case, you can use the following options:
%
%     d = databank.fromCSV( 'MyDataFile.csv', ...
%                           'DateFormat=', 'YYYY-MM-01', ...
%                           'EnforeFrequency=', Frequency.QUARTERLY );
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.fromCSV');
    addRequired(pp, 'fileName', @validate.list);

    addParameter(pp, 'AddToDatabank', [ ], @(x) isequal(x, [ ]) || validate.databank(x));
    addParameter(pp, {'Case', 'ChangeCase'}, '', @(x) isempty(x) || any(strcmpi(x, {'lower', 'upper'})));
    addParameter(pp, 'CommentRow', {'Comment', 'Comments'}, @(x) ischar(x) || iscellstr(x) || (isnumeric(x) && all(x==round(x)) && all(x>0)));
    addParameter(pp, 'Continuous', false, @(x) isequal(x, false) || any(strcmpi(x, {'Ascending', 'Descending'})));
    addParameter(pp, 'Delimiter', ', ', @(x) ischar(x) && numel(sprintf(x))==1);
    addParameter(pp, 'FirstDateOnly', false, @validate.logicalScalar);
    addParameter(pp, {'NamesHeader', 'NameRow', 'NamesRow', 'LeadingRow'}, ["", "Variables", "Time"], @(x) ischar(x) || isstring(x) || iscellstr(x) || validate.numericScalar(x));
    addParameter(pp, {'NameFunc', 'NamesFunc'}, [ ], @(x) isempty(x) || isfunc(x) || (iscell(x) && all(cellfun(@isfunc, x))));
    addParameter(pp, 'NaN', "NaN", @validate.stringScalar);
    addParameter(pp, 'OutputType', @auto, @(x) isequal(x, @auto) || validate.anyString(x, 'struct', 'Dictionary'));
    addParameter(pp, 'Preprocess', [ ], @(x) isempty(x) || isa(x, 'function_handle') || (iscell(x) && all(cellfun(@isfunc, x))));
    addParameter(pp, 'RemoveFromData', cell.empty(1, 0), @(x) iscellstr(x) || ischar(x) || isa(x, 'string'));
    addParameter(pp, 'Select', @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x));
    addParameter(pp, {'SkipRows', 'skiprow'}, '', @(x) isempty(x) || ischar(x) || iscellstr(x) || isnumeric(x));
    addParameter(pp, {'DatabankUserData', 'UserData'}, Inf, @(x) isequal(x, Inf) || (ischar(x) && isvarname(x)));
    addParameter(pp, 'UserDataField', '.', @(x) ischar(x) && isscalar(x));
    addParameter(pp, 'UserDataFieldList', { }, @(x) isempty(x) || iscellstr(x) || isnumeric(x));
    addParameter(pp, 'VariableNames', @auto, @(x) isequal(x, @auto) || validate.list(x));
    addDateOptions(pp);
end
parse(pp, fileName, varargin{:});
opt = pp.Options;
fileName = cellstr(fileName);

% Check consistency of options AddToDatabank= and OutputFormat=
outputDatabank = databank.backend.ensureTypeConsistency( ...
    opt.AddToDatabank, ...
    opt.OutputType ...
);

% Loop over all input databanks subcontracting `databank.fromCSV` and
% merging the resulting databanks in one.
if numel(fileName)>1
    numFileNames = numel(fileName);
    for i = 1 : numFileNames
        outputDatabank = databank.fromCSV( ...
            fileName(i), varargin{:}, ...
            'AddToDatabank=', outputDatabank ...
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


% /////////////////////////////////////////////////////////////////////////
hereReadFile( );
% /////////////////////////////////////////////////////////////////////////


% Replace non-comma delimiter with comma; applies only to CSV files
if ~strcmp(opt.Delimiter, ',')
    file = strrep(file, sprintf(opt.Delimiter), ',');
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


% /////////////////////////////////////////////////////////////////////////
hereReadHeaders( );
% /////////////////////////////////////////////////////////////////////////


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


% /////////////////////////////////////////////////////////////////////////
[data, inxMissing, dateCol] = hereReadNumericData( );
% /////////////////////////////////////////////////////////////////////////


% **Parse dates**
[dates, inxNaNDates] = hereParseDates( );

if ~isempty(dates)
    maxDate = max(dates);
    minDate = min(dates);
    numPeriods = 1 + round(maxDate - minDate);
    posDates = 1 + round(dates - minDate);
else
    numPeriods = 0;
    posDates = [ ];
    minDate = DateWrapper(NaN);
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


% /////////////////////////////////////////////////////////////////////////
% **Create Database**
% Populate the output databank with Series and numeric data
herePopulateDatabank( );
% /////////////////////////////////////////////////////////////////////////

return


    function hereReadFile( )
        % Read CSV file to char
        file = file2char(fileName);
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
        if ischar(opt.CommentRow)
            opt.CommentRow = {opt.CommentRow};
        end
    end%




    function hereReadHeaders( )
        strFindFunc = @(x, y) ~isempty(strfind(lower(x), y));
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
            % @@@@@ MOSW
            tkn = regexp(line, '[^",]*,|[^",]*$|"[^"]*",|"[^"]*"$', 'match');
            % Remove separating commas from the end of cells.
            tkn = regexprep(tkn, ',$', '', 'once');
            % Remove double quotes from beginning and end of each cell.
            tkn = regexprep(tkn, '^"', '', 'once');
            tkn = regexprep(tkn, '"$', '', 'once');
            
            if isempty(tkn) || all(cellfun(@isempty, tkn))
                ident = '%';
            else
                ident = strrep(tkn{1}, '->', '');
                ident = strtrim(ident);
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
            
            % ## User Data Fields ##
            % Some of the user data fields can be reused as comments, hence
            % do this before anything else
            if strncmp(ident, opt.UserDataField, 1) ...
                    ...
                    || ( ...
                        iscellstr(opt.UserDataFieldList) ...
                        && ~isempty(opt.UserDataFieldList) ...
                        && any(strcmpi(ident, opt.UserDataFieldList)) ...
                    ) ...
                    ...
                    || ( ...
                        isnumeric(opt.UserDataFieldList) ...
                        && ~isempty(opt.UserDataFieldList) ...
                        && any(rowCount==opt.UserDataFieldList(:).') ...
                    )
                fieldName = regexprep(ident, '\W', '');
                fieldName = matlab.lang.makeUniqueStrings(fieldName);
                try %#ok<TRYNC>
                    seriesUserdata.(fieldName) = tkn(2:end);
                end
                isDate = false;
            end

            if strncmp(ident, '%', 1) || isempty(ident)
                isDate = false;
            elseif strFindFunc(ident, 'userdata')
                databankUserDataFieldName = getUserdataFieldName(tkn{1});
                databankUserDataValueString = tkn{2};
                isUserData = true;
                isDate = false;
            elseif strFindFunc(ident, 'class[size]')
                classRow = tkn(2:end);
                isDate = false;
            elseif hereTestCommentRow( )
                cmtRow = tkn(2:end);
                isDate = false;
            elseif ~isempty(strfind(lower(ident), 'units'))
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
                elseif any(strcmpi(ident, opt.NamesHeader))
                    flag = true;
                    return
                end
                flag = false;
            end%


            function flag = hereTestCommentRow( )
                if isequal(opt.CommentRow, rowCount)
                    flag = true;
                    return
                elseif any(strcmpi(ident, opt.CommentRow))
                    flag = true;
                    return
                end
                flag = false;
            end%
    end%




    function [data, inxMissing, dateCol] = hereReadNumericData( )
        data = double.empty(0, 0);
        inxMissing = logical.empty(1, 0);
        dateCol = cell.empty(1, 0);
        if isempty(file)
            return
        end
        % Read date column (first column).
        dateCol = regexp(file, '^.*?(,|$)', 'match', 'lineanchors');
        dateCol = strtrim(dateCol);
        dateCol = strrep(dateCol, ',', '');
        
        % Remove leading or trailing single or double quotes.
        % Some programs save any text cells with single or double quotes.
        dateCol = regexprep(dateCol, '^["'']', '');
        dateCol = regexprep(dateCol, '["'']$', '');
        
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
            list = opt.RemoveFromData;
            if ~iscellstr(list)
                list = cellstr(list);
            end
            for i = 1 : numel(list)
                file = strrep(file, list{i}, '');
            end
        end

        % Read numeric data; empty cells will be treated either as `NaN` or
        % `NaN+NaNi` depending on the presence or absence of complex
        % numbers in the rest of that particular row.
        data = textscan( file, '', -1, ...
                         'Delimiter', ',', 'WhiteSpace', whiteSpace, ...
                         'HeaderLines', 0, 'HeaderColumns', 1, 'EmptyValue', -Inf, ...
                         'CommentStyle', 'Matlab', 'CollectOutput', true );
        if isempty(data)
            throw( exception.Base('Dbase:InvalidLoadFormat', 'error'), fileName ); %#ok<GTARG>
        end
        data = data{1};
        inxMissing = false(size(data));
        % The value `-Inf` indicates a possible missing value (but may be a
        % genuine `-Inf`, too). Re-read the table again, with missing
        % values represented by `NaN` this time to pin down missing values.
        isMaybeMissing = real(data)==-Inf;
        if any(isMaybeMissing(:))
            data1 = textscan( file, '', -1, ...
                              'Delimiter', ',', 'WhiteSpace', whiteSpace, ...
                              'HeaderLines', 0, 'HeaderColumns', 1, 'EmptyValue', NaN, ...
                              'CommentStyle', 'Matlab', 'CollectOutput', true );
            data1 = data1{1};
            isMaybeMissing1 = isnan(real(data1));
            inxMissing(isMaybeMissing & isMaybeMissing1) = true;
        end
        if strcmpi(opt.Continuous, 'Descending')
            data = flipud(data);
            inxMissing = flipud(inxMissing);
            dateCol = dateCol(end:-1:1);
        end
    end% 




    function [dates, inxNaNDates] = hereParseDates( )
        numDates = numel(dateCol);
        dates = DateWrapper(nan(1, numDates));
        dateCol = dateCol(1:min(end, size(data, 1)));
        if ~isempty(dateCol)
            if strcmpi(opt.Continuous, 'Ascending')
                dateCol(2:end) = {''};
            elseif strcmpi(opt.Continuous, 'Descending')
                dateCol(1:end-1) = {''};
            end
            % Rows with empty dates.
            inxEmptyDates = cellfun(@isempty, dateCol);
        end
        % Convert date strings
        if ~isempty(dateCol) && ~all(inxEmptyDates)
            dates(~inxEmptyDates) = str2dat( ...
                dateCol(~inxEmptyDates), ...
                'DateFormat=', opt.DateFormat, ...
                'Months=', opt.Months, ...
                'EnforceFrequency=', opt.EnforceFrequency, ...
                'FreqLetters=', opt.FreqLetters ...
            );
            if strcmpi(opt.Continuous, 'Ascending')
                dates(2:end) = dates(1) + (1 : numDates-1);
            elseif strcmpi(opt.Continuous, 'Descending')
                dates(end-1:-1:1) = dates(end) - (1 : numDates-1);
            end
        end
        % Exclude NaN dates (that includes also empty dates), but keep all data
        % rows; this is because of non-time-series data
        inxNaNDates = isnan(dates);
        dates(inxNaNDates) = [ ];
        
        % Homogeneous frequency check
        if ~isempty(dates)
            freqDates = dater.getFrequency(dates);
            DateWrapper.checkMixedFrequency(freqDates, [ ], 'in CSV data files');
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
                % Numeric data.
                numColumns = prod(tmpSize(2:end));
                data__ = reshape(data(1:tmpSize(1), count+(1:numColumns)), tmpSize);
                inxMissing__ = reshape(inxMissing(1:tmpSize(1), count+(1:numColumns)), tmpSize);
                data__(inxMissing__) = NaN;
                fnClass = str2func(cls);
                newEntry = fnClass(data__);
            end
            outputDatabank.(char(name)) = newEntry;
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
        if strcmpi(opt.Case, 'lower')
            nameRow = lower(nameRow);
        elseif strcmpi(opt.Case, 'upper')
            nameRow = upper(nameRow);
        end
    end% 




    function hereCheckNames( )
        inxEmpty = cellfun(@isempty, nameRow);
        if isstruct(outputDatabank)
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
            nameRow(inxToGenerate) = genvarname(nameRow(inxToGenerate), nameRow(inxToProtect)); %#ok<DEPGENAM>
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
        outputDatabank.(char(databankUserDataFieldName)) = userDataField;
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

