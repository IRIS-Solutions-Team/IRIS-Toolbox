function outputDate = convert(inputDate, toFreq, varargin)
% convert  Convert dates to another frequency
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%( Input parser
persistent pp
if isempty(pp)
    validFrequencies = iris.get('Freq');
    validFrequencies = setdiff(validFrequencies, Frequency.INTEGER);
    pp = extend.InputParser('numeric.convert');
    pp.KeepDefaultOptions = true;
    addRequired(pp, 'inputDate', @isnumeric);
    addRequired(pp, 'newFreq', @(x) isnumeric(x) && isscalar(x) && any(x==validFrequencies));
    addDateOptions(pp);
end
%)
[hasSkipped, opt] = maybeSkip(pp, varargin{:});
if ~hasSkipped
    opt = parse(pp, inputDate, toFreq, varargin{:});
end

%--------------------------------------------------------------------------

toFreqAsNumeric = double(toFreq);

inputDate = double(inputDate);

fromFreq = dater.getFrequency(inputDate);
inxFromInteger = fromFreq==0;
inxFromDaily = fromFreq==365;
inxFromWeekly = fromFreq==52;
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
    if toFreq==Frequency.DAILY
        toDay = getConversionDay(opt.ConversionDay, toYear, toMonth);
        outputDate(inxFromRegular) = numeric.dd(toYear, toMonth, toDay);
    elseif toFreq==Frequency.WEEKLY
        toDay = getConversionDay(opt.ConversionDay, toYear, toMonth);
        outputDate(inxFromRegular) = numeric.ww(toYear, toMonth, toDay);
    else
        outputDate(inxFromRegular) = numeric.datecode(toFreqAsNumeric, toYear, toPeriod);
    end
end

if any(inxFromWeekly(:))
    if toFreq==Frequency.DAILY
        x = ww2day(inputDate(inxFromWeekly), opt.WDay);
        outputDate(inxFromWeekly) = x;
    else
        x = ww2day(inputDate(inxFromWeekly), 'Thu');
        [toYear, toMonth] = datevec( double(x) );
        toPeriod = ceil(toMonth.*toFreqAsNumeric./12);
        outputDate(inxFromWeekly) = numeric.datecode(toFreqAsNumeric, toYear, toPeriod);
    end
end

if any(inxFromDaily(:))
    if toFreq==Frequency.DAILY
        outputDate(inxFromDaily) = inputDate(inxFromDaily);
    elseif toFreq==Frequency.WEEKLY
        outputDate(inxFromDaily) = numeric.day2ww(inputDate(inxFromDaily));
    else
        [toYear, toMonth, ~] = datevec( double(inputDate(inxFromDaily)) );
        toPeriod = ceil(toMonth.*toFreqAsNumeric./12);
        outputDate(inxFromDaily) = numeric.datecode(toFreqAsNumeric, toYear, toPeriod);
    end
end

end%


%
% Local Functions
%

function conversionDay = getConversionDay(conversionDay, toYear, toMonth)
    if isnumeric(conversionDay)
        return
    elseif strcmpi(conversionDay, 'First')
        conversionDay = 1;
    elseif strcmpi(conversionDay, 'Last')
        conversionDay = eomday(toYear, toMonth);
    end
end%

