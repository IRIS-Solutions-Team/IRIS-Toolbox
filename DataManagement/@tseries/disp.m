function disp(this, name, disp2DFunc)
% disp  Disp method for Series objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    name; %#ok<VUNUS>
catch %#ok<CTCH>
    name = '';
end

start = this.start;
freq = datfreq(start);

try
    disp2DFunc; %#ok<VUNUS>
catch %#ok<CTCH>
    if freq==365
        disp2DFunc = @disp2dDaily;
    else
        disp2DFunc = @disp2d;
    end
end

%--------------------------------------------------------------------------

dispHeader(this);

data = this.data;
dataNDim = ndims(data);
config = irisget( );
dispND(start, data, this.Comment, [ ], name, disp2DFunc, dataNDim, config);

disp@shared.UserDataContainer(this, 1);
textfun.loosespace( );
end




function dispHeader(this)
tmpSize = size(this.data);
nPer = tmpSize(1);
fprintf('\t');
if isempty(this.data)
   fprintf('empty ');
end
ccn = getClickableClassName(this);
strSize = sprintf('-by-%g', tmpSize(2:end));
fprintf('%s object: %g%s\n', ccn, nPer, strSize);
textfun.loosespace( );
end




function dispND(start, data, cmt, pos, name, disp2DFUnc, nDim, cfg)
lastDimSize = size(data, nDim);
nPer = size(data, 1);
tab = sprintf('\t');
sep = sprintf(':  ');
num2StrFunc = @(x) fnum2str(x, cfg.tseriesformat);
if nDim>2
    subsref = cell([1, nDim]);
    subsref(1:nDim-1) = {':'};
    for i = 1 : lastDimSize
        subsref(nDim) = {i};
        dispND(start, data(subsref{:}), cmt(subsref{:}), ...
            [i, pos], name, disp2DFUnc, nDim-1, cfg);
    end
else
    if ~isempty(pos)
        fprintf('%s{:, :%s} =\n', name, sprintf(', %g', pos));
        textfun.loosespace( );
    end
    if nPer>0
        X = disp2DFUnc(start, data, tab, sep, num2StrFunc);
        % Reduce the number of white spaces between numbers to 5 at most.
        X = reduceSpaces(X, cfg.tseriesmaxwspace);
        % Print the dates and data.
        disp(X);
    end
    % Make sure long scalar comments are never displayed as `[1xN char]`.
    if length(cmt)==1
        if isempty(regexp(cmt{1}, '[\r\n]', 'once'))
            fprintf('\t''%s''\n', cmt{1});
        else
            fprintf('''%s''\n', cmt{1});
        end
        textfun.loosespace( );
    else
        textfun.loosespace( );
        disp(cmt);
    end
end
end 




function x = disp2d(start, data, tab, sep, num2strFunc)
nPer = size(data, 1);
range = start + (0 : nPer-1);
dates = strjust(dat2char(range));
if datfreq(range(1))==52
    dateFormatW = '$ (Aaa DD-Mmm-YYYY)';
    dates = [dates, ...
        strjust(dat2char(range, 'dateFormat=', dateFormatW))];
end
dates = [ ...
    tab(ones(1, nPer), :), ...
    dates, ...
    sep(ones(1, nPer), :), ...
    ];
dataChar = num2strFunc(data);
x = [dates, dataChar];
end 




function c = reduceSpaces(c, maxn)
inx = all(c==' ', 1);
s = char(32*ones(size(inx)));
s(inx) = 'S';
s = regexprep(s, sprintf('(?<=S{%g})S', maxn), 'X');
c(:, s=='X') = '';
end




function c = fnum2str(x, fmt)
if isempty(fmt)
    c = num2str(x);
else
    c = num2str(x, fmt);
end
end




function x = disp2dDaily(start, data, tab, sep, num2strFunc)
MAX_DAYS_IN_MONTH = 31;

[nPer, nx] = size(data);
[startYear, startMonth, startDay] = datevec( double(start) );
[endYear, endMonth, endDay] = datevec( double(start + nPer - 1) );

% Pad missing observations at the beginning of the first month
% and at the end of the last month with NaNs.
tmp = eomday(endYear, endMonth);
data = [nan(startDay-1, nx);data;nan(tmp-endDay, nx)];

% Start-date and end-date of the calendar matrix.
% startdate = datenum(startyear, startmonth, 1);
% enddate = datenum(endyear, endmonth, tmp);

year = startYear : endYear;
nYear = length(year);
year = year(ones(1, 12), :);
year = year(:);

month = 1 : 12;
month = transpose(month(ones([1, nYear]), :));
month = month(:);

year(1:startMonth-1) = [ ];
month(1:startMonth-1) = [ ];
year(end-(12-endMonth)+1:end) = [ ];
month(end-(12-endMonth)+1:end) = [ ];
nPer = length(month);

lastDay = eomday(year, month);
lastDay = lastDay(:).';
x = [ ];
for t = 1 : nPer
    tmp = nan(nx, MAX_DAYS_IN_MONTH);
    tmp(:, 1:lastDay(t)) = transpose(data(1:lastDay(t), :));
    x = [x;tmp]; %#ok<AGROW>
    data(1:lastDay(t), :) = [ ];
end
lastDay = repmat(lastDay, nx, 1);
lastDay = lastDay(:).';

% Date string.
rowStart = datenum(year, month, 1);
nRow = length(rowStart);
dates = cell(1, 1 + nx*nRow);
dates(:) = {''};
dates(2:nx:end) = dat2str(rowStart, 'dateFormat=', ['$Mmm-YYYY', sep]);
dates = char(dates);

% Data string.
divider = '    ';
divider = divider(ones(size(x, 1)+1, 1), :);
dataStr = '';
for i = 1 : MAX_DAYS_IN_MONTH
    c = num2strFunc(x(:, i));
    ixExist = i<=lastDay;
    if any(~ixExist)
        for j = find(~ixExist(:).')
            c(j, :) = strrep(c(j, :), 'NaN', '  *');
        end
    end
    dataStr = [dataStr, ...
        strjust(char(sprintf('D%g', i), c), 'right')]; %#ok<AGROW>
    if i<MAX_DAYS_IN_MONTH
        dataStr = [dataStr, divider]; %#ok<AGROW>
    end
end

tab = repmat(tab, size(dates, 1), 1);
x = [tab, dates, dataStr];
end
