function outputDate = convert(inputDate, toFreq, varargin)
% convert  Convert dates to another frequency
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('dates.convert');
    parser.addRequired('InputDate', @isnumeric);
    parser.addRequired('NewFreq', @(x) isnumeric(x) && isscalar(x) && any(x==[1, 2, 4, 6, 12, 52, 365]));
    parser.addDateOptions( );
end
parser.parse(inputDate, toFreq, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

inputDate = double(inputDate);

fromFreq = DateWrapper.getFrequencyAsNumeric(inputDate);
ixFromZero = fromFreq==0;
ixFromDaily = fromFreq==365;
ixFromWeekly = fromFreq==52;
ixFromRegular = ~ixFromZero & ~ixFromWeekly & ~ixFromDaily;

outputDate = nan(size(inputDate));

if any(ixFromRegular(:))
    % Get year, period, and frequency of the original dates
    [fromYear, fromPer, fromFreq] = dat2ypf(inputDate(ixFromRegular));
    toYear = fromYear;
    % First, convert the original period to a corresponding month
    toMon = per2month(fromPer, fromFreq, opt.ConversionMonth);
    % Then, convert the month to the corresponding period of the request
    % frequnecy
    toPer = ceil(toMon.*toFreq./12);
    % Create new dates
    if toFreq==365
        outputDate(ixFromRegular) = dd(toYear, toMon, 1);
    else
        outputDate(ixFromRegular) = numeric.datecode(toFreq, toYear, toPer);
    end
end

if any(ixFromWeekly(:))
    if toFreq==365
        x = ww2day(inputDate(ixFromWeekly), opt.WDay);
        outputDate(ixFromWeekly) = x;
    else
        x = ww2day(inputDate(ixFromWeekly), 'Thu');
        [toYear, toMon] = datevec( double(x) );
        toPer = ceil(toMon.*toFreq./12);
        outputDate(ixFromWeekly) = numeric.datecode(toFreq, toYear, toPer);
    end
end

if any(ixFromDaily(:))
    if toFreq==365
        outputDate(ixFromDaily) = inputDate(ixFromDaily);
    elseif toFreq==52
        outputDate(ixFromDaily) = numeric.day2ww(inputDate(ixFromDaily));
    else
        [toYear, toMon, ~] = datevec( double(inputDate(ixFromDaily)) );
        toPer = ceil(toMon.*toFreq./12);
        outputDate(ixFromDaily) = numeric.datecode(toFreq, toYear, toPer);
    end
end

end%

