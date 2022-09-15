% convert  Convert dates to another frequency
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDate = convert(inputDate, toFreq, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser();
    pp.KeepDefaultOptions = true;
    addRequired(pp, 'inputDate', @isnumeric);
    addRequired(pp, 'newFreq', @(x) isa(Frequency(x), 'Frequency'));
    addDateOptions(pp);
end
%)

[hasSkipped, opt] = maybeSkip(pp, varargin{:});
if ~hasSkipped
    opt = parse(pp, inputDate, toFreq, varargin{:});
end

%--------------------------------------------------------------------------

toFreq = Frequency(toFreq);
toFreqAsNumeric = double(toFreq);
inputDate = double(inputDate);

fromFreq = dater.getFrequency(inputDate);
inxFromInteger = fromFreq==frequency.INTEGER;
inxFromDaily = fromFreq==frequency.DAILY;
inxFromWeekly = fromFreq==frequency.WEEKLY;
inxFromRegular = ~inxFromInteger & ~inxFromWeekly & ~inxFromDaily;

outputDate = nan(size(inputDate));

if any(inxFromRegular(:))
    % Get year, period, and frequency of the original dates
    [fromYear, fromPer, fromFreq] = dat2ypf(inputDate(inxFromRegular));
    toYear = fromYear;
    % First, convert the original period to a corresponding month
    toMonth = per2month(fromPer, fromFreq, opt.ConversionMonth);
    % Then, convert the month to the corresponding period of the request
    % frequnecy
    toPeriod = ceil(toMonth.*toFreqAsNumeric./12);
    % Create to dates
    if toFreq==frequency.DAILY
        toDay = getConversionDay(opt.ConversionDay, toYear, toMonth);
        outputDate(inxFromRegular) = dater.dd(toYear, toMonth, toDay);
    elseif toFreq==frequency.WEEKLY
        toDay = getConversionDay(opt.ConversionDay, toYear, toMonth);
        outputDate(inxFromRegular) = dater.ww(toYear, toMonth, toDay);
    else
        outputDate(inxFromRegular) = dater.datecode(toFreqAsNumeric, toYear, toPeriod);
    end
end

if any(inxFromWeekly(:))
    if toFreq==frequency.DAILY
        x = ww2day(inputDate(inxFromWeekly), opt.WDay);
        outputDate(inxFromWeekly) = x;
    else
        x = ww2day(inputDate(inxFromWeekly), 'Thu');
        [toYear, toMonth] = datevec( double(x) );
        toPeriod = ceil(toMonth.*toFreqAsNumeric./12);
        outputDate(inxFromWeekly) = dater.datecode(toFreqAsNumeric, toYear, toPeriod);
    end
end

if any(inxFromDaily(:))
    if toFreq==frequency.DAILY
        outputDate(inxFromDaily) = inputDate(inxFromDaily);
    elseif toFreq==frequency.WEEKLY
        outputDate(inxFromDaily) = dater.day2ww(inputDate(inxFromDaily));
    else
        [toYear, toMonth, ~] = datevec( double(inputDate(inxFromDaily)) );
        toPeriod = ceil(toMonth.*toFreqAsNumeric./12);
        outputDate(inxFromDaily) = dater.datecode(toFreqAsNumeric, toYear, toPeriod);
    end
end

end%


%
% Local Functions
%

function conversionDay = getConversionDay(conversionDay, toYear, toMonth)
    if isnumeric(conversionDay)
        return
    elseif strcmpi(conversionDay, 'first')
        conversionDay = 1;
    elseif strcmpi(conversionDay, 'last')
        conversionDay = eomday(toYear, toMonth);
    end
end%

