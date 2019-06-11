function disp(this, name, disp2DFunc)
% disp  Disp method for Series objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

config = iris.get( );

try
    name; %#ok<VUNUS>
catch %#ok<CTCH>
    name = '';
end

start = double(this.Start);
freq = DateWrapper.getFrequencyAsNumeric(start);

try
    disp2DFunc; %#ok<VUNUS>
catch %#ok<CTCH>
    if freq==Frequency.DAILY
        disp2DFunc = @disp2dDaily;
    else
        disp2DFunc = @disp2d;
    end
end

%--------------------------------------------------------------------------

dispHeader(this, config.DispIndent);

data = this.Data;
dataNDim = ndims(data);
dispND(start, data, this.Comment, [ ], name, disp2DFunc, dataNDim, config);

disp@shared.UserDataContainer(this, 1);
textual.looseLine( );

end%


%
% Local functions
%


function dispHeader(this, indent)
    sizeOfData = size(this.Data);
    numOfPeriods = sizeOfData(1);
    fprintf(indent);
    if isempty(this.Data)
       fprintf('Empty ');
    end
    sizeString = sprintf('-by-%g', sizeOfData(2:end));
    fprintf('%s Object: %g%s\n', getClickableClassName(this), numOfPeriods, sizeString);
    textual.looseLine( );
end%




function dispND(start, data, comment, pos, name, disp2DFUnc, numOfDims, cfg)
    lastDimSize = size(data, numOfDims);
    numOfPeriods = size(data, 1);
    sep = sprintf(':  ');
    num2StrFunc = @(x) fnum2str(x, cfg.TSeriesFormat);
    if numOfDims>2
        subsref = cell([1, numOfDims]);
        subsref(1:numOfDims-1) = {':'};
        for i = 1 : lastDimSize
            subsref(numOfDims) = {i};
            dispND(start, data(subsref{:}), comment(subsref{:}), ...
                [i, pos], name, disp2DFUnc, numOfDims-1, cfg);
        end
    else
        if ~isempty(pos)
            fprintf('%s{:, :%s} =\n', name, sprintf(', %g', pos));
            textual.looseLine( );
        end
        if numOfPeriods>0
            X = disp2DFUnc(start, data, cfg.DispIndent, sep, num2StrFunc);
            % Reduce the number of white spaces between numbers to 5 at most.
            X = reduceSpaces(X, cfg.tseriesmaxwspace);
            % Print the dates and data.
            disp(X);
        end
        % Make sure long scalar comments are never displayed as `[1xN char]`.
        fprintf(cfg.DispIndent);
        comment = [{'Dates'}, comment];
        if length(comment)==1
            if isempty(regexp(comment{1}, '[\r\n]', 'once'))
                fprintf('\t''%s''\n', comment{1});
            else
                fprintf('''%s''\n', comment{1});
            end
            textual.looseLine( );
        else
            textual.looseLine( );
            disp(comment);
        end
    end
end%




function x = disp2d(start, data, indent, sep, num2strFunc)
    numOfPeriods = size(data, 1);
    range = start + (0 : numOfPeriods-1);
    dates = strjust(dat2char(range));
    if DateWrapper.getFrequencyAsNumeric(start)==Frequency.WEEKLY
        dateFormatW = '$ (Aaa DD-Mmm-YYYY)';
        dates = [ dates, ...
                  strjust(dat2char(range, 'dateFormat=', dateFormatW)) ];
    end
    dates = [ repmat(indent, numOfPeriods, 1), ...
              dates, ...
              repmat(sep, numOfPeriods, 1) ];
    dataChar = num2strFunc(data);
    x = [dates, dataChar];
end%




function c = reduceSpaces(c, maxn)
    inx = all(c==' ', 1);
    s = char(32*ones(size(inx)));
    s(inx) = 'S';
    s = regexprep(s, sprintf('(?<=S{%g})S', maxn), 'X');
    c(:, s=='X') = '';
end%




function c = fnum2str(x, fmt)
    if isempty(fmt)
        c = num2str(x);
    else
        c = num2str(x, fmt);
    end
end%




function x = disp2dDaily(start, data, indent, sep, num2strFunc)
    MAX_DAYS_IN_MONTH = 31;

    [numOfPeriods, nx] = size(data);
    [startYear, startMonth, startDay] = datevec( double(start) );
    [endYear, endMonth, endDay] = datevec( double(start + numOfPeriods - 1) );

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
    numOfPeriods = length(month);

    lastDay = eomday(year, month);
    lastDay = lastDay(:).';
    x = [ ];
    for t = 1 : numOfPeriods
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

    indent = repmat(indent, size(dates, 1), 1);
    x = [indent, dates, dataStr];
end%

