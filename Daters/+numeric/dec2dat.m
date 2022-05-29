function dat = dec2dat(dec, freq, pos)
% numeric.dec2dat  Convert decimal representation of date to datecode
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

if nargin<3
    pos = 's';
end
pos = lower(pos(1));

%--------------------------------------------------------------------------

Frequency.checkMixedFrequency(freq);
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
        dat = numeric.datecode(freq, year, per);
    case 52
        day = dec2day(dec);
        dat = numeric.day2ww(day);
    otherwise
        throw( exception.Base('Dates:UnrecognizedFrequency', 'error') )        
end

end%

