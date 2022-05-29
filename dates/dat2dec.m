% dat2dec  Convert dates to decimal grid
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     Dec = dat2dec(Dat, ~Pos)
%
%
% __Input Arguments__
%
% * `Dat` [ numeric ] - IRIS serial date number.
%
% * `~Pos` [ *`'start'`* | `'centre'` | `'end'` ] - Point within the period
% that will represent the date; if omitted, `~Pos` is set to `'start'`.
%
%
% __Output Arguments__
%
% * `Dec` [ numeric ] - Decimal grid representing the input dates, 
% computed as `Year + (Per-1)/Freq`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function dec = dat2dec(dat, pos)

if nargin<2
    userPosition = '';
    pos = 's';
else
    pos = char(pos);
    pos = lower(pos(1));
    userPosition = pos;
end

%--------------------------------------------------------------------------

dec = nan(size(dat));
if isempty(dat)
    return
end

[year, per, freq] = dat2ypf(dat);

Frequency.checkMixedFrequency(freq);
freq = freq(1);

switch freq
    case frequency.INTEGER
        dec = per;
    case frequency.DAILY
        if isempty(userPosition)
            dec = per;
        else
            [year, month, day] = datevec(double(dat));
            startOfYear = floor(datenum(year, 1, 1));
            per = round(floor(dat) - startOfYear + 1);
            adjust = getAdjustmentFactor(pos);
            dec = year + (per + adjust) ./ 365;
        end
    case {frequency.YEARLY, frequency.HALFYEARLY, frequency.QUARTERLY, frequency.MONTHLY}
        adjust = getAdjustmentFactor(pos);
        dec = year + (per + adjust) ./ freq;
    case frequency.WEEKLY
        switch pos
            case {'s', 'b', 'f'}
                conversionDay = 'Monday';
            case {'c', 'm'}
                conversionDay = 'Thursday';
            case {'e', 'l'}
                conversionDay = 'Sunday';
            otherwise
                conversionDay = 'Monday';
        end
        x = ww2day(dat, conversionDay);
        dec = day2dec(x);
    otherwise
        throw( exception.Base('Dates:UnrecognizedFrequency', 'error') );        
end

end%


%
% Local Functions
%


function adjust = getAdjustmentFactor(pos)
    switch pos
        case {'s', 'b', 'f'}
            adjust = -1;
        case {'c', 'm'}
            adjust = -1/2;
        case {'e', 'l'}
            adjust = 0;
        otherwise
            adjust = -1;
    end
end%

