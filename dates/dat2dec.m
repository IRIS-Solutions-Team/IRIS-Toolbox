function dec = dat2dec(dat, pos)
% dat2dec  Convert dates to decimal grid.
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if nargin<2
    pos = 's';
end
pos = lower(pos(1));

%--------------------------------------------------------------------------

dec = nan(size(dat));
if isempty(dat)
    return
end

[year, per, freq] = dat2ypf(dat);

DateWrapper.checkMixedFrequency(freq);
freq = freq(1);

switch freq
    case {0, 365}
        dec = per;
    case {1, 2, 4, 6, 12}
        switch pos
            case {'s', 'b'}
                adjust = -1;
            case {'c', 'm'}
                adjust = -1/2;
            case {'e'}
                adjust = 0;
            otherwise
                adjust = -1;
        end
        dec = year + (per + adjust) ./ freq;
    case 52
        switch pos
            case {'s', 'b'}
                standinDay = 'Monday';
            case {'c', 'm'}
                standinDay = 'Thursday';
            case {'e'}
                standinDay = 'Sunday';
            otherwise
                standinDay = 'Monday';
        end
        x = ww2day(dat, standinDay);
        dec = day2dec(x);
    otherwise
        throw( ...
            exception.Base('Dates:UnrecognizedFrequency', 'error') ...
        );        
end

end
