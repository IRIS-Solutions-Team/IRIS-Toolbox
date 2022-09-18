function lsSaved = dbsave(inp, fileName, varargin)
% dbsave  Save database to CSV file.
%
% __Syntax__
%
%     ListSaved = dbsave(D, FileName)
%     ListSaved = dbsave(D, FileName, Dates, ...)
%
%
% __Output Arguments__
%
% * `ListSaved` [ cellstr ] - List of actually saved database entries.
%
%
% __Input Arguments__
%
% * `D` [ struct ] - Database whose tseries and numeric entries will be
% saved.
%
% * `FileName` [ char ] - Filename under which the CSV will be saved, 
% including its extension.
%
% * `Dates` [ numeric | *`Inf`* ] Dates or date range on which the tseries
% objects will be saved.
%
%
% __Options__
%
% * `VariablesHeader='Variables->'` [ char ] - String that will be put in
% the top-left corncer (cell A1).
%
% * `Class=true` [ `true` | `false` ] - Include a row with class and size
% specifications.
%
% * `Comment=true` [ `true` | `false` ] - Include a row with comments for
% time series.
%
% * `Decimal=[ ]` [ numeric ] - Number of decimals up to which the data
% will be saved; if empty the option `Format=` is used.
%
% * `Format='%.8e'` [ char ] - Numeric format that will be used to
% represent the data, see `sprintf` for details on formatting, The format
% must start with a `'%'`, and must not include identifiers specifying
% order of processing, i.e. the `'$'` signs, or left-justify flags, the
% `'-'` signs.
%
% * `MatchFreq=false` [ `true` | `false` ] - Save only those time series
% whose date frequencies match the input vector of dates, `Dates`.
%
% * `NaN='NaN'` [ char ] - String that will be used to represent NaNs.
%
% * `SaveNested=false` [ `true` | `false` ] - Save nested databanks
% (structs within the `inputDatabank`); the nested databanks will be saved
% to separate CSV files.
%
% * `UserData='userdata'` [ char ] - Field name from which any kind of
% userdata will be read and saved in the CSV file.
%
%
% __Description__
%
% The data saved include also imaginary parts of complex numbers.
%
%
% _Saving user data with the database_
%
% If your database contains field named `UserData=`, this will be saved
% in the CSV file on a separate row. The `UserData=` field can be any
% combination of numeric, char, and cell arrays and 1-by-1 structs.
%
% You can use the `UserData=` field to describe the database or preserve
% any sort of metadata. To change the name of the field that is treated as
% user data, use the `UserData=` option.
%
%
% __Example__
%
% Create a simple database with two time series.
%
%     D = struct( );
%     D.x = tseries(qq(2010, 1):qq(2010, 4), @rand);
%     D.y = tseries(qq(2010, 1):qq(2010, 4), @rand);
%
% Add your own description of the database, e.g.
%
%     D.UserData = {'My database', datestr(now( ))};
%
% Save the database as CSV using `dbsave`, 
%
%     dbsave(D, 'mydatabase.csv');
%
% When you later load the database, 
%
%     D = dbload('mydatabase.csv')
%
%     D = 
%
%        userdata: {'My database'  '23-Sep-2011 14:10:17'}
%               x: [4x1 tseries]
%               y: [4x1 tseries]
%
% the database will preserve the `'UserData''` field.
%
%
% __Example__
%
% To change the field name under which you store your own user data, use
% the option `UserData=` when running `dbsave`, 
%
%     D = struct( );
%     D.x = tseries(qq(2010, 1):qq(2010, 4), @rand);
%     D.y = tseries(qq(2010, 1):qq(2010, 4), @rand);
%     D.MYUSERDATA = {'My database', datestr(now( ))};
%     dbsave(D, 'mydatabase.csv', Inf, 'userData=', 'MYUSERDATA');
%
% The name of the user data field is also kept in the CSV file so that
% `dbload` works fine in this case, too, and returns a database identical
% to the saved one, 
%
%     D = dbload('mydatabase.csv')
%
%     D = 
%
%        MYUSERDATA: {'My database'  '23-Sep-2011 14:10:17'}
%                 x: [4x1 tseries]
%                 y: [4x1 tseries]

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

thisWarning = [ 
    "Deprecated"
    "Function dbsave() is deprecated and will be removed from "
    "[IrisToolbox] in a future release; use databank.toCSV() instead."
];
throw(exception.Base(thisWarning, 'warning'));


FN_PRINT_SIZE = @(s) [ '[', sprintf('%g', s(1)), sprintf('-by-%g', s(2:end)), ']' ];

if ~isempty(varargin) && (isa(varargin{1}, 'DateWrapper') || isnumeric(varargin{1}))
    dates = double(varargin{1});
    varargin(1) = [ ];
end

try
    dates;
catch %#ok<CTCH>
    dates = Inf;
end

% Allow both dbsave(d, fileName) and dbsave(fileName, d)
if validate.string(inp) && validate.databank(fileName)
    [inp, fileName] = deal(fileName, inp);
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('dbase/dbsave');
    addRequired(parser, 'inputDatabank', @validate.databank);
    addRequired(parser, 'fileName', @validate.string);
    addRequired(parser, 'dates', @validate.date);
    % Options
    addParameter(parser, 'VariablesHeader', 'Variables ->', @(x) validate.string(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"')));
    addParameter(parser, 'ClassHeader', 'Class[Size] ->', @(x) validate.string(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"')));
    addParameter(parser, 'Class', true, @validate.logicalScalar);
    addParameter(parser, 'Comment', true, @validate.logicalScalar);
    addParameter(parser, 'CommentsHeader', 'Comments ->', @(x) validate.string(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"')));
    addParameter(parser, {'Decimal', 'Decimals'}, [ ], @(x) isempty(x) || validate.numericScalar(x));
    addParameter(parser, 'Format', '%.8e', @(x) validate.string(x) && ~isempty(x) && x(1)=='%' && isempty(strfind(x, '$')) && isempty(strfind(x, '-')));
    addParameter(parser, 'MatchFreq', false, @validate.logicalScalar);
    addParameter(parser, 'Nan', 'NaN', @validate.string);
    addParameter(parser, {'SaveNested', 'SaveSubdb'}, false, @validate.logicalScalar);
    addParameter(parser, 'UserData', 'userdata', @(x) validate.string(x) && isvarname(x));
    addParameter(parser, 'UnitsHeader', 'Units ->', @(x) validate.string(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"')));
    addParameter(parser, 'Delimiter', ',', @validate.string);
    addDateOptions(parser);
end
parse(parser, inp, fileName, dates, varargin{:});
opt = parser.Options;

% Set up the formatting string
if isempty(opt.Decimal)
    format = opt.Format;
else
    format = ['%.', sprintf('%g', opt.Decimal), 'f'];
end

%--------------------------------------------------------------------------

if isequal(dates, Inf) || isequal(dates, [-Inf, Inf])
    dates = dbrange(inp);
    if iscell(dates)
        THIS_ERROR = { 'Databank:CannotSaveMixedFrequencies'
                       'Input date range needs to be specified when saving databanks containing time series of multiple date frequencies' };
        throw( exception.Base(THIS_ERROR, 'error') );
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

% Create saving struct.
o = struct( );

% Handle userdata first, and remove them from the database so that they are
% not processed as a regular field.
if ~isempty(opt.UserData) && isfield(inp, opt.UserData)
    o.UserData = inp.(opt.UserData);
    o.UserDataFieldName = opt.UserData;
    inp = rmfield(inp, opt.UserData);
end

% Handle custom delimiter
o.Delimiter = opt.Delimiter;

list = fieldnames(inp).';

% Initialise the data matrix as a N-by-1 vector of NaNs to mimic the Dates.
% This first column will fill in all entries.
nList = numel(list);
data = cell(1, nList); % nan(length(dates), 1);

nameRow = { };
classRow = { };
commentRow = { };
ixSaved = false(size(list));
inxOfNested = false(size(list));

for i = 1 : nList
    
    name = list{i};
    x = inp.(name);
    
    if isa(x, 'Series')
        ithFreq = x.FrequencyAsNumeric;
        if opt.MatchFreq && userFreq~=ithFreq
            continue
        end
        if isRange
            iData = getDataFromTo(x, dates(1), dates(end));
        else
            iData = getData(x, dates);
        end
        iComment = comment(x);
        ixSaved(i) = true;
        iClass = class(x);
        iUserData = userdata(x);
    elseif isnumeric(x)
        iData = x;
        iComment = {''};
        ixSaved(i) = true;
        iClass = class(x);
        iUserData = [ ];
    elseif isstruct(x)
        inxOfNested(i) = true;
        iUserData = [ ];
        continue
    else
        continue
    end
    
    iData = double(iData);
    tmpSize = size(iData);
    iData = iData(:, :);
    iComment = iComment(1, :);
    [tmpRows, tmpCols] = size(iData);
    if tmpCols==0
        data{i} = [ ];
        continue
    end
    % Add data, expand first dimension if necessary.
    data{i} = iData;
    nameRow{end+1} = list{i}; %#ok<AGROW>
    classRow{end+1} = [iClass, FN_PRINT_SIZE(tmpSize)]; %#ok<AGROW>
    if tmpCols>1
        nameRow(end+(1:tmpCols-1)) = {''}; %#ok<AGROW>
        classRow(end+(1:tmpCols-1)) = {''}; %#ok<AGROW>
    end
    if tmpCols>size(iComment, 2)
        iComment(1, end+1:tmpCols) = {''};
    end 
    commentRow = [commentRow, iComment]; %#ok<AGROW>
end

inxEmpty = cellfun('isempty', data);
data(inxEmpty) = [ ];

numRows = cellfun(@(x) size(x, 1), data);
maxNumRows = max(numRows);
for i = find(numRows~=maxNumRows)
    data{i}(end+1:maxNumRows, :) = NaN;
end

data = [ data{:} ];

lsSaved = list(ixSaved);

% We need to remove double quotes from the date format string because the
% double quotes are used to delimit the CSV cells.
o.StrDat = dat2str(dates(:), opt);
o.StrDat = strrep(o.StrDat, '"', '');

o.Data = data;
o.NameRow = nameRow;
o.NanString = opt.Nan;
o.Format = format;
if opt.Comment
    o.CommentRow = commentRow;
end
if opt.Class
    o.ClassRow = classRow;
end

c = hereSerialize(o, opt);

% Save to fileName if not empty
if ~isempty(fileName)
    textual.write(c, fileName);
end

% Save nested databanks
if opt.SaveNested && any(inxOfNested)
    hereSaveNestedDatabanks( );
end

return


    function hereSaveNestedDatabanks( )
        [fPath, fTit, fExt] = fileparts(fileName);
        for ii = find(inxOfNested)
            iiName = list{ii};
            iifileName = fullfile(fPath, [fTit, '_', iiName], fExt);
            saved = dbsave(inp.(iiName), iifileName, dates, varargin{:});
            lsSaved{end+1} = saved; %#ok<AGROW>
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
    c = [c, sprintf('"%s"', opt.VariablesHeader), herePrintCharCells(nameRow)];

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
    nRow = size(data, 1);
    nCol = size(data, 2);

    % Combine real and imag columns in an extended data matrix.
    xData = zeros(nRow, 2*nCol);
    xData(:, 1:2:end) = real(data);
    iData = imag(data);
    xData(:, 2:2:end) = iData;

    % Find imag columns and create positions of zero-only imag columns that
    % will be removed.
    iCol = any(iData ~= 0, 1);
    removeCol = 2*(1 : nCol);
    removeCol(iCol) = [ ];
    % Check for the occurence of imaginary NaNs.
    isImagNan = any(isnan(iData(:)));
    % Remove zero-only imag columns from the extended data matrix.
    xData(:, removeCol) = [ ];
    % Create a sequence of formats for one line.
    formatLine = cell(1, nCol);
    % Format string for columns that have imaginary numbers.
    formatLine(iCol) = {[delimiter, format, iFormat]};
    % Format string for columns that only have real numbers.
    formatLine(~iCol) = {[delimiter, format]};
    formatLine = [formatLine{:}];

    if isempty(strDat)
        % If there is no time series in the input database, create a vector 1:N in
        % the first column instead of dates.
        strDat = cellfun( @(x) sprintf('%g', x), ...
                          num2cell(1:nRow), ...
                          'UniformOutput', false );
    end

    % Transpose data in cellData so that they are read correctly in sprintf.
    cellData = cell(1+size(xData, 2), nRow);
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
