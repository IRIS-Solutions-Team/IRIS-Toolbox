function dateCode = str2dat(string, varargin)
% numeric.str2dat  Convert strings to serial date numbers
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser configStruct
if isempty(parser)
    configStruct = iris.get( );
    parser = extend.InputParser('dates.str2dat');
    parser.addRequired('InputString', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    parser.addParameter({'EnforceFrequency', 'Freq'}, false, @(x) isequal(x, false) || isempty(x) || strcmpi(x, 'Daily') || ((isa(x, 'Frequency') || isnumeric(x)) && isscalar(x) && any(x==configStruct.Freq)));
    parser.addDateOptions( );
end

if ~isempty(varargin) && isstruct(varargin{1})
    varargin = extend.InputParser.extractDateOptionsFromStruct(varargin{1});
end
parser.parse(string, varargin{:});
opt = parser.Options;

if isempty(opt.EnforceFrequency)
    opt.EnforceFrequency = false;
end

%--------------------------------------------------------------------------

parseDateFormatOption( );

longMonthList = sprintf('%s|',opt.Months{:});
longMonthList(end) = '';
shortMonthList = regexp(opt.Months,'\w{1,3}','match','once');
shortMonthList = sprintf('%s|',shortMonthList{:});
shortMonthList(end) = '';
romanList = 'xii|xi|x|ix|viii|vii|vi|v|iv|iii|ii|i|iv|v|x';

if ischar(string)
    string = cellstr(string);
end

dateCode = nan(size(string));
if isempty(string)
    return
end

ptn = parsePattern( );
tkn = regexpi(string, ptn, 'names', 'once');
[year, per, day, month, freq, inxPeriod] = parseDates(tkn, configStruct, opt);

inxCalendarDaily = freq==Frequency.DAILY;
inxCalendarWeekly = freq==Frequency.WEEKLY & ~inxPeriod;

if any(inxCalendarWeekly)
    dateCode(inxCalendarWeekly) = numeric.ww( year(inxCalendarWeekly), ...
                                              month(inxCalendarWeekly), ...
                                              day(inxCalendarWeekly) );
end

if any(inxCalendarDaily)
    dateCode(inxCalendarDaily) = numeric.dd( year(inxCalendarDaily), ...
                                             month(inxCalendarDaily), ...
                                             day(inxCalendarDaily) );
end

if any(inxPeriod)
    dateCode(inxPeriod) = numeric.datecode( freq(inxPeriod), ...
                                            year(inxPeriod), ...
                                            per(inxPeriod) );
    % Try Indeterminate frequency for NaN dates.
    inxNaN = inxPeriod & isnan(dateCode);
    for i = find(inxNaN(:).')
        aux = sscanf(string{i}, '%g');
        aux = round(aux);
        if ~isempty(aux)
            dateCode(i) = aux;
        end
    end
end

return




    function x = parsePattern( )
        x = upper(opt.DateFormat);
        x = regexptranslate('escape', x);
        x = regexprep(x,'(?<!%)\*', '.*?');
        x = regexprep(x,'(?<!%)\?', '.');
        subs = { ...
            '(?<!%)YYYY', '(?<LongYear>\d{4})'; ... Four-digit year
            '(?<!%)YY', '(?<ShortYear>\d{2})'; ... Last two digits of year
            '(?<!%)Y', '(?<LongYear>\d{0,4})'; ... One to four digits of year
            '(?<!%)PP', '(?<LongPeriod>\d{2})'; ... Two-digit period
            '(?<!%)P', '(?<ShortPeriod>\d{0,2})'; ... Empty or one- or two-digit period
            '(?<!%)MMMM', ['(?<Month>', longMonthList, ')']; ... Full name of month
            '(?<!%)MMM', ['(?<Month>', shortMonthList, ')']; ... Three-letter name of month
            '(?<!%)MM', '(?<NumericMonth>\d{2})'; ... Two-digit month
            '(?<!%)M', '(?<NumericMonth>\d{1,2})'; ... One- or two-digit month
            '(?<!%)Q', ['(?<RomanMonth>', romanList, ')']; ... Roman numerals for month
            '(?<!%)R', ['(?<RomanPeriod>', romanList, ')']; ... Roman numerals for period
            '(?<!%)I', '(?<Indeterminate>\d+)'; ... Any number of digits for Indeterminate frequency
            '(?<!%)DD', '(?<LongDay>\d{2})'; ... Two-digit day
            '(?<!%)D', '(?<VarDay>\d{1,2})'; ... One- or two-digit day
            '(?<!%)F', ['(?<FreqLetter>[', opt.FreqLetters, '])']; ... Frequency letter
        };
        for ii = 1 : size(subs, 1)
            x = regexprep(x, subs{ii, 1}, char(1000+ii));
        end
        for ii = 1 : size(subs, 1)
            x = strrep(x, char(1000+ii), subs{ii, 2});
        end
        x = regexprep(x,'%(\w)', '$1');
    end%

    


    function parseDateFormatOption( )
        if strcmpi(opt.EnforceFrequency, 'Daily')
            opt.EnforceFrequency = Frequency.DAILY;
        end
        
        if (isstruct(opt.DateFormat) || iscell(opt.DateFormat)) ...
            && numel(opt.DateFormat)~=1
            throw( exception.Base('Dates:OnlyScalarFormatAllowed', 'error') );
        end

        if isstruct(opt.DateFormat)
            if isequal(opt.EnforceFrequency, false)
                opt.DateFormat = opt.DateFormat.qq;
            else
                opt.DateFormat = DateWrapper.chooseFormat(opt.DateFormat, opt.EnforceFrequency);
            end
        end
        
        if strncmp(opt.DateFormat, '$', 1) && ...
                ( isequal(opt.EnforceFrequency, false) || isequal(opt.EnforceFrequency, 0) )
            opt.EnforceFrequency = Frequency.DAILY;
        end
        
        if strncmp(opt.DateFormat, '$', 1)
            opt.DateFormat(1) = '';
        end
    end%
end%


%
% Local functions
%


function [year, per, day, month, freq, inxPeriod] = parseDates(cellToken, configStruct, opt)
    [thisYear, ~] = datevec(now( ));
    thisCentury = 100*floor(thisYear/100);
    freq = nan(size(cellToken));

    day = nan(size(cellToken));
    % Set period to 1 by default so that e.g. YPF is correctly matched with
    % 2000Y.
    per = ones(size(cellToken));
    month = nan(size(cellToken));
    year = nan(size(cellToken));
    inxPeriod = false(size(cellToken));

    for i = 1 : length(cellToken)
        tkn = cellToken{i};
        if length(tkn)~=1
            continue
        end
        
        if isfield(tkn, 'Indeterminate') && ~isempty(tkn.Indeterminate)
            freq(i) = Frequency.INTEGER;
            per(i) = sscanf(tkn.Indeterminate, '%g');
            continue
        end

        if isfield(tkn, 'FreqLetter') && ~isempty(tkn.FreqLetter)
            ix = upper(opt.FreqLetters)==upper(tkn.FreqLetter);
            if any(ix)
                freq(i) = configStruct.RegularFrequencies(ix);
            end
        end
        
        if isfield(tkn, 'ShortYear')
            ithYear = sscanf(tkn.ShortYear,'%g');
            ithYear = ithYear + thisCentury;
            if ithYear - thisYear>20
                ithYear = ithYear - 100;
            elseif ithYear - thisYear<=-80
                ithYear = ithYear + 100;
            end
            year(i) = ithYear;
        end

        if isfield(tkn, 'LongYear')
            ithYear = sscanf(tkn.LongYear, '%g');
            if ~isempty(ithYear)
                year(i) = ithYear;
            end
        end
        
        if isfield(tkn, 'ShortPeriod')
            if ~isempty(tkn.ShortPeriod)
                per(i) = sscanf(tkn.ShortPeriod, '%g');
            else
                per(i) = 1;
            end
        end
        
        if isfield(tkn, 'LongPeriod')
            per(i) = sscanf(tkn.LongPeriod, '%g');
        end
        
        if isfield(tkn, 'RomanPeriod')
            per(i) = roman2num(tkn.RomanPeriod);
        end
        
        if isfield(tkn, 'RomanMonth')
            month(i) = roman2num(tkn.RomanMonth);
        end
        
        if isfield(tkn, 'NumericMonth')
            month(i) = sscanf(tkn.NumericMonth, '%g');
        end
        
        if isfield(tkn, 'Month')
            ix = strncmpi(tkn.Month, opt.Months, length(tkn.Month));
            if any(ix)
                month(i) = find(ix, 1);
            end
        end
        if ~isnumeric(month(i)) || isinf(month(i))
            month(i) = NaN;
        end
        
        if isfield(tkn, 'VarDay')
            day(i) = sscanf(tkn.VarDay, '%g');
        end
        if isfield(tkn, 'LongDay')
            day(i) = sscanf(tkn.LongDay, '%g');
        end
        
        if ~isequal(opt.EnforceFrequency, false)
            freq(i) = opt.EnforceFrequency;
        elseif tryYearlyFrequency(tkn)
            freq(i) = Frequency.YEARLY;
        end
        
        inxPeriod(i) = freq(i)~=Frequency.DAILY ...
            && ( isfield(tkn, 'LongPeriod') ...
                 || isfield(tkn, 'ShortPeriod') ...
                 || isfield(tkn, 'RomanPeriod') ...
                 || freq(i)==Frequency.YEARLY );
        
        if ~inxPeriod(i) && ~isnan(month(i))
            if isnan(freq(i)) || freq(i)==Frequency.MONTHLY
                freq(i) = Frequency.MONTHLY;
                per(i) = month(i);
                inxPeriod(i) = true;
            elseif freq(i)<Frequency.MONTHLY
                per(i) = month2per(month(i), freq(i));
                inxPeriod(i) = true;
            end
        end
        
        % Disregard periods for annual dates. This is now also consistent with
        % the YY function.
        if freq(i)==Frequency.YEARLY
            per(i) = 1;
        end
    end

    % Try to guess frequency for periodic dates by the highest period found
    % among all dates passed in.
    if all(isnan(freq)) && all(inxPeriod)
        maxPer = max(per(~isnan(per)));
        if ~isempty(maxPer)
            ix = find(maxPer<=configStruct.RegularFrequencies, 1, 'first');
            if ~isempty(ix)
                freq(:) = configStruct.RegularFrequencies(ix);
            end
        end
    end
end%


%
% Local Functions
%


function per = roman2num(romanPer)
    per = 1;
    list = { 'i', 'ii', 'iii', 'iv', 'v', 'vi', ...
             'vii', 'viii', 'ix', 'x', 'xi', 'xii' };
    ix = strcmpi(romanPer, list);
    if any(ix)
        per = find(ix, 1);
    end
end%



function flag = tryYearlyFrequency(tkn)
    listFields = fieldnames(tkn);
    flag = numel(listFields)==1 && ~isempty(strfind(listFields{1}, 'Year'));
end%

