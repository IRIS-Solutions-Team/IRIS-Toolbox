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
% * `'VariablesHeader='` [ *`'Variables ->'`* | char ] - String that will
% be put in the top-left corncer (cell A1).
%
% * `'Class='` [ *`true`* | false ] - Include a row with class and size
% specifications.
%
% * `'Comment='` [ *`true`* | `false` ] - Include a row with comments for tseries
% objects.
%
% * `'Decimal='` [ numeric | *empty* ] - Number of decimals up to which the
% data will be saved; if empty the option `'Format='` is used.
%
% * `'Format='` [ char | *`'%.8e'`* ] - Numeric format that will be used to
% represent the data, see `sprintf` for details on formatting, The format
% must start with a `'%'`, and must not include identifiers specifying
% order of processing, i.e. the `'$'` signs, or left-justify flags, the
% `'-'` signs.
%
% * `'FreqLetters='` [ char | *`'YHQBMW'`* ] - Six letters to represent the
% five possible date frequencies except daily and integer (annual,
% semi-annual, quarterly, bimonthly, monthly, weekly).
%
% * `'MatchFreq='` [ `true` | *`false`* ] - Save only the tseries whose
% date frequencies match the input vector of dates, `dates`.
%
% * `'NaN='` [ char | *`'NaN'`* ] - String that will be used to represent
% NaNs.
%
% * `'SaveSubdb='` [ `true` | *`false`* ] - Save sub-databases (structs
% found within the input struct `D`); the sub-databases will be saved to
% separate CSF files.
%
% * `'UserData='` [ char | *'userdata'* ] - Field name from which
% any kind of userdata will be read and saved in the CSV file.
%
%
% __Description__
%
% The data saved include also imaginary parts of complex numbers.
%
%
% _Saving user data with the database_
%
% If your database contains field named `'userdata='`, this will be saved
% in the CSV file on a separate row. The `'userdata='` field can be any
% combination of numeric, char, and cell arrays and 1-by-1 structs.
%
% You can use the `'userdata='` field to describe the database or preserve
% any sort of metadata. To change the name of the field that is treated as
% user data, use the `'userData='` option.
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
% the database will preserve the `'userdata='` field.
%
%
% __Example__
%
% To change the field name under which you store your own user data, use
% the `'userdata='` option when running `dbsave`, 
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

FN_PRINT_SIZE = @(s) [ '[', sprintf('%g', s(1)), sprintf('-by-%g', s(2:end)), ']' ];

if ~isempty(varargin) && isnumeric(varargin{1})
    vecDat = varargin{1};
    varargin(1) = [ ];
end

try
    vecDat;
catch %#ok<CTCH>
    vecDat = Inf;
end

% Allow both dbsave(d, fileName) and dbsave(fileName, d).
if ischar(inp) && isstruct(fileName)
    [inp, fileName] = deal(fileName, inp);
end

% Parse input arguments.
pp = inputParser( );
pp.addRequired('d', @isstruct);
pp.addRequired('fileName', @ischar);
pp.addRequired('dates', @isnumeric);
pp.parse(inp, fileName, vecDat);

% Parse options.
opt = passvalopt('dbase.dbsave', varargin{:});

% Run Dates/datdefaults to substitute the default (irisget) date format
% options for `@config`.
opt = datdefaults(opt);

% Set up the formatting string.
if isempty(opt.Decimal)
    format = opt.Format;
else
    format = ['%.', sprintf('%g', opt.Decimal), 'f'];
end

%--------------------------------------------------------------------------

if isequal(vecDat, Inf)
    vecDat = dbrange(inp);
    if iscell(vecDat)
        utils.error('dbase:dbsave', ...
            'Cannot save database with mixed date frequencies.');
    end
else
    vecDat = vecDat(:)';
    if ~isempty(vecDat) && any(~freqcmp(vecDat))
        utils.error('dbase:dbsave', ...
            'Input date vector must have homogenous date frequency.');
    end
end
isRange = all(round(diff(vecDat))==1);
if ~isempty(vecDat)
    usrFreq = getFrequency(vecDat);
else
    usrFreq = Frequency.NaF;
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
data = cell(1, nList); % nan(length(vecDat), 1);
nRows = zeros(1, nList, 'int32');

nameRow = { };
classRow = { };
commentRow = { };
ixSaved = false(size(list));
ixSubdb = false(size(list));

for i = 1 : nList
    
    name = list{i};
    
    if isa(inp.(name), 'tseries')
        iFreq = freq(inp.(name));
        if opt.MatchFreq && usrFreq~=iFreq
            continue
        end
        if isRange
            iData = rangedata(inp.(name), vecDat);
        else
            iData = mygetdata(inp.(name), vecDat);
        end
        iComment = comment(inp.(name));
        ixSaved(i) = true;
        iClass = class(inp.(name));
    elseif isnumeric(inp.(name))
        iData = inp.(name);
        iComment = {''};
        ixSaved(i) = true;
        iClass = class(inp.(name));
    elseif isstruct(inp.(name))
        ixSubdb(i) = true;
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
    nRows(i) = int32(tmpRows);
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

nRowsMax = max(nRows);
ixCorrect = nRows==nRowsMax;
if any(~ixCorrect)
    for i = find(~ixCorrect)
        data{i}(end+1:nRowsMax, :) = NaN;
    end
end

data = [ data{:} ];

lsSaved = list(ixSaved);

% We need to remove double quotes from the date format string because the
% double quotes are used to delimit the CSV cells.
o.StrDat = dat2str(vecDat(:), opt);
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

saveCsvData(o, fileName, opt);

% Save sub-databases.
if opt.SaveSubdb && any(ixSubdb)
    doSaveSubdb( );
end

return




    function doSaveSubdb( )
        [fPath, fTit, fExt] = fileparts(fileName);
        for ii = find(ixSubdb)
            iiName = list{ii};
            iifileName = fullfile(fPath, [fTit, '_', iiName], fExt);
            saved = dbsave(inp.(iiName), iifileName, vecDat, varargin{:});
            lsSaved{end+1} = saved; %#ok<AGROW>
        end
    end
end




function saveCsvData(oo, fileName, opt)
nameRow = oo.NameRow;
strDat = oo.StrDat;
data = oo.Data;

if isfield(oo, 'Delimiter')
    delimiter = oo.Delimiter;
else
    delimiter = ', ';
end
fstr = [delimiter, '"%s"'];

if isfield(oo, 'CommentRow')
    commentRow = oo.CommentRow;
else
    commentRow = { };
end
isCommentRow = ~isempty(commentRow);

if isfield(oo, 'ClassRow')
    classRow = oo.ClassRow;
else
    classRow = { };
end
isClassRow = ~isempty(classRow);

if isfield(oo, 'UnitRow')
    unitRow = oo.UnitRow;
else
    unitRow = { };
end
isUnitRow = ~isempty(unitRow);

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

% Create an empty buffer.
c = '';
br = sprintf('\n');

% Write database user data.
if isUserData
    userData = utils.any2str(oo.UserData);
    userData = strrep(userData, '"', '''');
    c = [c, '"Userdata[', oo.UserDataFieldName, '] ->"', delimiter, '"', userData, '"', br];
end

% Write name row.
if isHighlight
    nameRow = [{''}, nameRow];
end
c = [c, sprintf('"%s"', opt.VariablesHeader), printCharCells(nameRow)];

% Write comments.
if isCommentRow
    if isHighlight
        commentRow = [{''}, commentRow];
    end
    c = [c, br, sprintf('"%s"', opt.CommentsHeader), printCharCells(commentRow)];
end

% Write units.
if isUnitRow
    if isHighlight
        unitRow = [{''}, unitRow];
    end
    c = [c, br, sprintf('"%s"', opt.UnitsHeader), printCharCells(unitRow)];
end

% Write classes.
if isClassRow
    if isHighlight
        classRow = [{''}, classRow];
    end
    c = [c, br, sprintf('"%s"', opt.ClassHeader), printCharCells(classRow)];
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
    strDat = cellfun( ...
        @(x) sprintf('%g', x), ...
        num2cell(1:nRow), ...
        'UniformOutput', false ...
        );
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
char2file([c, cc], fileName);

return




    function s = printCharCells(c)
        s = '';
        if isempty(c) || ~iscellstr(c)
            return
        end
        s = sprintf(fstr, c{:});
    end
end
