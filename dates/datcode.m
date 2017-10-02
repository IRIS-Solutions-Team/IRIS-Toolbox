function dat = datcode(freq, year, per)
% datcode  IRIS serial date number.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if nargin<3
    per = 1;
end

%--------------------------------------------------------------------------

% Determine the size of the resulting date array.
temp = nan(size(freq)) + nan(size(year));
if isnumeric(per)
    temp = temp + nan(size(per));
end
dat = DateWrapper( nan(size(temp)) );

if numel(freq)==1
    freq = repmat(freq, size(temp));
end

if numel(year)==1
    year = repmat(year, size(temp));
end

if numel(per)==1
    per = repmat(per, size(temp));
end

ixZero = freq==0;
ixWeekly = freq==52;
ixReg = freq==1 | freq==2 | freq==4 | freq==6 | freq==12;

if any(~ixReg & ~ixZero & ~ixWeekly)
    throw( ...
        exception.Base('Dates:UnrecognizedFrequency', 'error') ...
    );
end

if any(ixReg)
    if isequal(per, 'end')
        per = nan(size(freq));
        per(ixReg) = freq(ixReg);
    end
    serial = round(year(ixReg)).*round(freq(ixReg)) + round(per(ixReg)) - 1;
    dat(ixReg) = serial + round(freq(ixReg))/100;
    dat = DateWrapper(dat);
end

if any(ixZero)
    dat(ixZero) = DateWrapper.ii( per(ixZero) );
end

if any(ixWeekly)
    if isequal(per, 'end')
        per = nan(size(year));
        per(ixWeekly) = weeksinyear(year(ixWeekly));
    end
    day = fwymonday(year(ixWeekly)) + 7*(per(ixWeekly)-1);
    dat(ixWeekly) = DateWrapper( day2ww(day) );
end

end
