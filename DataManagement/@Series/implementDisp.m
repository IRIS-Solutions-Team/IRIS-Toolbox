
function implementDisp(this, name, disp2dFunc)

    config = iris.get();

    try
        name; %#ok<VUNUS>
    catch %#ok<CTCH>
        name = '';
    end

    start = double(this.Start);
    freq = dater.getFrequency(start);

    if nargin<3
        disp2dFunc = 'disp2d';
    end

    dispHeader(this, config.DispIndent);
    dispDataClass(this, config.DispIndent);
    textual.looseLine( );

    data = this.Data;
    dataNDim = ndims(data);
    dispND(start, data, this.Comment, this.Headers, [ ], name, disp2dFunc, dataNDim, config);

    implementDisp@iris.mixin.UserDataContainer(this, name);

end%


%
% Local functions
%


function dispHeader(this, indent)
    sizeOfData = size(this.Data);
    numPeriods = sizeOfData(1);
    fprintf(indent);
    if isempty(this.Data)
       fprintf('Empty ');
    end
    sizeString = sprintf('-by-%g', sizeOfData(2:end));
    fprintf('%s Object: %g%s\n', getClickableClassName(this), numPeriods, sizeString);
end%




function dispDataClass(this, indent)
    fprintf(indent);
    fprintf('Class of Data: %s\n', class(this.Data));
end%




function dispND(start, data, comment, headers, pos, name, disp2dFunc, numDims, cfg)
    MAX_WHITE_SPACES = 5;
    start = double(start);
    lastDimSize = size(data, numDims);
    numPeriods = size(data, 1);
    sep = sprintf(':  ');
    if numDims>2
        subsref = cell([1, numDims]);
        subsref(1:numDims-1) = {':'};
        for i = 1 : lastDimSize
            subsref(numDims) = {i};
            headers__ = [];
            if ~isempty(headers)
                headers__ = headers(subsref{:});
            end
            dispND( ...
                start, data(subsref{:}), comment(subsref{:}), headers__ ...
                , [i, pos], name, disp2dFunc, numDims-1, cfg ...
            );
        end
    else
        if ~isempty(pos)
            fprintf('%s{:, :%s} =\n', name, sprintf(', %g', pos));
            textual.looseLine( );
        end
        if numPeriods>0
            try
                % Create and display 2D table
                disp(Series.createTable(start, data, comment, headers, true));
            catch
                % Legacy method
                toCharFunc = @num2str;
                range = dater.plus(start, 0:numPeriods-1);
                temp = feval(disp2dFunc, start, data, cfg.DispIndent, sep, toCharFunc);
                % Reduce the number of white spaces between numbers to 5 at most
                temp = reduceSpaces(temp, MAX_WHITE_SPACES);
                % Print the dates and data
                disp(temp);
            end
        end
        textual.looseLine( );
        disp(["Dates", string(comment)]);
    end
end%


function x = disp2d(start, data, indent, sep, toCharFunc)
    numPeriods = size(data, 1);
    range = dater.plus(start, 0:numPeriods-1);
    dates = strjust(dat2char(range));
    if dater.getFrequency(start)==Frequency.WEEKLY
        dateFormatW = '$ (Aaa DD-Mmm-YYYY)';
        dates = [ dates, ...
                  strjust(dat2char(range, 'dateFormat', dateFormatW)) ];
    end
    dates = [ repmat(indent, numPeriods, 1), ...
              dates, ...
              repmat(sep, numPeriods, 1) ];
    dataChar = toCharFunc(data);
    x = [dates, dataChar];
end%


function c = reduceSpaces(c, maxn)
    inx = all(c==' ', 1);
    s = char(32*ones(size(inx)));
    s(inx) = 'S';
    s = regexprep(s, sprintf('(?<=S{%g})S', maxn), 'X');
    c(:, s=='X') = '';
end%


function x = disp2dDaily(start, data, indent, sep, toCharFunc)
    MAX_DAYS_IN_MONTH = 31;

    [numPeriods, nx] = size(data);
    [startYear, startMonth, startDay] = datevec( double(start) );
    [endYear, endMonth, endDay] = datevec( double(start + numPeriods - 1) );

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
    numPeriods = length(month);

    lastDay = eomday(year, month);
    lastDay = lastDay(:).';
    x = [ ];
    for t = 1 : numPeriods
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
    dates(2:nx:end) = dat2str(rowStart, 'dateFormat', ['$Mmm-YYYY', sep]);
    dates = char(dates);

    % Data string.
    divider = '    ';
    divider = divider(ones(size(x, 1)+1, 1), :);
    dataStr = '';
    for i = 1 : MAX_DAYS_IN_MONTH
        c = toCharFunc(x(:, i));
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

    indent = repmat(indent, size(dates, 1), 1);
    x = [indent, dates, dataStr];
end%




function x = disp2dYearly(start, data, tab, separator, toCharFunc)
    % `data` is always a vector or a 2D matrix; no higher dimensions
    [numPeriods, nx] = size(data);
    freq = dater.getFrequency(start);
    range = start+(0:numPeriods-1);
    [year, per] = dat2ypf(range);
    firstYear = year(1);
    lastYear = year(end);
    piy = persinyear(firstYear : lastYear, freq);
    numYears = lastYear - firstYear + 1;

    if per(1) > 1
        numPre = per(1) - 1;
        data = [nan(numPre, nx); data];
        start = start - numPre;
    end

    if per(end) < piy(end)
        nPost = piy(end) - per(end);
        data = [data;nan(nPost, nx)];
    end

    numPeriods = size(data, 1);
    range = start+(0:numPeriods-1);
    maxPiy = max(piy);

    dataTable = [ ];
    dates = [ ];
    inxPadded = false(1, 0);
    for i = 1 : numYears
        n = piy(i);
        idata = data(1:n, :);
        ithRange = range(1:n);
        data(1:n, :) = [ ];
        range(1:n) = [ ];
        isPadded = n < maxPiy;
        if isPadded
            idata = [idata;nan(maxPiy-n, nx)]; %#ok<AGROW>
        end
        inxPadded = [inxPadded, repmat(isPadded, 1, nx)]; %#ok<AGROW>
        
        ithFirstDate = ithRange(1);
        ithLastDate = ithRange(end);
        dates = [ dates; ...
                  ithFirstDate, ithLastDate ]; %#ok<AGROW>
        dataTable = [dataTable; idata.']; %#ok<AGROW>
    end

    dates = dat2str(dates);
    dates = strcat(char(dates(:, 1)), '-', char(dates(:, 2)), separator);
    if nx > 1
        swap = dates;
        dates = repmat(' ', nx*numYears, size(dates, 2));
        dates(1:nx:end, :) = swap;
    end
    dates = [ repmat(' ', 1, size(dates, 2)) ; dates ];

    % Add header line with periods over columns.
    dataChar = feval(toCharFunc, [1:maxPiy; dataTable]);

    % Add the frequency letter to period numbers in the header line.
    c = dataChar(1, :);
    freqLetter = Frequency.toChar(freq);
    freqLetter = freqLetter(1);
    c = regexprep(c, ' (\d+)', [freqLetter, '$1']);
    dataChar(1, :) = c;

    % Replace `NaN` in periods that don't exist in the respective year with
    % `*`.
    for i = find(inxPadded)
        c = dataChar(1+i, :);
        c = regexprep(c, 'NaN$', '  *');
        dataChar(1+i, :) = c;
    end

    tab = repmat(tab, size(dates, 1), 1);
    x = [tab, dates, tab, dataChar];
end%

