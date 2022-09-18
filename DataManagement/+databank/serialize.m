
function [c, listSerialized] = serialize(inputDb, varargin)

FN_PRINT_SIZE = @(s) [ '[', sprintf('%g', s(1)), sprintf('-by-%g', s(2:end)), ']' ];

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.serialize');
    addRequired(pp, 'inputDb', @validate.databank);
    addOptional(pp, 'dates', Inf, @(x) isequal(x, Inf) || validate.date(x));

    addParameter(pp, {'NamesHeader', 'VariablesHeader'}, 'Variables ->', @(x) validate.string(x) && ~contains(x, ["'", """"]));
    addParameter(pp, 'TargetNames', [], @(x) isempty(x) || isa(x, 'function_handle'));
    addParameter(pp, 'ClassHeader', 'Class[Size] ->', @(x) validate.string(x) && ~contains(x, ["'", """"]));
    addParameter(pp, 'Class', true, @validate.logicalScalar);
    addParameter(pp, {'Comments', 'Comment'}, true, @validate.logicalScalar);
    addParameter(pp, 'CommentsHeader', 'Comments ->', @(x) validate.string(x) && ~contains(x, ["'", """"]));
    addParameter(pp, {'Decimals', 'Decimal'}, [ ], @(x) isempty(x) || validate.numericScalar(x));
    addParameter(pp, 'Format', '%.8e', @(x) validate.string(x) && startsWith(x, "%") && ~contains(x, ["$", "-"]));
    addParameter(pp, 'MatchFreq', false, @validate.logicalScalar);
    addParameter(pp, 'Nan', 'NaN', @validate.string);
    addParameter(pp, 'UserDataFields', cell.empty(1, 0), @(x) iscellstr(x) || ischar(x) || isstring(x));
    addParameter(pp, 'UnitsHeader', 'Units ->', @(x) validate.string(x) && ~contains(x, ["'", """"]));
    addParameter(pp, 'Delimiter', ',', @validate.string);
    addParameter(pp, 'QuoteStrings', true, @validate.logicalScalar);
    addParameter(pp, 'SourceNames', Inf, @(x) isequal(x, Inf) || isequal(x, @all) || isstring(x));

    addDateOptions(pp);
end
%)
opt = parse(pp, inputDb, varargin{:});
dates = pp.Results.dates;

% Set up the formatting string
if isempty(opt.Decimals)
    format = opt.Format;
else
    format = ['%.', sprintf('%g', opt.Decimals), 'f'];
end

opt.UserDataFields = reshape(string(opt.UserDataFields), 1, []);

%--------------------------------------------------------------------------

% TODO: Implement -Inf:date, date:Inf
if isequal(dates, Inf) || isequal(dates, [-Inf, Inf])
    dates = databank.range(inputDb, "sourceNames", opt.SourceNames);
    if iscell(dates)
        exception.error([
            "Databank:CannotSaveMixedFrequencies"
            "Proper date range needs to be specified when saving databanks "
            "containing time series of multiple date frequencies."
        ]);
    end
    dates = double(dates);
    userFreq = dater.getFrequency(dates);
else
    dates = double(dates);
    dates = transpose(dates(:));
    if ~isempty(dates) && any(~freqcmp(dates))
        THIS_ERROR = { 'Databank:CannotSaveMixedFrequencies'
                       'Input date range is not allowed to include multiple date frequencies' };
        throw( exception.Base(THIS_ERROR, 'error') );
    end
end
isRange = all(round(diff(dates))==1);
if ~isempty(dates)
    userFreq = dater.getFrequency(dates);
else
    userFreq = NaN;
end

% Create saving struct
o = struct( );

% Handle custom delimiter
o.Delimiter = opt.Delimiter;

% Field names to save
namesToSave = databank.fieldNames(inputDb);
if ~isequal(opt.SourceNames, Inf) && ~isequal(opt.SourceNames, @all)
    namesToSave = intersect(namesToSave, textual.stringify(opt.SourceNames), 'stable');
end

% Initialise the data matrix as a N-by-1 vector of NaNs to mimic the Dates.
% This first column will fill in all entries.
numNamesToSave = numel(namesToSave);
data = cell(1, numNamesToSave); % nan(length(dates), 1);

nameRow = { };
classRow = { };
commentRow = { };
userDataFields = locallyInitializeUserDataFields(opt);
inxSerialized = false(size(namesToSave));

for i = 1 : numNamesToSave
    x = inputDb.(namesToSave{i});
    
    if isa(x, 'Series')
        freq__ = x.FrequencyAsNumeric;
        if opt.MatchFreq && any(userFreq~=freq__)
            continue
        end
        if isRange
            data__ = getDataFromTo(x, dates(1), dates(end));
        else
            data__ = getData(x, dates);
        end
        comment__ = cellstr(comment(x));
        class__ = class(x);
        userData__ = x.UserData;
    elseif isnumeric(x)
        data__ = x;
        comment__ = {''};
        class__ = class(x);
        userData__ = [ ];
    else
        continue
    end

    data__ = double(data__);
    sizeData__ = size(data__);
    data__ = data__(:, :);
    comment__ = comment__(1, :);
    [numRows__, numColumns__] = size(data__);
    if numColumns__==0
        continue
    end

    inxSerialized(i) = true;
    % Add data, expand first dimension if necessary.
    data{i} = data__;
    nameToAdd = namesToSave{i};
    if isa(opt.TargetNames, 'function_handle')
        nameToAdd = opt.TargetNames(nameToAdd);
    end
    nameRow{end+1} = char(nameToAdd); %#ok<AGROW>
    classRow{end+1} = [class__, FN_PRINT_SIZE(sizeData__)]; %#ok<AGROW>

    if numColumns__>1
        nameRow(end+(1:numColumns__-1)) = {''}; %#ok<AGROW>
        classRow(end+(1:numColumns__-1)) = {''}; %#ok<AGROW>
    end
    if numColumns__>size(comment__, 2)
        comment__(1, end+1:numColumns__) = {''};
    end 
    commentRow = [commentRow, comment__]; %#ok<AGROW>
    userDataFields = locallyAddUserDataFields(userDataFields, userData__, numColumns__);
end

%
% Convert serialized data to numeric array
%
data = data(inxSerialized);
numRows = cellfun(@(x) size(x, 1), data);
maxNumRows = max(numRows);
for i = reshape(find(numRows<maxNumRows), 1, [ ])
    data{i}(end+1:maxNumRows, :) = NaN;
end
data = [ data{:} ];

%
% Report names of serialized fields
%
listSerialized = reshape(string(namesToSave(inxSerialized)), 1, []);


% We need to remove double quotes from the date format string because the
% double quotes are used to delimit the CSV cells.
o.StrDat = dat2str(dates(:), opt);
o.StrDat = strrep(o.StrDat, '"', '');

o.Data = data;
o.NameRow = nameRow;
o.NanString = opt.Nan;
o.Format = format;
o.CommentRow = cell.empty(1, 0);
o.ClassRow = cell.empty(1, 0);

if opt.Comments
    o.CommentRow = commentRow;
end

if opt.Class
    o.ClassRow = classRow;
end

if ~isempty(fieldnames(userDataFields))
    o.UserDataFields = userDataFields;
end

c = locallySerialize(o, opt);

end%


%
% Local Functions
%

function userDataFields = locallyInitializeUserDataFields(opt)
    userDataFields = struct( );
    for n = opt.UserDataFields
        userDataFields.(n) = cell.empty(1, 0);
    end
end%


function udf = locallyAddUserDataFields(udf, ithUserData, numColumns)
    if numColumns==0
        return
    end
    for n = reshape(string(fieldnames(udf)), 1, [])
        valueToSave = repmat({''}, 1, numColumns);
        if isstruct(ithUserData) && isfield(ithUserData, n)
            fieldValue = ithUserData.(n); 
            if isstring(fieldValue) || ischar(fieldValue) || (iscellstr(fieldValue) && isscalar(fieldValue))
                valueToSave{1} = char(string(fieldValue));
            end
        end
        udf.(n) = [udf.(n), valueToSave];
    end
end%


function c = locallySerialize(oo, opt)
    nameRow = oo.NameRow;
    strDat = oo.StrDat;
    data = oo.Data;

    if isfield(oo, 'Delimiter')
        delimiter = oo.Delimiter;
    else
        delimiter = ', ';
    end

    formatString = '%s';
    if opt.QuoteStrings
        formatString = ['"', formatString, '"'];
    end

    if isfield(oo, 'UnitRow')
        unitRow = oo.UnitRow;
    else
        unitRow = cell.empty(1, 0);
    end

    if isfield(oo, 'NanString')
        naString = oo.NanString;
    else
        naString = 'NaN';
    end
    isNaString = ~strcmpi(naString, 'NaN');

    format = char(oo.Format);



    % Create an empty buffer
    c = '';

    c = [c, sprintf(formatString, opt.NamesHeader), herePrintCharCells(nameRow)];

    % Write comments
    if ~isempty(oo.CommentRow)
        c = [c, newline( ), sprintf(formatString, opt.CommentsHeader), herePrintCharCells(oo.CommentRow)];
    end

    % Write unit
    if ~isempty(unitRow)
        c = [c, newline( ), sprintf(formatString, opt.UnitsHeader), herePrintCharCells(unitRow)];
    end

    % Write class
    if ~isempty(oo.ClassRow)
        c = [ ...
            c, newline( ) ...
            , sprintf(formatString, opt.ClassHeader) ...
            , herePrintCharCells(oo.ClassRow) ...
        ];
    end

    % Write user data fields
    if isfield(oo, 'UserDataFields')
        for n = reshape(string(fieldnames(oo.UserDataFields)), 1, [])
            ithRow = oo.UserDataFields.(n);
            c = [
                c, newline( ) ...
                , sprintf(formatString, ['.', char(n)]) ...
                , herePrintCharCells(ithRow) ...
            ];
        end
    end

    % Handle escape characters.
    strDat = strrep(strDat, '\', '\\');
    strDat = strrep(strDat, '%', '%%');

    % Create format string fot the imaginary parts of data; they need to be
    % always printed with a plus or minus sign.
    imagFormat = [format, 'i'];
    if isempty(strfind(imagFormat, '%+')) && isempty(strfind(imagFormat, '%0+'))
        imagFormat = strrep(imagFormat, '%', '%+');
    end

    % Find columns that have at least one non-zero imag. These column will
    % be printed as complex numbers.
    numRows = size(data, 1);
    numColumns = size(data, 2);

    % Combine real and imag columns in an extended data matrix.
    xData = zeros(numRows, 2*numColumns);
    xData(:, 1:2:end) = real(data);
    data__ = imag(data);
    xData(:, 2:2:end) = data__;

    % Find imag columns and create positions of zero-only imag columns that
    % will be removed.
    iCol = any(data__ ~= 0, 1);
    removeCol = 2*(1 : numColumns);
    removeCol(iCol) = [ ];
    % Check for the occurence of imaginary NaNs.
    isImagNan = any(isnan(data__(:)));
    % Remove zero-only imag columns from the extended data matrix.
    xData(:, removeCol) = [ ];
    % Create a sequence of formats for one line.
    formatLine = cell(1, numColumns);
    % Format string for columns that have imaginary numbers.
    formatLine(iCol) = {[delimiter, format, imagFormat]};
    % Format string for columns that only have real numbers.
    formatLine(~iCol) = {[delimiter, format]};
    formatLine = [formatLine{:}];

    if isempty(strDat)
        % If there is no time series in the input database, create a vector 1:N in
        % the first column instead of dates.
        strDat = cellfun( ...
            @(x) sprintf('%g', x), num2cell(1:numRows), 'UniformOutput', false ...
        );
    end

    % Transpose data in cellData so that they are read correctly in sprintf.
    cellData = cell(1+size(xData, 2), numRows);
    numDates = numel(strDat);
    cellData(1, 1:numDates) = strDat(:);
    cellData(2:end, :) = num2cell(xData.');
    cc = sprintf(['\n', formatString, formatLine], cellData{:});

    % NaNi is never printed with the leading sign. Replace NaNi with +NaNi. We
    % should also control for the occurence of NaNi in date strings but we
    % don't as this is quite unlikely (and would not be easy).
    if isImagNan
        cc = strrep(cc, 'NaNi', '+NaNi');
    end

    % Replace NaNs in the date/data matrix with a user-supplied string. We
    % don't protect NaNs in date strings; these too will be replaced.
    if isNaString && string(naString)~="NaN"
        cc = replace(cc, "NaN", naString);
    end

    % Splice the headings and the data, and save the buffer. No need to put
    % a line break between `c` and `cc` because that the `cc` does start
    % with a line break.
    c = [c, cc];

    return


        function s = herePrintCharCells(c)
            s = '';
            if isempty(c) || ~iscellstr(c)
                return
            end
            s = sprintf([delimiter, formatString], c{:});
        end%
end%

