function newDat = convert(dat, toFreq, varargin)
% convert   Convert dates to another frequency.
%
% Syntax
% =======
%
%     newDat = convert(dat, newFreq, ...)
%
%
% Input arguments
% ================
%
%
% * `dat` [ numeric ] - IRIS serial date numbers that will be converted to
% the new frequency, `NewFreq`.
%
% * `newFreq` [ `1` | `2` | `4` | `6` | `12` | `52` | `365` ] - New
% frequency to which the dates `d1` will be converted.
%
%
% Output arguments
% =================
%
% * `newDat` [ numeric ] - IRIS serial date numbers representing the new
% frequency.
%
%
% Options
% ========
%
% * `'ConversionMonth='` [ numeric | `'last'` | *`1`* ] - Month that will be
% used to represent a certain period of time in low- to high-frequency
% conversions.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% Parse options.
opt = passvalopt('dates.convert', varargin{:});
opt = datdefaults(opt);

pp = inputParser( );
pp.addRequired('Dat', @isnumeric);
pp.addRequired('NewFreq', @(x) isnumericscalar(x) ...
    && any(x==[1, 2, 4, 6, 12, 52, 365]));
pp.parse(dat, toFreq);

%--------------------------------------------------------------------------

fromFreq = DateWrapper.getFrequencyFromNumeric(dat);
ixFromZero = fromFreq==0;
ixFromDaily = fromFreq==365;
ixFromWeekly = fromFreq==52;
ixFromRegular = ~ixFromZero & ~ixFromWeekly & ~ixFromDaily;

newDat = nan(size(dat));

if any(ixFromRegular(:))
    % Get year, period, and frequency of the original dates.
    [fromYear, fromPer, fromFreq] = dat2ypf(dat(ixFromRegular));
    toYear = fromYear;
    % First, convert the original period to a corresponding month.
    toMon = per2month(fromPer, fromFreq, opt.ConversionMonth);
    % Then, convert the month to the corresponding period of the request
    % frequnecy.
    toPer = ceil(toMon.*toFreq./12);
    % Create new dates.
    if toFreq==365
        newDat(ixFromRegular) = dd(toYear, toMon, 1);
    else
        newDat(ixFromRegular) = datcode(toFreq, toYear, toPer);
    end
end

if any(ixFromWeekly(:))
    if toFreq==365
        x = ww2day(dat(ixFromWeekly), opt.Wday);
        newDat(ixFromWeekly) = x;
    else
        x = ww2day(dat(ixFromWeekly), 'Thu');
        [toYear, toMon] = datevec( double(x) );
        toPer = ceil(toMon.*toFreq./12);
        newDat(ixFromWeekly) = datcode(toFreq, toYear, toPer);
    end
end

if any(ixFromDaily(:))
    if toFreq==365
        newDat(ixFromDaily) = dat(ixFromDaily);
    elseif toFreq==52
        newDat(ixFromDaily) = day2ww(dat(ixFromDaily));
    else
        [toYear, toMon, ~] = datevec( double(dat(ixFromDaily)) );
        toPer = ceil(toMon.*toFreq./12);
        newDat(ixFromDaily) = datcode(toFreq, toYear, toPer);
    end
end

newDat = DateWrapper(newDat);

end
