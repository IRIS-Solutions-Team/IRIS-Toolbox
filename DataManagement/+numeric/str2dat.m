% numeric.str2dat  Convert strings to serial date numbers
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function dateCode = str2dat(inputString, varargin)

%( Input parser
persistent pp configStruct
if isempty(pp)
    configStruct = iris.get();
    pp = extend.InputParser();
    addRequired(pp, 'InputString', @(x) ischar(x) || iscellstr(x) || isstring(x));
    addDateOptions(pp);
end
%)

if ~isempty(varargin) && isstruct(varargin{1})
    varargin = extend.InputParser.extractDateOptionsFromStruct(varargin{1});
end
opt = parse(pp, inputString, varargin{:});

if isempty(opt.EnforceFrequency)
    opt.EnforceFrequency = false;
end

%--------------------------------------------------------------------------

primaryFreqLetters = frequency.getPrimaryFreqLetters();
here_parseDateFormatOption();

longMonthList = sprintf('%s|',opt.Months{:});
longMonthList(end) = '';
shortMonthList = regexp(opt.Months,'\w{1,3}','match','once');
shortMonthList = sprintf('%s|',shortMonthList{:});
shortMonthList(end) = '';
romanList = 'xii|xi|x|ix|viii|vii|vi|v|iv|iii|ii|i|iv|v|x';

inputString = string(inputString);

dateCode = nan(size(inputString));
if isempty(inputString)
    return
end

ptn = here_parseFormat();
tkn = regexpi(cellstr(inputString), ptn, 'names', 'once', 'forceCellOutput');
[year, per, day, month, freq, inxPeriod] = local_parseDateStrings(tkn, configStruct, opt);

inxCalendarDaily = freq==frequency.DAILY;
inxCalendarWeekly = freq==frequency.WEEKLY & ~inxPeriod;

if any(inxCalendarWeekly)
    dateCode(inxCalendarWeekly) = numeric.ww( ...
        year(inxCalendarWeekly), month(inxCalendarWeekly), day(inxCalendarWeekly) ...
    );
end

if any(inxCalendarDaily)
    dateCode(inxCalendarDaily) = numeric.dd( ...
        year(inxCalendarDaily), ...
        month(inxCalendarDaily), ...
        day(inxCalendarDaily) ...
    );
end

if any(inxPeriod)
    dateCode(inxPeriod) = numeric.datecode( freq(inxPeriod), ...
                                            year(inxPeriod), ...
                                            per(inxPeriod) );
    % Try Indeterminate frequency for NaN dates.
    inxNaN = inxPeriod & isnan(dateCode);
    for i = find(reshape(inxNaN, 1, [ ]));
        aux = sscanf(inputString(i), '%g');
        aux = round(aux);
        if ~isempty(aux)
            dateCode(i) = aux;
        end
    end
end

return


    function x = here_parseFormat()
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
            '(?<!%)F', ['(?<FreqLetter>[', char(primaryFreqLetters), '])']; ... Frequency letter
        };
        for ii = 1 : size(subs, 1)
            x = regexprep(x, subs{ii, 1}, char(1000+ii));
        end
        for ii = 1 : size(subs, 1)
            x = strrep(x, char(1000+ii), subs{ii, 2});
        end
        x = regexprep(x,'%(\w)', '$1');
    end%




    function here_parseDateFormatOption()
        if strcmpi(opt.EnforceFrequency, 'Daily')
            opt.EnforceFrequency = frequency.DAILY;
        end

        if (isstruct(opt.DateFormat) || iscell(opt.DateFormat)) ...
            && numel(opt.DateFormat)~=1
            throw( exception.Base('Dates:OnlyScalarFormatAllowed', 'error') );
        end

        if isstruct(opt.DateFormat)
            if islogical(opt.EnforceFrequency) && isequal(opt.EnforceFrequency, false)
                opt.DateFormat = opt.DateFormat.qq;
            else
                opt.DateFormat = Dater.chooseFormat(opt.DateFormat, opt.EnforceFrequency);
            end
        end

        if strncmp(opt.DateFormat, '$', 1) && ...
                ( isequal(opt.EnforceFrequency, false) || isequal(opt.EnforceFrequency, 0) )
            opt.EnforceFrequency = frequency.DAILY;
        end

        if strncmp(opt.DateFormat, '$', 1)
            opt.DateFormat(1) = '';
        end
    end%
end%


%
% Local functions
%


function [year, per, day, month, freq, inxPeriod] = local_parseDateStrings(cellToken, configStruct, opt)
    [thisYear, ~] = datevec(now());
    thisCentury = 100*floor(thisYear/100);
    freq = nan(size(cellToken));

    day = nan(size(cellToken));
    % Set period to 1 by default so that e.g. YPF is correctly matched with
    % 2000Y.
    per = ones(size(cellToken));
    month = nan(size(cellToken));
    year = nan(size(cellToken));
    inxPeriod = false(size(cellToken));

    for i = 1 : numel(cellToken)
        tkn = cellToken{i};
        if numel(tkn)~=1
            continue
        end

        if isfield(tkn, 'Indeterminate') && ~isempty(tkn.Indeterminate)
            freq(i) = frequency.INTEGER;
            per(i) = sscanf(tkn.Indeterminate, '%g');
            continue
        end

        if isfield(tkn, 'FreqLetter') && ~isempty(tkn.FreqLetter)
            freq(i) = frequency.fromString(tkn.FreqLetter);
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
            per(i) = local_roman2Num(tkn.RomanPeriod);
        end

        if isfield(tkn, 'RomanMonth')
            month(i) = local_roman2Num(tkn.RomanMonth);
        end

        if isfield(tkn, 'NumericMonth')
            month(i) = sscanf(tkn.NumericMonth, '%g');
        end

        if isfield(tkn, 'Month')
            ix = strncmpi(tkn.Month, opt.Months, numel(tkn.Month));
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
        elseif local_tryYearlyFrequency(tkn)
            freq(i) = frequency.YEARLY;
        end

        inxPeriod(i) = freq(i)~=frequency.DAILY ...
            && ( isfield(tkn, 'LongPeriod') ...
                 || isfield(tkn, 'ShortPeriod') ...
                 || isfield(tkn, 'RomanPeriod') ...
                 || freq(i)==frequency.YEARLY );

        if ~inxPeriod(i) && ~isnan(month(i))
            if isnan(freq(i)) || freq(i)==frequency.MONTHLY
                freq(i) = frequency.MONTHLY;
                per(i) = month(i);
                inxPeriod(i) = true;
            elseif freq(i)<frequency.MONTHLY
                per(i) = month2per(month(i), freq(i));
                inxPeriod(i) = true;
            end
        end

        % Disregard periods for annual dates. This is now also consistent with
        % the YY function.
        if freq(i)==frequency.YEARLY
            per(i) = 1;
        end
    end
end%




function per = local_roman2Num(romanPer)
    per = 1;
    list = { 'i', 'ii', 'iii', 'iv', 'v', 'vi', ...
             'vii', 'viii', 'ix', 'x', 'xi', 'xii' };
    ix = strcmpi(romanPer, list);
    if any(ix)
        per = find(ix, 1);
    end
end%



function flag = local_tryYearlyFrequency(tkn)
    listFields = fieldnames(tkn);
    flag = numel(listFields)==1 && ~isempty(strfind(listFields{1}, 'Year'));
end%

