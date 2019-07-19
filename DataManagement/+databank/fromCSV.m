function d = fromCSV(varargin)
% fromCSV  Create databank by loading CSV file
%{
% ## Syntax ##
%
%     outputDatabank = databank.fromCSV(fileName, ...)
%     outputDatabank = databank.fromCSV(inputDatabank, fileName, ...)
%
%
% ## Input Arguments ##
%
% **`fileName`** [ char | cellstr ] - 
% Name of the Input CSV data file or a cell array of CSV file names that
% will be combined.
%
% **`inputDatabank`** [ struct ] -
% An existing databank (struct) to which the new entries from the input CSV
% data file entries will be added.
%
%
% ## Output Arguments ##
%
% **`outputDatabank`** [ struct ] -
% Database created from the input CSV file(s).
%
%
% ## Options ##
%
% **`Case=''`** [ `'lower'` | `'upper'` | empty ] - 
% Change case of variable names.
%
% **`CommentRow={'Comment', 'Comments'}`** [ char | cellstr ] - 
% Label at the start of row that will be used to create comments in time
% series.
%
% **`Continuous=false`** [ false | `'Descending'` | `'Ascending'` ] -
% Indicate that dates are a continuous range, either acending or
% descending.
%
% **`DateFormat='YYYYFP'`** [ char ] - 
% Format of dates in first column.
%
% **`Delimiter=','`** [ char ] - 
% Delimiter separating the individual values (cells) in the CSV file; if
% different from a comma, all occurences of the delimiter will replaced
% with commas -- note that this will also affect text in comments.
%
% **`FirstDateOnly=false`** [ `true` | `false` ] - 
% Read and parse only the first date string, and fill in the remaining
% dates assuming a range of consecutive dates.
%
% **`EnforceFrequency=false`** [ Frequency | `false` ] -
% Advise frequency of dates; if empty, frequency will be automatically
% recognised.
%
% **`FreqLetters=@config`** [ char | @config ] - 
% Letters representing frequency of dates in date column.
%
% **`InputFormat='auto'`** [ `'auto'` | `'csv'` | `'xls'` ] - 
% Format of input data file; `'auto'` means the format will be determined
% by the file extension.
%
% **`NameRow={'', Variables'}`** [ char | cellstr | numeric ] - 
% String, or cell array of possible strings, that is found at the beginning
% (in the first cell) of the row with variable names, or the line number at
% which the row with variable names appears (first row is numbered 1).
%
% **`NameFunc=[ ]`** [ cell | function_handle | empty ] - 
% Function used to change or transform the variable names. If a cell array
% of function handles, each function will be applied in the given order.
%
% **`NaN='NaN'`** [ char ] - 
% String representing missing observations (case insensitive).
%
% **`Preprocess=[ ]`** [ function_handle | cell | empty ] - 
% Apply this function, or cell array of functions, to the raw text file
% before parsing the data.
%
% **`Select={ }`** [ char | cellstr | empty ] - 
% Only databank entries included on this list will be read in and returned
% in the output databank `outputDatabank`; entries not on this list will be
% discarded.
%
% **`SkipRows=[ ]`** [ char | cellstr | numeric | empty ] - 
% Skip rows whose first cell matches the string or strings (regular
% expressions); or, skip a vector of row numbers.
%
% **`UserData=Inf`** [ char | `Inf` ] - 
% Field name under which the databank
% userdata loaded from the CSV file (if they exist) will be stored in the
% output databank; `Inf` means the field name will be read from the CSV
% file (and will be thus identical to the originally saved databank).
%
% **`UserDataField='.'`** [ char ] - 
% A leading character denoting userdata fields for individual time series;
% if empty, no userdata fields will be read in and created.
%
% **`UserDataFieldList={ }`** [ cellstr | numeric | empty ] - 
% List of row headers, or vector of row numbers, that will be included as
% user data in each time series.
%
%
% ## Description ##
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
% in that case you need to set the option `'commentRow='` accordingly.
%
% All CSV rows whose names start with a character specified in the option
% `'userdataField='` (a dot by default) will be added to output Series
% objects as fields of their userdata.
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
% Typical example of using the `'EnforeFrequency='` option is a quarterly
% databank with dates represented by the corresponding months, such as a
% sequence 2000-01-01, 2000-04-01, 2000-07-01, 2000-10-01, etc. In this
% case, you can use the following options:
%
%     d = databank.fromCSV( 'MyDataFile.csv', ...
%                           'DateFormat=', 'YYYY-MM-01', ...
%                           'EnforeFrequency=', Frequency.QUARTERLY );
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

if isstruct(varargin{1})
    d = varargin{1};
    varargin(1) = [ ];
else
    d = struct( );
end

fileName = varargin{1};
varargin(1) = [ ];

persistent parser
if isempty(parser)
    parser = extend.InputParser('dbase.dbload');
    addRequired(parser, 'InputDatabank', @isstruct);
    addRequired(parser, 'FileName', @Valid.list);
    addParameter(parser, {'case', 'changecase'}, '', @(x) isempty(x) || any(strcmpi(x, {'lower', 'upper'})));
    addParameter(parser, 'CommentRow', {'Comment', 'Comments'}, @(x) ischar(x) || iscellstr(x) || (isnumeric(x) && all(x==round(x)) && all(x>0)));
    addParameter(parser, 'Continuous', false, @(x) isequal(x, false) || any(strcmpi(x, {'Ascending', 'Descending'})));
    addParameter(parser, 'Delimiter', ', ', @(x) ischar(x) && numel(sprintf(x))==1);
    addParameter(parser, 'FirstDateOnly', false, @Valid.logicalScalar);
    addParameter(parser, 'inputformat', 'auto', @(x) ischar(x) && (strcmpi(x, 'auto') || strcmpi(x, 'csv') || strncmpi(x, 'xl', 2)));
    addParameter(parser, {'NameRow', 'NamesRow', 'LeadingRow'}, {'', 'Variables'}, @(x) ischar(x) || iscellstr(x) || Valid.numericScalar(x));
    addParameter(parser, {'NameFunc', 'NamesFunc'}, [ ], @(x) isempty(x) || isfunc(x) || (iscell(x) && all(cellfun(@isfunc, x))));
    addParameter(parser, {'EnforceFrequency', 'Freq'}, false, @(x) isempty(x) || isequal(x, false) || (ischar(x) && strcmpi(x, 'daily')) || (numel(x)==1 && isnan(x)) || (isnumeric(x) && length(x)==1 && any(x==[0, 1, 2, 4, 6, 12, 52, 365])));
    addParameter(parser, 'NaN', 'NaN', @(x) ischar(x));
    addParameter(parser, 'Preprocess', [ ], @(x) isempty(x) || isa(x, 'function_handel') || (iscell(x) && all(cellfun(@isfunc, x))));
    addParameter(parser, 'RemoveFromData', cell.empty(1, 0), @(x) iscellstr(x) || ischar(x) || isa(x, 'string'));
    addParameter(parser, 'select', @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x));
    addParameter(parser, {'skiprows', 'skiprow'}, '', @(x) isempty(x) || ischar(x) || iscellstr(x) || isnumeric(x));
    addParameter(parser, 'userdata', Inf, @(x) isequal(x, Inf) || (ischar(x) && isvarname(x)));
    addParameter(parser, 'userdatafield', '.', @(x) ischar(x) && isscalar(x));
    addParameter(parser, 'userdatafieldlist', { }, @(x) isempty(x) || iscellstr(x) || isnumeric(x));
    addParameter(parser, 'VariableNames', @auto, @(x) isequal(x, @auto) || Valid.list(x));
    addDateOptions(parser);
end
parse(parser, d, fileName, varargin{:});
opt = parser.Options;

% Loop over all input databanks subcontracting `dbload` and merging the
% resulting databanks in one.
if iscellstr(fileName)
    numOfFileNames = length(fileName);
    for i = 1 : numOfFileNames
        d = dbload(d, fileName{i}, varargin{:});
        return
    end
end

if isequal(opt.FirstDateOnly, true)
    opt.Continuous = 'Ascending';
end

% Pre-process options
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
dbUserdata = '';
dbUserdataFieldName = '';
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
if ~isequal(opt.select, @all)
    if ischar(opt.select)
        opt.select = regexp(opt.select, '\w+', 'match');
    end
    for i = 1 : numel(nameRow)
        if ~any(strcmp(nameRow{i}, opt.select))
            nameRow{i} = ''; %#ok<AGROW>
        end
    end
end


% /////////////////////////////////////////////////////////////////////////
[data, ixMissing, dateCol] = readNumericData( );
% /////////////////////////////////////////////////////////////////////////


% **Parse dates**
[dates, inxNaNDates] = parseDates( );

if ~isempty(dates)
    maxDate = max(dates);
    minDate = min(dates);
    numPeriods = 1 + round(maxDate - minDate);
    posOfDates = 1 + round(dates - minDate);
else
    numPeriods = 0;
    posOfDates = [ ];
    minDate = DateWrapper(NaN);
end

% Change variable names.
% * Apply user function to variables names.
% * Convert variable name case.
changeNames( );

% Make sure the databank entry names are all valid and unique Matlab names.
checkNames( );

% Populated the userdata field; this is NOT Series userdata, but a
% separate entry in the output databank.
if ~isempty(opt.userdata) && isUserData
    createUserdataField( );
end


% /////////////////////////////////////////////////////////////////////////
% **Create Database**
% Populate the output databank with Series and numeric data
populateDatabase( );
% /////////////////////////////////////////////////////////////////////////

return


    function hereReadFile( )
        % Read CSV file to char
        file = file2char(fileName);
        file = textfun.converteols(file);
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
    end


    function hereProcessOptions( )
        % Headers for rows to be skipped.
        if ischar(opt.skiprows)
            opt.skiprows = {opt.skiprows};
        end
        if ~isempty(opt.skiprows) && ~isnumeric(opt.skiprows)
            for ii = 1 : numel(opt.skiprows)
                if isempty(opt.skiprows{ii})
                    continue
                end
                if opt.skiprows{ii}(1)~='^'
                    opt.skiprows{ii} = ['^', opt.skiprows{ii}];
                end
                if opt.skiprows{ii}(end)~='$'
                    opt.skiprows{ii} = [opt.skiprows{ii}, '$'];
                end
            end
        end
        % Headers for comment rows
        if ischar(opt.CommentRow)
            opt.CommentRow = {opt.CommentRow};
        end
    end 


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
            if Valid.numericScalar(opt.NameRow) && rowCount<opt.NameRow
                hereMoveToNextEol( );
                continue
            end
            
            % Read individual comma-separated cells on the current line. Capture the
            % entire match (including separating commas and double quotes), not only
            % tokens -- this is a workaround for a bug in Octave.
            % @@@@@ MOSW
            tkn = regexp(line, ...
                '[^",]*,|[^",]*$|"[^"]*",|"[^"]*"$', 'match');
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
            
            if isnumeric(opt.skiprows) && any(rowCount==opt.skiprows)
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
            
            % Userdata fields
            %-----------------
            % Some of the userdata fields can be reused as comments, hence do this
            % before anything else.
            if strncmp(ident, opt.userdatafield, 1) ...
                    ...
                    || ( ...
                    iscellstr(opt.userdatafieldlist) ...
                    && ~isempty(opt.userdatafieldlist) ...
                    && any(strcmpi(ident, opt.userdatafieldlist)) ...
                    ) ...
                    ...
                    || ( ...
                    isnumeric(opt.userdatafieldlist) ...
                    && ~isempty(opt.userdatafieldlist) ...
                    && any(rowCount==opt.userdatafieldlist(:).') ...
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
                dbUserdataFieldName = getUserdataFieldName(tkn{1});
                dbUserdata = tkn{2};
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
            elseif ~isnumeric(opt.skiprows) ...
                    && any(~cellfun(@isempty, regexp(ident, opt.skiprows)))
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
                elseif isequal(opt.NameRow, rowCount)
                    flag = true;
                    return
                elseif any(strcmpi(ident, opt.NameRow))
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




    function [data, ixMissing, dateCol] = readNumericData( )
        data = double.empty(0, 0);
        ixMissing = logical.empty(1, 0);
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
        file = lower(file);
        file = strrep(file, ' ', '');
        opt.NaN = strtrim(lower(opt.NaN));
        
        % When replacing user-defined NaNs, there can be in theory conflict with
        % date strings. We do not resolve this conflict because it is not very
        % likely.
        if strcmp(opt.NaN, 'nan')
            % Remove quotes from quoted NaNs.
            file = strrep(file, '"nan"', 'nan');
        else
            % We cannot have multiple NaN strings because of the way `strrep` handles
            % repeated patterns and because `strrep` is not able to detect word
            % boundaries. Handle quoted NaNs first.
            file = strrep(file, ['"', opt.NaN, '"'], 'NaN');
			if strcmp('.', opt.NaN)
				file = regexprep(file, ...
                    ['(?<=,)(\', opt.NaN, ')(?=(,|\n|\r))'], ...
                    'NaN');
			else
				file = strrep(file, opt.NaN, 'NaN');
			end
        end
        
        % Replace empty character cells with numeric NaNs.
        file = strrep(file, '""', 'NaN');
        % Replace date highlights with numeric NaNs.
        file = strrep(file, '"***"', 'NaN');
        % Define white spaces.
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
        ixMissing = false(size(data));
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
            ixMissing(isMaybeMissing & isMaybeMissing1) = true;
        end
        if strcmpi(opt.Continuous, 'Descending')
            data = flipud(data);
            ixMissing = flipud(ixMissing);
            dateCol = dateCol(end:-1:1);
        end
    end% 




    function [dates, inxNaNDates] = parseDates( )
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
            dates(~inxEmptyDates) = str2dat(dateCol(~inxEmptyDates), ...
                'DateFormat=', opt.DateFormat, ...
                'EnforceFrequency=', opt.EnforceFrequency, ...
                'FreqLetters=', opt.FreqLetters);
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
            freqDates = DateWrapper.getFrequencyAsNumeric(dates);
            DateWrapper.checkMixedFrequency(freqDates, [ ], 'in CSV data files');
        end
    end% 




    function populateDatabase( )
        TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
        TEMPLATE_SERIES = TIME_SERIES_CONSTRUCTOR( );
        count = 0;
        lenOfNameRow = numel(nameRow);
        seriesUserdataList = fieldnames(seriesUserdata);
        numOfSeriesUserData = numel(seriesUserdataList);
        while count<lenOfNameRow
            name = nameRow{count+1};
            if numOfSeriesUserData>0
                thisUserData = createSeriesUserdata( );
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
                % Series data.
                if isempty(tmpSize)
                    tmpSize = [Inf, 1];
                end
                numOfColumns = prod(tmpSize(2:end));
                if ~isempty(data)
                    if isreal(data(~inxNaNDates, count+(1:numOfColumns)))
                        unit = 1;
                    else
                        unit = 1 + 1i;
                    end
                    iData = nan(numPeriods, numOfColumns)*unit;
                    iMiss = false(numPeriods, numOfColumns);
                    iData(posOfDates, :) = data(~inxNaNDates, count+(1:numOfColumns));
                    iMiss(posOfDates, :) = ixMissing(~inxNaNDates, count+(1:numOfColumns));
                    iData(iMiss) = NaN*unit;
                    iData = reshape(iData, [numPeriods, tmpSize(2:end)]);
                    cmt = cmtRow(count+(1:numOfColumns));
                    cmt = reshape(cmt, [1, tmpSize(2:end)]);
                    d.(name) = replace(TEMPLATE_SERIES, iData, minDate, cmt);
                else
                    % Create an empty Series object with proper 2nd and higher
                    % dimensions.
                    iData = zeros([0, tmpSize(2:end)]);
                    d.(name) = replace(TEMPLATE_SERIES, iData, NaN, '');
                end
                if numOfSeriesUserData>0
                    d.(name) = userdata(d.(name), thisUserData);
                end
            elseif ~isempty(tmpSize)
                % Numeric data.
                numOfColumns = prod(tmpSize(2:end));
                iData = reshape(data(1:tmpSize(1), count+(1:numOfColumns)), tmpSize);
                iMiss = reshape(ixMissing(1:tmpSize(1), count+(1:numOfColumns)), tmpSize);
                iData(iMiss) = NaN;
                % Convert to the right numeric class.
                if true % ##### MOSW
                    fnClass = str2func(cls);
                else
                    fnClass = mosw.str2func(cls); %#ok<UNRCH>
                end
                d.(name) = fnClass(iData);
            end
            count = count + numOfColumns;
        end
        
        return
        
        
        
        
        function userData = createSeriesUserdata( )
            userData = struct( );
            for ii = 1 : numOfSeriesUserData
                try
                    userData.(seriesUserdataList{ii}) = ...
                        seriesUserdata.(seriesUserdataList{ii}){count+1};
                catch %#ok<CTCH>
                    userData.(seriesUserdataList{ii}) = '';
                end
            end
        end
    end%




    function changeNames( )
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
        if strcmpi(opt.case, 'lower')
            nameRow = lower(nameRow);
        elseif strcmpi(opt.case, 'upper')
            nameRow = upper(nameRow);
        end
    end% 




    function checkNames( )
        ixEmpty = cellfun(@isempty, nameRow);
        ixValid = cellfun(@isvarname, nameRow);
        % Index of non-empty, invalid names that need to be regenerated.
        ixGen = ~ixEmpty & ~ixValid;
        % Index of valid names that will be protected.
        ixProtect = ~ixEmpty & ixValid;
        % `genvarname` now guarantees uniqueness of names by appending `1`, `2`, 
        % etc. at the end of the string; did not use to be the case in older
        % versions of Matlab.
        nameRow(ixGen) = genvarname(nameRow(ixGen), nameRow(ixProtect)); %#ok<DEPGENAM>
    end%




    function createUserdataField( )
        if ischar(opt.userdata) || isempty(dbUserdataFieldName)
            dbUserdataFieldName = opt.userdata;
        end
        try
            d.(dbUserdataFieldName) = eval(dbUserdata);
        catch err
            throw( exception.Base('Dbase:ErrorLoadingUserData', 'error'), ...
                   fileName, err.message ); %#ok<GTARG>
        end
    end%
end




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
