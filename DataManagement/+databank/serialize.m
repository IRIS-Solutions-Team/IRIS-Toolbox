function [c, listSerialized] = serialize(inputDatabank, varargin)
% serialize  Serialize databank entries to character vector
%{
% ## Syntax ##
%
%     [c, listSerialized] = databank.serialized(inputDatabank, dates, ...)
%
%
% ## Input Arguments ##
%
% __`inputDatabank`__ [ struct | Dictionary | containers.Map ] -
% Input databank whose time series and numeric entries will be serialized
% to a character vector.
%
%
% __`dates`__ [ DateWrapper | numeric | `Inf` ] -
% Dates at which time series entries will be serialized; `Inf` means the
% all encompassing range determined from all time series entries.
%
%
% ## Output Arguments ##
%
% __`c`__ [ char ] -
% Character vector serializing the `inputDatabank`.
%
%
% ## Options ##
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team


FN_PRINT_SIZE = @(s) [ '[', sprintf('%g', s(1)), sprintf('-by-%g', s(2:end)), ']' ];

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.serialize');
    addRequired(pp, 'inputDatabank', @validate.databank);
    addOptional(pp, 'dates', Inf, @(x) isequal(x, Inf) || DateWrapper.validateDateInput(x));

    addParameter(pp, {'NamesHeader', 'VariablesHeader'}, 'Variables ->', @(x) validate.string(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"')));
    addParameter(pp, 'ClassHeader', 'Class[Size] ->', @(x) validate.string(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"')));
    addParameter(pp, 'Class', true, @validate.logicalScalar);
    addParameter(pp, {'Comments', 'Comment'}, true, @validate.logicalScalar);
    addParameter(pp, 'CommentsHeader', 'Comments ->', @(x) validate.string(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"')));
    addParameter(pp, {'Decimals', 'Decimal'}, [ ], @(x) isempty(x) || validate.numericScalar(x));
    addParameter(pp, 'Format', '%.8e', @(x) validate.string(x) && ~isempty(x) && x(1)=='%' && isempty(strfind(x, '$')) && isempty(strfind(x, '-')));
    addParameter(pp, 'MatchFreq', false, @validate.logicalScalar);
    addParameter(pp, 'Nan', 'NaN', @validate.string);
    addParameter(pp, 'UserData', 'UserData', @(x) validate.string(x) && isvarname(x));
    addParameter(pp, 'UserDataFields', cell.empty(1, 0), @validate.list);
    addParameter(pp, 'UnitsHeader', 'Units ->', @(x) validate.string(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"')));
    addParameter(pp, 'Delimiter', ',', @validate.string);

    addDateOptions(pp);
end
%)
opt = parse(pp, inputDatabank, varargin{:});
dates = pp.Results.dates;

% Set up the formatting string
if isempty(opt.Decimals)
    format = opt.Format;
else
    format = ['%.', sprintf('%g', opt.Decimals), 'f'];
end

opt.UserDataFields = cellstr(opt.UserDataFields);

%--------------------------------------------------------------------------

% TODO: Implement -Inf:date, date:Inf
if isequal(dates, Inf) || isequal(dates, [-Inf, Inf])
    dates = databank.range(inputDatabank);
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

% Handle userdata first, and remove them from the database so that they are
% not processed as a regular field
if ~isempty(opt.UserData) && isfield(inputDatabank, opt.UserData)
    if isa(inputDatabank, 'containers.Map')
        o.UserData = inputDatabank(opt.UserData);
        o.UserDataFieldName = opt.UserData;
        inputDatabank = remove(inputDatabank, opt.UserData);
    else
        o.UserData = inputDatabank.(opt.UserData);
        o.UserDataFieldName = opt.UserData;
        inputDatabank = rmfield(inputDatabank, opt.UserData);
    end
end

% Handle custom delimiter
o.Delimiter = opt.Delimiter;

if isa(inputDatabank, 'containers.Map')
    list = keys(inputDatabank);
else
    list = fieldnames(inputDatabank).';
end

% Initialise the data matrix as a N-by-1 vector of NaNs to mimic the Dates.
% This first column will fill in all entries.
nList = numel(list);
data = cell(1, nList); % nan(length(dates), 1);

nameRow = { };
classRow = { };
commentRow = { };
userDataFields = hereCreateUserDataFields( );
inxSerialized = false(size(list));

for i = 1 : nList
    x = inputDatabank.(list{i});
    
    if isa(x, 'TimeSubscriptable')
        freq__ = x.FrequencyAsNumeric;
        if opt.MatchFreq && userFreq~=freq__
            continue
        end
        if isRange
            data__ = getDataFromTo(x, dates(1), dates(end));
        else
            data__ = getData(x, dates);
        end
        comment__ = comment(x);
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
    nameRow{end+1} = list{i}; %#ok<AGROW>
    classRow{end+1} = [class__, FN_PRINT_SIZE(sizeData__)]; %#ok<AGROW>

    if numColumns__>1
        nameRow(end+(1:numColumns__-1)) = {''}; %#ok<AGROW>
        classRow(end+(1:numColumns__-1)) = {''}; %#ok<AGROW>
    end
    if numColumns__>size(comment__, 2)
        comment__(1, end+1:numColumns__) = {''};
    end 
    commentRow = [commentRow, comment__]; %#ok<AGROW>
    hereAddUserDataFields(userData__, numColumns__);
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
listSerialized = list(inxSerialized);


% We need to remove double quotes from the date format string because the
% double quotes are used to delimit the CSV cells.
o.StrDat = dat2str(dates(:), opt);
o.StrDat = strrep(o.StrDat, '"', '');

o.Data = data;
o.NameRow = nameRow;
o.NanString = opt.Nan;
o.Format = format;
if opt.Comments
    o.CommentRow = commentRow;
end
if ~isempty(opt.UserDataFields)
    o.UserDataFields = userDataFields;
end
if opt.Class
    o.ClassRow = classRow;
end

c = hereSerialize(o, opt);

return


    function userDataFields = hereCreateUserDataFields( )
        userDataFields = struct( );
        for ii = 1 : numel(opt.UserDataFields)
            fieldName = opt.UserDataFields{ii};
            userDataFields.(fieldName) = cell.empty(1, 0);
        end
    end%


    function hereAddUserDataFields(ithUserData, numColumns)
        if numColumns==0
            return
        end
        for ii = 1 : numel(opt.UserDataFields)
            valueToSave = repmat({char.empty(1, 0)}, 1, numColumns);
            fieldName = opt.UserDataFields{ii};
            if isfield(ithUserData, fieldName)
                fieldValue = ithUserData.(fieldName); 
                if ischar(fieldValue) || isa(fieldValue, 'string')
                    valueToSave{1} = char(fieldValue);
                end
            end
            userDataFields.(fieldName) = [userDataFields.(fieldName), valueToSave];
        end
    end%
end%


%
% Local Functions
%


function c = hereSerialize(oo, opt)
    nameRow = oo.NameRow;
    strDat = oo.StrDat;
    data = oo.Data;

    if isfield(oo, 'Delimiter')
        delimiter = oo.Delimiter;
    else
        delimiter = ', ';
    end
    formatString = [delimiter, '"%s"'];

    if isfield(oo, 'CommentRow')
        commentRow = oo.CommentRow;
    else
        commentRow = { };
    end

    if isfield(oo, 'ClassRow')
        classRow = oo.ClassRow;
    else
        classRow = { };
    end
    isClassRow = ~isempty(classRow);

    if isfield(oo, 'UnitRow')
        unitRow = oo.UnitRow;
    else
        unitRow = cell.empty(1, 0);
    end

    if isfield(oo, 'NanString')
        nanString = oo.NanString;
    else
        nanString = 'NaN';
    end
    isNanString = ~strcmpi(nanString, 'NaN');

    if isfield(oo, 'Format')
        format = oo.Format;
    else
        format = '%.8e';
    end

    if isfield(oo, 'Highlight')
        highlight = oo.Highlight;
    else
        highlight = [ ];
    end
    isHighlight = ~isempty(highlight);

    isUserData = isfield(oo, 'UserData');

    %--------------------------------------------------------------------------

    % Create an empty buffer
    c = '';

    % Write database user data
    if isUserData
        userData = utils.any2str(oo.UserData);
        userData = strrep(userData, '"', '''');
        c = [c, '"Userdata[', oo.UserDataFieldName, '] ->"', delimiter, '"', userData, '"', newline( )];
    end

    % Write name row.
    if isHighlight
        nameRow = [{''}, nameRow];
    end
    c = [c, sprintf('"%s"', opt.NamesHeader), herePrintCharCells(nameRow)];

    % Write comments
    if ~isempty(commentRow)
        if isHighlight
            commentRow = [{''}, commentRow];
        end
        c = [c, newline( ), sprintf('"%s"', opt.CommentsHeader), herePrintCharCells(commentRow)];
    end

    % Write unit
    if ~isempty(unitRow)
        if isHighlight
            unitRow = [{''}, unitRow];
        end
        c = [c, newline( ), sprintf('"%s"', opt.UnitsHeader), herePrintCharCells(unitRow)];
    end

    % Write class
    if isClassRow
        if isHighlight
            classRow = [{''}, classRow];
        end
        c = [c, newline( ), sprintf('"%s"', opt.ClassHeader), herePrintCharCells(classRow)];
    end

    % Write user data fields
    if isfield(oo, 'UserDataFields')
        fieldNames = fieldnames(oo.UserDataFields);
        for ii = 1 : numel(fieldNames)
            ithFieldName = fieldNames{ii};
            ithRow = oo.UserDataFields.(ithFieldName);
            if isHighlight
                ithRow = [{''}, ithRow];
            end
            c = [ c, newline( ), ...
                  sprintf('".%s"', ithFieldName), herePrintCharCells(ithRow)];
        end
    end

    % Handle escape characters.
    strDat = strrep(strDat, '\', '\\');
    strDat = strrep(strDat, '%', '%%');

    % Create format string fot the imaginary parts of data; they need to be
    % always printed with a plus or minus sign.
    iFormat = [format, 'i'];
    if isempty(strfind(iFormat, '%+')) && isempty(strfind(iFormat, '%0+'))
        iFormat = strrep(iFormat, '%', '%+');
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
    formatLine(iCol) = {[delimiter, format, iFormat]};
    % Format string for columns that only have real numbers.
    formatLine(~iCol) = {[delimiter, format]};
    formatLine = [formatLine{:}];

    if isempty(strDat)
        % If there is no time series in the input database, create a vector 1:N in
        % the first column instead of dates.
        strDat = cellfun( @(x) sprintf('%g', x), ...
                          num2cell(1:numRows), ...
                          'UniformOutput', false );
    end

    % Transpose data in cellData so that they are read correctly in sprintf.
    cellData = cell(1+size(xData, 2), numRows);
    nDat = numel(strDat);
    cellData(1, 1:nDat) = strDat(:);
    cellData(2:end, :) = num2cell(xData.');
    cc = sprintf(['\n"%s"', formatLine], cellData{:});

    % NaNi is never printed with the leading sign. Replace NaNi with +NaNi. We
    % should also control for the occurence of NaNi in date strings but we
    % don't as this is quite unlikely (and would not be easy).
    if isImagNan
        cc = strrep(cc, 'NaNi', '+NaNi');
    end

    % Replace NaNs in the date/data matrix with a user-supplied string. We
    % don't protect NaNs in date strings; these too will be replaced.
    if isNanString
        cc = strrep(cc, 'NaN', nanString);
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
            s = sprintf(formatString, c{:});
        end%
end%
