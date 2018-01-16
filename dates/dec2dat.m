function dat = dec2dat(dec, freq, pos)
% dec2dat  Convert decimal representation of date to IRIS serial date number.
%
% __Syntax__
%
%     dat = dec2dat(dec, freq)
%
%
% __Input Arguments__
%
% * `dec` [ numeric ] - Decimal numbers representing dates.
%
% * `freq` [ freq ] - Date frequency.
%
%
% __Output Arguments__
%
% * `dat` [ numeric ] - IRIS serial date numbers corresponding to the
% decimal representations `dec`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if nargin<3
    pos = 's';
end
pos = lower(pos(1));

%--------------------------------------------------------------------------

DateWrapper.checkMixedFrequency(freq);
freq = freq(1);

switch freq
    case 0
        dat = dec;
    case {1, 2, 4, 6, 12}
        switch pos
            case {'s','b'}
                adjust = -1;
            case {'c','m'}
                adjust = -1/2;
            case {'e'}
                adjust = 0;
            otherwise
                adjust = -1;
        end
        year = floor(dec);
        per = round((dec - year)*freq - adjust);
        dat = datcode(freq, year, per);
    case 52
        day = dec2day(dec);
        dat = day2ww(day);
    otherwise
        throw( ...
            exception.Base('Dates:UnrecognizedFrequency', 'error') ...
            );        
end

end
