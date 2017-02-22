function dat = str2dat(string, varargin)
% str2dat  Convert strings to IRIS serial date numbers.
%
% Syntax
% =======
%
%     dat = str2dat(s, ...)
%
%
% Input arguments
% ================
%
% * `s` [ char | cellstr ] - Cell array of strings representing dates.
%
%
% Output arguments
% =================
%
% * `dat` [ dates.Dte ] - Dates.
%
%
% Options
% ========
%
% * `'Freq='` [ `1` | `2` | `4` | `6` | `12` | `52` | `365` | *empty* ] -
% Enforce frequency.
%
% See help on [`dat2str`](dates/dat2str) for other options available.
%
%
% Description
% ============
%
%
% Example
% ========
%
%     d = str2dat('04-2010','dateFormat=','MM-YYYY');
%     dat2str(d)
%     ans =
%        '2010M04'
%
%     d = str2dat('04-2010','dateFormat=','MM-YYYY','freq=',4);
%     dat2str(d)
%     ans =
%        '2010Q2'
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

opt = passvalopt('dates.str2dat',varargin{:});
opt = datdefaults(opt);

%--------------------------------------------------------------------------

parseDateFormat( );

longMonthList = sprintf('%s|',opt.months{:});
longMonthList(end) = '';
shortMonthList = regexp(opt.months,'\w{1,3}','match','once');
shortMonthList = sprintf('%s|',shortMonthList{:});
shortMonthList(end) = '';
romanList = 'xii|xi|x|ix|viii|vii|vi|v|iv|iii|ii|i|iv|v|x';

if ischar(string)
    string = cellstr(string);
end

dat = nan(size(string));
if isempty(string)
    return
end

ptn = parsePattern( );
tkn = regexpi(string, ptn, 'names', 'once');
[year, per, day, month, freq, ixPeriod] = parseDates(tkn, opt);

ixCalendarDaily = freq==365;
ixCalendarWeekly = freq==52 & ~ixPeriod;

if any(ixCalendarWeekly)
    dat(ixCalendarWeekly) = ww( ...
        year(ixCalendarWeekly), ...
        month(ixCalendarWeekly), ...
        day(ixCalendarWeekly) ...
        );
end

if any(ixCalendarDaily)
    dat(ixCalendarDaily) = dd( ...
        year(ixCalendarDaily), ...
        month(ixCalendarDaily), ...
        day(ixCalendarDaily) ...
        );
end

if any(ixPeriod)
    dat(ixPeriod) = datcode( ...
        freq(ixPeriod), ...
        year(ixPeriod), ...
        per(ixPeriod) ...
        );
    % Try indeterminate frequency for NaN dates.
    ixNan = ixPeriod & isnan(dat);
    for i = find(ixNan(:).')
        aux = sscanf(string{i}, '%g');
        aux = round(aux);
        if ~isempty(aux)
            dat(i) = aux;
        end
    end
end

dat = dates.Date(dat);

return




    function x = parsePattern( )
        x = upper(opt.dateformat);
        x = regexptranslate('escape', x);
        x = regexprep(x,'(?<!%)\*', '.*?');
        x = regexprep(x,'(?<!%)\?', '.');
        escapeLongMonth = '%L%O%N%G%M%O%N%T%H';
        escapeShortMonth ='%S%H%O%R%T%M%O%N%T%H';
        escapeFreq = '%F%R%E%Q%U%E%N%C%Y';
        escapeRomanMonth = '%R%O%M%A%N%M%O%N%T%H';
        escapeRomanPer = '%R%O%M%A%N%P%E%R';
        subs = { ...
            '(?<!%)YYYY', '(?<longyear>\\d{4})'; ... Four-digit year
            '(?<!%)YY', '(?<shortyear>\\d{2})'; ... Last two digits of year
            '(?<!%)Y', '(?<longyear>\\d{0,4})'; ... One to four digits of year
            '(?<!%)PP', '(?<longperiod>\\d{2})'; ... Two-digit period
            '(?<!%)P', '(?<shortperiod>\\d*)'; ... Any number of digits of period
            '(?<!%)MMMM', escapeLongMonth; ... Full name of months
            '(?<!%)MMM', escapeShortMonth; ... Three-letter name of month
            '(?<!%)MM', '(?<numericmonth>\\d{2})'; ... Two-digit month
            '(?<!%)M', '(?<numericmonth>\\d{1,2})'; ... One- or two-digit month
            '(?<!%)Q', escapeRomanMonth; ... Roman numerals for month
            '(?<!%)R', escapeRomanPer; ... Roman numerals for period
            '(?<!%)I', '(?<indeterminate>\\d+)'; ... Any number of digits for indeterminate frequency
            '(?<!%)DD', '(?<longday>\\d{2})'; ... Two-digit day
            '(?<!%)D', '(?<varday>\\d{1,2})'; ... One- or two-digit day
            '(?<!%)F', escapeFreq; ... Frequency letter
            };
        
        for ii = 1 : size(subs, 1)
            x = regexprep(x, subs{ii,1}, subs{ii,2});
        end
        x = strrep(x, escapeLongMonth, ['(?<month>', longMonthList, ')']);
        x = strrep(x, escapeShortMonth, ['(?<month>', shortMonthList, ')']);
        x = strrep(x, escapeRomanMonth, ['(?<romanmonth>', romanList, ')']);
        x = strrep(x, escapeRomanPer, ['(?<romanperiod>', romanList, ')']);
        x = strrep(x, escapeFreq, ['(?<freqletter>[', opt.freqletters, '])']);
        
        x = regexprep(x,'%(\w)', '$1');
    end




    function parseDateFormat( )
        if isequal(opt.freq, 'daily')
            opt.freq = 365;
        end
        
        if isstruct(opt.dateformat)
            if isempty(opt.freq)
                opt.dateformat = opt.dateformat.qq;
            else
                opt.dateformat = mydateformat(opt.dateformat,opt.freq);
            end
        end
        
        if strncmp(opt.dateformat,'$',1) && ...
                ( isempty(opt.freq) || isequal(opt.freq, 0) )
            opt.freq = 365;
        end
        
        if strncmp(opt.dateformat, '$', 1)
            opt.dateformat(1) = '';
        end
    end
end




function [year, per, day, month, freq, ixPeriod] = parseDates(cellToken, opt)
[thisYear, ~] = datevec(now( ));
thisCentury = 100*floor(thisYear/100);
vecFreq = [1, 2, 4, 6, 12, 52];
freq = nan(size(cellToken));

day = nan(size(cellToken));
% Set period to 1 by default so that e.g. YPF is correctly matched with
% 2000Y.
per = ones(size(cellToken));
month = nan(size(cellToken));
year = nan(size(cellToken));
ixPeriod = false(size(cellToken));

for i = 1 : length(cellToken)
    tkn = cellToken{i};
    if length(tkn)~=1
        continue
    end
    
    if isfield(tkn, 'indeterminate') ...
            && ~isempty(tkn.indeterminate)
        freq(i) = 0;
        per(i) = sscanf(tkn.indeterminate, '%g');
        continue
    end

    if isfield(tkn, 'freqletter') && ~isempty(tkn.freqletter)
        ix = upper(opt.freqletters)==upper(tkn.freqletter);
        if any(ix)
            freq(i) = vecFreq(ix);
        end
    end
    
    if isfield(tkn, 'shortyear')
        yeari = sscanf(tkn.shortyear,'%g');
        yeari = yeari + thisCentury;
        if yeari - thisYear>20
            yeari = yeari - 100;
        elseif yeari - thisYear<=-80
            yeari = yeari + 100;
        end
        year(i) = yeari;
    end
    if isfield(tkn, 'longyear')
        yeari = sscanf(tkn.longyear, '%g');
        if ~isempty(yeari)
            year(i) = yeari;
        end
    end
    
    if isfield(tkn, 'shortperiod')
        if ~isempty(tkn.shortperiod)
            per(i) = sscanf(tkn.shortperiod, '%g');
        else
            per(i) = 1;
        end
    end
    
    if isfield(tkn, 'longperiod')
        per(i) = sscanf(tkn.longperiod, '%g');
    end
    
    if isfield(tkn, 'romanperiod')
        per(i) = roman2num(tkn.romanperiod);
    end
    
    if isfield(tkn, 'romanmonth')
        month(i) = roman2num(tkn.romanmonth);
    end
    
    if isfield(tkn, 'numericmonth')
        month(i) = sscanf(tkn.numericmonth, '%g');
    end
    
    if isfield(tkn, 'month')
        ix = strncmpi(tkn.month, opt.months, length(tkn.month));
        if any(ix)
            month(i) = find(ix, 1);
        end
    end
    if ~isnumeric(month(i)) || isinf(month(i))
        month(i) = NaN;
    end
    
    if isfield(tkn, 'varday')
        day(i) = sscanf(tkn.varday, '%g');
    end
    if isfield(tkn, 'longday')
        day(i) = sscanf(tkn.longday, '%g');
    end
    
    if ~isempty(opt.freq)
        freq(i) = opt.freq;
    end
    
    ixPeriod(i) = freq(i)~=365 ...
        && ( isfield(tkn, 'longperiod') ...
        || isfield(tkn, 'shortperiod') ...
        || isfield(tkn, 'romanperiod') );
    
    if ~ixPeriod(i) && ~isnan(month(i))
        if isnan(freq(i)) || freq(i)==12
            freq(i) = 12;
            per(i) = month(i);
            ixPeriod(i) = true;
        elseif freq(i)<12
            per(i) = month2per(month(i), freq(i));
            ixPeriod(i) = true;
        end
    end
    
    % Disregard periods for annual dates. This is now also consistent with
    % the YY function.
    if freq(i)==1
        per(i) = 1;
    end
end

% Try to guess frequency for periodic dates by the highest period found
% among all dates passed in.
if all(isnan(freq)) && all(ixPeriod)
    maxPer = max(per(~isnan(per)));
    if ~isempty(maxPer)
        ix = find(maxPer<=vecFreq, 1, 'first');
        if ~isempty(ix)
            freq(:) = vecFreq(ix);
        end
    end
end
end




function per = roman2num(romanPer)
per = 1;
list = { ...
    'i', 'ii', 'iii', 'iv', 'v', 'vi', ...
    'vii', 'viii', 'ix', 'x', 'xi', 'xii', ...
    };
ix = strcmpi(romanPer, list);
if any(ix)
    per = find(ix, 1);
end
end
