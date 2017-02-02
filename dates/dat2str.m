function [s, field] = dat2str(dat, varargin)
% dat2str  Convert IRIS dates to cell array of strings.
%
% Syntax
% =======
%
%     s = dat2str(dat, ...)
%
%
% Input arguments
% ================
%
% * `dat` [ numeric ] - IRIS serial date number(s).
%
%
% Output arguments
% =================
%
% * `s` [ cellstr ] - Cellstr with strings representing the input dates.
%
%
% Options
% ========
%
% * `'dateFormat='` [ char | cellstr | *`'YYYYFP'`* ] - Date format string, 
% or array of format strings (possibly different for each date).
%
% * `'freqLetters='` [ char | *`'YHQBMW'`* ] - Six letters used to
% represent the six possible frequencies of IRIS dates, in this order:
% yearly, half-yearly, quarterly, bi-monthly, monthly, and weekly (such as
% the `'Q'` in `'2010Q1'`).
%
% * `'months='` [ cellstr | *`{'January', ..., 'December'}`* ] - Twelve
% strings representing the names of the twelve months.
%
% * `'standinMonth='` [ numeric | `'last'` | *`1`* ] - Month that will
% represent a lower-than-monthly-frequency date if the month is part of the
% date format string.
%
% * `'wwDay='` [ `'Mon'` | `'Tue'` | `'Wed'` | *`'Thu'`* | `'Fri'` |
% `'Sat'` | `'Sun'` ] - Day of week that will represent weeks.
%
%
% Description
% ============
%
% There are two types of date strings in IRIS: year-period strings and
% calendar date strings. The year-period strings can be printed for dates
% with yearly, half-yearly, quarterly, bimonthly, monthly, weekly, and
% indeterminate frequencies. The calendar date strings can be printed for
% dates with weekly and daily frequencies. Date formats for calendar date
% strings must start with a dollar sign, `$`.
%
% Year-period date strings
% -------------------------
%
% Regular date formats can include any combination of the following
% fields:
%
% * `'Y'` - Year.
%
% * `'YYYY'` - Four-digit year.
%
% * `'YY'` - Two-digit year.
%
% * `'P'` - Period within the year (half-year, quarter, bi-month, month, 
% week).
%
% * `'PP'` - Two-digit period within the year.
%
% * `'R'` - Upper-case roman numeral for the period within the year.
%
% * `'r'` - Lower-case roman numeral for the period within the year.
%
% * `'M'` - Month numeral.
%
% * `'MM'` - Two-digit month numeral.
%
% * `'MMMM'`, `'Mmmm'`, `'mmmm'` - Case-sensitive name of month.
%
% * `'MMM'`, `'Mmm'`, `'mmm'` - Case-sensitive three-letter abbreviation of
% month.
%
% * `'Q'` - Upper-case roman numeral for the month or stand-in month.
%
% * `'q'` - Lower-case roman numeral for the month or stand-in month.
%
% * `'F'` - Upper-case letter representing the date frequency.
%
% * `'f'` - Lower-case letter representing the date frequency.
%
% * `'EE'` - Two-digit end-of-month day; stand-in month used for
% non-monthly dates.
%
% * `'E'` - End-of-month day; stand-in month used for non-monthly dates.
%
% * `'WW'` - Two-digit end-of-month workday; stand-in month used for
% non-monthly dates.
%
% * `'W'` - End-of-month workday; stand-in month used for non-monthly dates.
%
% Calendar date strings
% ----------------------
%
% Calendar date formats must start with a dollar sign, `$`, and can include
% any combination of the following fields:
%
% * `'Y'` - Year.
%
% * `'YYYY'` - Four-digit year.
%
% * `'YY'` - Two-digit year.
%
% * `'DD'` - Two-digit day numeral; daily and weekly dates only.
%
% * `'D'` - Day numeral; daily and weekly dates only.
%
% * `'M'` - Month numeral.
%
% * `'MM'` - Two-digit month numeral.
%
% * `'MMMM'`, `'Mmmm'`, `'mmmm'` - Case-sensitive name of month.
%
% * `'MMM'`, `'Mmm'`, `'mmm'` - Case-sensitive three-letter abbreviation of
% month.
%
% * `'Q'` - Upper-case roman numeral for the month.
%
% * `'q'` - Lower-case roman numeral for the month.
%
% * `'DD'` - Two-digit day numeral.
%
% * `'D'` - Day numeral.
%
% * `'Aaa'`, `'AAA'` - Three-letter English name of the day of week
% (`'Mon'`, ..., `'Sun'`).
%
% Escaping control letters
% -------------------------
%
% To get the format letters printed literally in the date string, use a
% percent sign as an escape character: `'%Y'`, `'%P'`, `'%F'`, `'%f'`, 
% `'%M'`, `'%m'`, `'%R'`, `'%r'`, `'%Q'`, `'%q'`, `'%D'`, `'%E'`, `'%D'`.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ~isempty(varargin) && isstruct(varargin{1})
    opt = varargin{1};
else
    % Parse options.
    opt = passvalopt('dates.dat2str', varargin{1:end});
    % Run dates/datdefaults to substitute the default (irisget) date
    % format options for `@config`.
    opt = datdefaults(opt);
end

upperRomans = { ...
    'I', 'II', 'III', 'IV', 'V', 'VI', ...
    'VII', 'VIII', 'IX', 'X', 'XI', 'XII', ...
    };
lowerRomans = lower(upperRomans);

daysOfWeek = { ...
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', ...
    'Thursday', 'Friday', 'Saturday', ...
    };


%--------------------------------------------------------------------------

[year, per, freq] = dat2ypf(dat);

%ixYearly = freq == 1;
%ixZero = freq == 0;
ixWeekly = freq == 52;
ixDaily = freq == 365;
ixMsd = ixWeekly | ixDaily;

% Matlab serial date numbers (daily or weekly dates only), calendar years, 
% months, and days.
msd = nan(size(dat));
yearC = nan(size(dat));
monC = nan(size(dat));
dayC = nan(size(dat));
dowC = nan(size(dat)); %% Day of week: 'Mon' through 'Sun'.
if any(ixMsd(:))
    msd(ixDaily) = dat(ixDaily);
    msd(ixWeekly) = ww2day(dat(ixWeekly), opt.wwday);
    [yearC(ixMsd), monC(ixMsd), dayC(ixMsd)] = datevec( double(msd(ixMsd)) );
    dowC(ixMsd) = weekday(msd(ixMsd));
end

s = cell(size(year));
s(:) = {''};
nDat = numel(year);
nFmt = numel(opt.dateformat);

for iDat = 1 : nDat
    
    iFreq = freq(iDat);
    if ~any(iFreq == [0, 1, 2, 4, 6, 12, 52, 365])
        continue
    end

    if iDat <= nFmt
        isMonthNeeded = false;
        isCalendar = false;
        field = { };
        % `opt.dateformat` can be either a string, a cellstr array, or a struct.
        fmt = mydateformat(opt.dateformat, iFreq, iDat);
        parseDateFormat( );
        nField = length(field);
    end
    
    if iFreq == 365 && ~isCalendar
        utils.error('dates:dat2str', ...
            ['Calendar date format must be specified for dates ', ...
            'with daily frequency.']);
    end
    
    subs = cell(1, nField);
    subs(:) = {''};
    
    % Year-period.
    iYear = year(iDat);
    iPer = per(iDat);
    iMsd = msd(iDat);
    iMon = NaN;

    % Calendar.
    iYearC = yearC(iDat);
    iMonC = monC(iDat);
    iDayC = dayC(iDat);
    iDowC = dowC(iDat);
    
    if ~isCalendar && isMonthNeeded
        % Calculate non-calendar month.
        iMon = calculateMonth( );
    end
    
    for j = 1 : nField
        switch field{j}(1)
            case 'Y'
                if isCalendar
                    subs{j} = doYear(iYearC);
                else
                    subs{j} = doYear(iYear);
                end
            case {'M', 'm', 'Q', 'q'}
                if isCalendar
                    subs{j} = doMonth(iMonC);
                else
                    subs{j} = doMonth(iMon);
                end
            case {'P', 'R', 'r'}
                subs{j} = doPer( );
            case {'F', 'f'}
                subs{j} = subsFreqLetter( );
            case 'D'
                if isCalendar
                    subs{j} = doDay( );
                end
            case 'E'
                if isCalendar
                    subs{j} = doEom(iYearC, iMonC);
                else
                    subs{j} = doEom(iYear, iMon);
                end
            case 'W'
                if isCalendar
                    subs{j} = doEomW(iYearC, iMonC);
                else
                    subs{j} = doEomW(iYear, iMon);
                end
            case 'A'
                if isCalendar
                    subs{j} = doDow(iDowC);
                else
                    subs{j} = '';
                end
        end
    end
    
    s{iDat} = sprintf(fmt, subs{:});
end

return




    function parseDateFormat( )
        isCalendar = strncmp(fmt, '$', 1);
        if isCalendar
            fmt(1) = '';
        end
        
        fragile = 'YPFfRrQqMmEWDA';
        fmt = regexprep(fmt, ['%([', fragile, '])'], '&$1');
        
        ptn = ['(?<!&)(', ...
            'YYYY|YY|Y|', ...
            'PP|P|', ...
            'R|r|', ...
            'F|f|', ...
            'Mmmm|Mmm|mmmm|mmm|MMMM|MMM|MM|M|', ...
            'Q|q|', ...
            'EE|E|WW|W|', ...
            'DD|D|', ...
            'Aaa|AAA', ...
            ')'];
        
        while true
            found = false;
            if true % ##### MOSW
                replaceFunc = @replace; %#ok<NASGU>
                fmt = regexprep(fmt, ptn, '${replaceFunc($1)}', 'once');
            else
                fmt = mosw.dregexprep(fmt, ptn, @doReplace, 1, 'once'); %#ok<UNRCH>
            end
            if ~found
                break
            end
        end
        
        fmt = regexprep(fmt, ['&([', fragile, '])'], '$1');
        
        return
        
        
        
        
        function c = replace(c0)
            found = true;
            c = '%s';
            field{end+1} = c0;
            if ~isCalendar && any(c0(1) == 'MQqEW')
                isMonthNeeded = true;
            end
        end
    end 




    function Subs = doYear(Y)
        Subs = '';
        if ~isfinite(Y)
            return
        end
        switch field{j}
            case 'YYYY'
                Subs = sprintf('%04g', Y);
            case 'YY'
                Subs = sprintf('%04g', Y);
                if length(Subs) > 2
                    Subs = Subs(end-1:end);
                end
            case 'Y'
                Subs = sprintf('%g', Y);
        end
    end 




    function Subs = doPer( )
        Subs = '';
        if ~isfinite(iPer)
            return
        end
        switch field{j}
            case 'PP'
                Subs = sprintf('%02g', iPer);
            case 'P'
                if iFreq < 10
                    Subs = sprintf('%g', iPer);
                else
                    Subs = sprintf('%02g', iPer);
                end
            case 'R'
                try %#ok<TRYNC>
                    Subs = upperRomans{iPer};
                end
            case 'r'
                try %#ok<TRYNC>
                    Subs = lowerRomans{iPer};
                end
        end
    end 




    function Subs = doMonth(M)
        Subs = '';
        if ~isfinite(M)
            return
        end
        switch field{j}
            case {'MMMM', 'Mmmm', 'MMM', 'Mmm'}
                Subs = opt.months{M};
                if field{j}(1) == 'M'
                    Subs(1) = upper(Subs(1));
                else
                    Subs(1) = lower(Subs(1));
                end
                if field{j}(end) == 'M'
                    Subs(2:end) = upper(Subs(2:end));
                else
                    Subs(2:end) = lower(Subs(2:end));
                end
                if length(field{j}) == 3
                    Subs = Subs(1:min(3, end));
                end
            case 'MM'
                Subs = sprintf('%02g', M);
            case 'M'
                Subs = sprintf('%g', M);
            case 'Q'
                try %#ok<TRYNC>
                    Subs = upperRomans{M};
                end
            case 'q'
                try %#ok<TRYNC>
                    Subs = lowerRomans{M};
                end
        end
    end 




    function subs = doDay( )
        subs = '';
        if ~isfinite(iDayC)
            return
        end
        switch field{j}
            case 'DD'
                subs = sprintf('%02g', iDayC);
            case 'D'
                subs = sprintf('%g', iDayC);
        end
    end




    function subs = doEom(Y, M)
        subs = '';
        if ~isfinite(Y) || ~isfinite(M)
            return
        end
        e = eomday(Y, M);
        switch field{j}
            case 'E'
                subs = sprintf('%g', e);
            case 'EE'
                subs = sprintf('%02g', e);
        end
    end




    function subs = doEomW(Y, M)
        subs = '';
        if ~isfinite(Y) || ~isfinite(M)
            return
        end
        e = eomday(Y, M);
        w = weekday(datenum(Y, M, e));
        if w == 1
            e = e - 2;
        elseif w == 7
            e = e - 1;
        end
        switch field{j}
            case 'W'
                subs = sprintf('%g', e);
            case 'WW'
                subs = sprintf('%02g', e);
        end
    end




    function subs = doDow(A)
        subs = daysOfWeek{A};
        if strcmp(field{j}, 'Aaa')
            subs = subs(1:3);
        elseif strcmp(field{j}, 'AAA')
            subs = upper(subs(1:3));
        end
    end




    function m = calculateMonth( )
        % Non-calendar month.
        m = NaN;
        switch iFreq
            case {1, 2, 4, 6}
                m = per2month(iPer, iFreq, opt.standinmonth);
            case 12
                m = iPer;
            case 52
                % Non-calendar month of a weekly date is the month that contains Thursday.
                [~, m] = datevec( double(iMsd+3) );
        end
    end




    function subs = subsFreqLetter( )
        subs = '';
        switch iFreq
            case 1
                subs = opt.freqletters(1);
            case 2
                subs = opt.freqletters(2);
            case 4
                subs = opt.freqletters(3);
            case 6
                subs = opt.freqletters(4);
            case 12
                subs = opt.freqletters(5);
            case 52
                subs = opt.freqletters(6);
        end
        if isequal(field{j}, 'f')
            subs = lower(subs);
        end
    end
end
